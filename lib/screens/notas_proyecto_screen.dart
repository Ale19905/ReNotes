import 'package:flutter/material.dart';

import '../models/nota.dart';
import '../state/app_state_scope.dart';

import 'detalle_nota_screen.dart';
import 'editor_nota_screen.dart';
import '../models/etiqueta.dart';

class NotasProyectoScreen extends StatefulWidget {
  final String proyectoId;

  const NotasProyectoScreen({
    super.key,
    required this.proyectoId,
  });

  @override
  State<NotasProyectoScreen> createState() => _NotasProyectoScreenState();
}

class _NotasProyectoScreenState extends State<NotasProyectoScreen> {
  final TextEditingController _busquedaController =
      TextEditingController();

  Set<String> _etiquetasSeleccionadas = {};
  bool _todasLasEtiquetas = false;

  @override
  void initState() {
    super.initState();
    _busquedaController.addListener(_actualizarBusqueda);
  }

  @override
  void dispose() {
    _busquedaController
      ..removeListener(_actualizarBusqueda)
      ..dispose();

    super.dispose();
  }

  void _actualizarBusqueda() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final proyecto = appState.obtenerProyecto(widget.proyectoId);

    if (proyecto == null) {
      return const Scaffold(
        body: Center(
          child: Text('El proyecto ya no existe.'),
        ),
      );
    }

    final etiquetasDisponibles =
    appState.etiquetasDelProyecto(widget.proyectoId);

    final idsDisponibles =
        etiquetasDisponibles.map((e) => e.id).toSet();

    final filtrosActivos =
        _etiquetasSeleccionadas.intersection(idsDisponibles);

    final cantidadTotal =
        appState.notasDelProyecto(widget.proyectoId).length;

    final notas = appState.buscarNotas(
      texto: _busquedaController.text,
      proyectoId: widget.proyectoId,
      etiquetaIds: filtrosActivos,
      todasLasEtiquetas: _todasLasEtiquetas,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(proyecto.nombre),
        actions: [
          IconButton(
            tooltip: 'Filtrar por etiquetas',
            icon: Badge(
              isLabelVisible: filtrosActivos.isNotEmpty,
              label: Text('${filtrosActivos.length}'),
            child: const Icon(Icons.filter_list),
            ),
            onPressed: () {
              _mostrarFiltros(
                context,
                etiquetasDisponibles,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: 'Buscar notas',
                hintText: 'Título o contenido',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _busquedaController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$cantidadTotal nota(s) en este proyecto',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          if (filtrosActivos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  children: [
                    ...filtrosActivos.map((id) {
                      final etiqueta = appState.obtenerEtiqueta(id);

                      return Chip(
                        label: Text(etiqueta?.nombre ?? ''),
                        onDeleted: () {
                          setState(() {
                            _etiquetasSeleccionadas.remove(id);
                          });
                        },
                      );
                    }),
                    if (filtrosActivos.length > 1)
                      Text(
                        _todasLasEtiquetas
                            ? 'Todas'
                            : 'Al menos una',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: notas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay notas que coincidan con la búsqueda.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notas.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 20),
                    itemBuilder: (context, indice) {
                      final nota = notas[indice];

                      return _TarjetaNota(
                        nota: nota,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleNotaScreen(
                                notaId: nota.id,
                              ),
                            ),
                          );
                        },
                        onEliminar: () {
                          _confirmarEliminarNota(context, nota);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorNotaScreen(
                proyectoId: widget.proyectoId,
              ),
            ),
          );
        },
        icon: const Icon(Icons.note_add),
        label: const Text('Nueva nota'),
      ),
    );
  }

  Future<void> _mostrarFiltros(
    BuildContext context,
    List<Etiqueta> etiquetasDisponibles,
  ) async {
    final appState = AppStateScope.of(context);
    final seleccionadas = Set<String>.from(_etiquetasSeleccionadas);
    var todas = _todasLasEtiquetas;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtrar por etiquetas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (etiquetasDisponibles.isEmpty)
                      const Text(
                        'Este proyecto todavía no tiene etiquetas.',
                      )
                    else
                      ...etiquetasDisponibles.map((etiqueta) {
                        return CheckboxListTile(
                          value: seleccionadas.contains(etiqueta.id),
                          title: Text(etiqueta.nombre),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (seleccionada) {
                            setModalState(() {
                              if (seleccionada == true) {
                                seleccionadas.add(etiqueta.id);
                              } else {
                                seleccionadas.remove(etiqueta.id);
                              }
                            });
                          },
                        );
                      }),
                    if (seleccionadas.length > 1)
                      SwitchListTile(
                        value: todas,
                        title: const Text('La nota debe tener todas'),
                        subtitle: const Text(
                          'Desactivado: tendrá al menos una',
                        ),
                        onChanged: (valor) {
                          setModalState(() {
                            todas = valor;
                          });
                        },
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _etiquetasSeleccionadas = seleccionadas;
                              _todasLasEtiquetas = todas;
                            });

                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Aplicar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Evita que el analizador considere appState no utilizado al modificar
    // posteriormente esta vista con filtros globales.
    appState.etiquetas;
  }

  Future<void> _confirmarEliminarNota(
    BuildContext context,
    Nota nota,
  ) async {
    final appState = AppStateScope.of(context);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar nota'),
          content: Text(
            '¿Deseas eliminar la nota "${nota.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      appState.eliminarNota(nota.id);
    }
  }
}

class _TarjetaNota extends StatelessWidget {
  final Nota nota;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const _TarjetaNota({
    required this.nota,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final etiquetas = appState.etiquetasDeNota(nota);

    final extracto = nota.descripcion
        .replaceAll('\n', ' ')
        .trim();

    final textoExtracto = extracto.length > 150
        ? '${extracto.substring(0, 150)}...'
        : extracto.isEmpty
            ? 'Sin descripción'
            : extracto;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        nota.titulo,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(textoExtracto),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ...etiquetas.map(
                  (etiqueta) => Chip(
                    label: Text(etiqueta.nombre),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Text(
                  'Modificada ${_formatearFecha(nota.fechaModificacion)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
      isThreeLine: true,
      onTap: onTap,
      trailing: PopupMenuButton<String>(
        onSelected: (opcion) {
          if (opcion == 'eliminar') {
            onEliminar();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: 'eliminar',
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

String _formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');

  return '$dia/$mes/${fecha.year}';
}