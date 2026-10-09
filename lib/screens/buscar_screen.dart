import 'package:flutter/material.dart';

import '../state/app_state_scope.dart';
import 'detalle_nota_screen.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final TextEditingController _busquedaController = TextEditingController();
  String? _proyectoId;
  Set<String> _etiquetaIds = {};
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

  void _limpiarFiltros() {
    _busquedaController.clear();
    setState(() {
      _proyectoId = null;
      _etiquetaIds.clear();
      _todasLasEtiquetas = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final proyectos = appState.proyectos;

    // Evita filtros inválidos si se elimina un proyecto o una etiqueta.
    final proyectoActivo = _proyectoId != null &&
            appState.obtenerProyecto(_proyectoId!) != null
        ? _proyectoId
        : null;
    final etiquetasActivas = _etiquetaIds
        .where((id) => appState.obtenerEtiqueta(id) != null)
        .toSet();

    final resultados = appState.buscarNotas(
      texto: _busquedaController.text,
      proyectoId: proyectoActivo,
      etiquetaIds: etiquetasActivas,
      todasLasEtiquetas: _todasLasEtiquetas,
    );

    final hayFiltros = _busquedaController.text.isNotEmpty ||
        proyectoActivo != null ||
        etiquetasActivas.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar notas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _busquedaController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Buscar en todas las notas',
                hintText: 'Título o contenido',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Borrar búsqueda',
                        onPressed: _busquedaController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Filtrar por proyecto',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: proyectoActivo ?? '',
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Todos los proyectos'),
                    ),
                    ...proyectos.map(
                      (proyecto) => DropdownMenuItem<String>(
                        value: proyecto.id,
                        child: Text(
                          proyecto.nombre,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _proyectoId = valor == '' ? null : valor;
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _mostrarFiltrosEtiquetas,
                    icon: const Icon(Icons.filter_list),
                    label: Text('Etiquetas (${etiquetasActivas.length})'),
                  ),
                ),
                if (hayFiltros) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _limpiarFiltros,
                    child: const Text('Limpiar'),
                  ),
                ],
              ],
            ),
          ),
          if (etiquetasActivas.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final id in etiquetasActivas)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text(appState.obtenerEtiqueta(id)!.nombre),
                        onDeleted: () {
                          setState(() {
                            _etiquetaIds.remove(id);
                          });
                        },
                      ),
                    ),
                  if (etiquetasActivas.length > 1)
                    Center(
                      child: Text(
                        _todasLasEtiquetas ? 'Todas' : 'Al menos una',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${resultados.length} nota(s) encontrada(s)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Expanded(
            child: resultados.isEmpty
                ? Center(
                    child: Text(
                      hayFiltros
                          ? 'No hay notas que coincidan con los filtros.'
                          : 'No hay notas disponibles.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    key: const PageStorageKey<String>('buscar-resultados'),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: resultados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, indice) {
                      final nota = resultados[indice];
                      final proyecto =
                          appState.obtenerProyecto(nota.proyectoId);
                      final etiquetas = appState.etiquetasDeNota(nota);
                      final extracto = nota.descripcion
                          .replaceAll(RegExp(r'\s+'), ' ')
                          .trim();

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
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
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nota.titulo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  proyecto?.nombre ?? 'Proyecto desconocido',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  extracto.isEmpty
                                      ? 'Sin descripción'
                                      : extracto,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (etiquetas.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      for (final etiqueta in etiquetas)
                                        Chip(
                                          label: Text(etiqueta.nombre),
                                          visualDensity:
                                              VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _mostrarFiltrosEtiquetas() {
    final appState = AppStateScope.of(context);
    final etiquetas = appState.etiquetas;
    final seleccionadas = _etiquetaIds
        .where((id) => appState.obtenerEtiqueta(id) != null)
        .toSet();
    var todas = _todasLasEtiquetas;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(sheetContext).height * 0.7,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtrar por etiquetas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: etiquetas.isEmpty
                            ? const Center(
                                child: Text('No hay etiquetas disponibles.'),
                              )
                            : ListView.builder(
                                itemCount: etiquetas.length,
                                itemBuilder: (context, indice) {
                                  final etiqueta = etiquetas[indice];
                                  return CheckboxListTile(
                                    title: Text(etiqueta.nombre),
                                    value: seleccionadas.contains(etiqueta.id),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    onChanged: (valor) {
                                      setModalState(() {
                                        if (valor == true) {
                                          seleccionadas.add(etiqueta.id);
                                        } else {
                                          seleccionadas.remove(etiqueta.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                      if (seleccionadas.length > 1)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('La nota debe tener todas'),
                          subtitle: const Text(
                            'Desactivado: basta con al menos una',
                          ),
                          value: todas,
                          onChanged: (valor) {
                            setModalState(() => todas = valor);
                          },
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _etiquetaIds = seleccionadas;
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
              ),
            );
          },
        );
      },
    );
  }
}
