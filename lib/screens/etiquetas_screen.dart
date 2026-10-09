import 'package:flutter/material.dart';

import '../models/etiqueta.dart';
import '../state/app_state_scope.dart';
import '../utils/text_utils.dart';
import 'detalle_nota_screen.dart';

class EtiquetasScreen extends StatefulWidget {
  final String? filtroInicial;

  const EtiquetasScreen({
    super.key,
    this.filtroInicial,
  });

  @override
  State<EtiquetasScreen> createState() => _EtiquetasScreenState();
}

class _EtiquetasScreenState extends State<EtiquetasScreen> {
  final TextEditingController _busquedaController =
      TextEditingController();

  final Set<String> _etiquetasSeleccionadas = {};
  bool _todasLasEtiquetas = false;

  @override
  void initState() {
    super.initState();

    if (widget.filtroInicial != null) {
      _etiquetasSeleccionadas.add(widget.filtroInicial!);
    }

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
    final etiquetas = _filtrarEtiquetas(appState.etiquetas);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etiquetas'),
        actions: [
          IconButton(
            tooltip: 'Seleccionar varias etiquetas',
            icon: Badge(
              isLabelVisible: _etiquetasSeleccionadas.isNotEmpty,
              label: Text('${_etiquetasSeleccionadas.length}'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () {
              _mostrarSelectorDeEtiquetas(context);
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
                labelText: 'Buscar etiquetas',
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
          if (_etiquetasSeleccionadas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _etiquetasSeleccionadas.map((id) {
                      final etiqueta = appState.obtenerEtiqueta(id);

                      return Chip(
                        label: Text(etiqueta?.nombre ?? ''),
                        onDeleted: () {
                          setState(() {
                            _etiquetasSeleccionadas.remove(id);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (_etiquetasSeleccionadas.length > 1)
                    Text(
                      _todasLasEtiquetas
                          ? 'Se mostrarán notas con todas las etiquetas.'
                          : 'Se mostrarán notas con al menos una etiqueta.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        _mostrarNotasDeEtiquetas(
                          context,
                          _etiquetasSeleccionadas,
                          _todasLasEtiquetas,
                        );
                      },
                      icon: const Icon(Icons.article_outlined),
                      label: const Text('Ver notas agrupadas'),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: etiquetas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay etiquetas disponibles.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: etiquetas.length,
                    itemBuilder: (context, indice) {
                      final etiqueta = etiquetas[indice];
                      final cantidad = appState.notas
                          .where(
                            (nota) =>
                                nota.etiquetaIds.contains(etiqueta.id),
                          )
                          .length;

                      final seleccionada =
                          _etiquetasSeleccionadas.contains(etiqueta.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Checkbox(
                            value: seleccionada,
                            onChanged: (valor) {
                              setState(() {
                                if (valor == true) {
                                  _etiquetasSeleccionadas.add(etiqueta.id);
                                } else {
                                  _etiquetasSeleccionadas.remove(
                                    etiqueta.id,
                                  );
                                }
                              });
                            },
                          ),
                          title: Text(
                            etiqueta.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '$cantidad nota(s) asociada(s)',
                          ),
                          onTap: () {
                            _mostrarNotasDeEtiquetas(
                              context,
                              {etiqueta.id},
                              false,
                            );
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (opcion) {
                              if (opcion == 'renombrar') {
                                _mostrarDialogoRenombrar(
                                  context,
                                  etiqueta,
                                );
                              }

                              if (opcion == 'eliminar') {
                                _confirmarEliminar(
                                  context,
                                  etiqueta,
                                  cantidad,
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'renombrar',
                                child: Text('Renombrar'),
                              ),
                              PopupMenuItem(
                                value: 'eliminar',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mostrarDialogoCrear(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva etiqueta'),
      ),
    );
  }

  List<Etiqueta> _filtrarEtiquetas(List<Etiqueta> etiquetas) {
    final consulta = normalizarTexto(_busquedaController.text);

    if (consulta.isEmpty) {
      return etiquetas;
    }

    return etiquetas
        .where(
          (etiqueta) => normalizarTexto(etiqueta.nombre)
              .contains(consulta),
        )
        .toList();
  }

  Future<void> _mostrarSelectorDeEtiquetas(
    BuildContext context,
  ) async {
    final appState = AppStateScope.of(context);
    final seleccionadas =
        Set<String>.from(_etiquetasSeleccionadas);
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
                      'Agrupar notas por etiquetas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (appState.etiquetas.isEmpty)
                      const Text('Todavía no existen etiquetas.')
                    else
                      ...appState.etiquetas.map((etiqueta) {
                        return CheckboxListTile(
                          value: seleccionadas.contains(etiqueta.id),
                          title: Text(etiqueta.nombre),
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
                      }),
                    if (seleccionadas.length > 1)
                      SwitchListTile(
                        value: todas,
                        title: const Text('Coincidir con todas'),
                        subtitle: const Text(
                          'Desactivado: coincidir con al menos una',
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
                              _etiquetasSeleccionadas
                                ..clear()
                                ..addAll(seleccionadas);
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
  }

  Future<void> _mostrarDialogoCrear(BuildContext context) async {
    final appState = AppStateScope.of(context);

    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => _FormularioEtiquetaDialogo(
        titulo: 'Nueva etiqueta',
        accion: 'Crear',
        etiquetasExistentes: appState.etiquetas,
      ),
    );

    if (nombre == null || !context.mounted) return;

    // La validacion del dialogo evita duplicados; crearEtiqueta tambien
    // los controla en AppState para todos los puntos de entrada.
    appState.crearEtiqueta(nombre);
    _busquedaController.clear(); // Hacer visible la nueva etiqueta si habia filtro.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Etiqueta "$nombre" creada correctamente.')),
    );
  }

  Future<void> _mostrarDialogoRenombrar(
    BuildContext context,
    Etiqueta etiqueta,
  ) async {
    final appState = AppStateScope.of(context);

    final nuevoNombre = await showDialog<String>(
      context: context,
      builder: (_) => _FormularioEtiquetaDialogo(
        titulo: 'Renombrar etiqueta',
        accion: 'Guardar',
        nombreInicial: etiqueta.nombre,
        excluirId: etiqueta.id,
        etiquetasExistentes: appState.etiquetas,
      ),
    );

    if (nuevoNombre == null || !context.mounted) return;

    final guardada = appState.renombrarEtiqueta(
      id: etiqueta.id,
      nuevoNombre: nuevoNombre,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          guardada
              ? 'Etiqueta actualizada correctamente.'
              : 'No se pudo renombrar: ese nombre ya existe.',
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    Etiqueta etiqueta,
    int cantidadNotas,
  ) async {
    final appState = AppStateScope.of(context);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar etiqueta'),
          content: Text(
            cantidadNotas == 0
                ? '¿Deseas eliminar "${etiqueta.nombre}"?'
                : 'La etiqueta se quitará de $cantidadNotas nota(s), '
                    'pero las notas no se eliminarán.',
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
      setState(() {
        _etiquetasSeleccionadas.remove(etiqueta.id);
      });

      appState.eliminarEtiqueta(etiqueta.id);
    }
  }

  Future<void> _mostrarNotasDeEtiquetas(
    BuildContext context,
    Set<String> etiquetaIds,
    bool todas,
  ) async {
    final appState = AppStateScope.of(context);

    final notas = appState.notasConEtiquetas(
      etiquetaIds: etiquetaIds,
      todas: todas,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Notas agrupadas (${notas.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: notas.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay notas con las etiquetas seleccionadas.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: notas.length,
                          itemBuilder: (context, indice) {
                            final nota = notas[indice];
                            final proyecto =
                                appState.obtenerProyecto(
                              nota.proyectoId,
                            );

                            return ListTile(
                              leading: const Icon(Icons.note_outlined),
                              title: Text(nota.titulo),
                              subtitle: Text(
                                proyecto?.nombre ?? 'Sin proyecto',
                              ),
                              onTap: () {
                                Navigator.pop(sheetContext);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetalleNotaScreen(
                                      notaId: nota.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// Este formulario vive dentro de la ruta del dialogo. Sus controladores
// se liberan al desmontar esa ruta, no antes de terminar la animacion.
class _FormularioEtiquetaDialogo extends StatefulWidget {
  final String titulo;
  final String accion;
  final List<Etiqueta> etiquetasExistentes;
  final String nombreInicial;
  final String? excluirId;

  const _FormularioEtiquetaDialogo({
    required this.titulo,
    required this.accion,
    required this.etiquetasExistentes,
    this.nombreInicial = '',
    this.excluirId,
  });

  @override
  State<_FormularioEtiquetaDialogo> createState() =>
      _FormularioEtiquetaDialogoState();
}

class _FormularioEtiquetaDialogoState
    extends State<_FormularioEtiquetaDialogo> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreInicial);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  String? _validarNombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }

    final buscado = normalizarTexto(valor);
    final duplicada = widget.etiquetasExistentes.any(
      (etiqueta) =>
          etiqueta.id != widget.excluirId &&
          normalizarTexto(etiqueta.nombre) == buscado,
    );
    if (duplicada) return 'Ya existe una etiqueta con ese nombre';
    return null;
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_nombreController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.titulo),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nombreController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _guardar(),
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
          validator: _validarNombre,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: Text(widget.accion),
        ),
      ],
    );
  }
}
