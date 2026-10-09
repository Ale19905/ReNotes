import 'package:flutter/material.dart';

import '../models/etiqueta.dart';
import '../state/app_state_scope.dart';
import '../utils/text_utils.dart';

class EditorNotaScreen extends StatefulWidget {
  final String proyectoId;
  final String? notaId;

  const EditorNotaScreen({
    super.key,
    required this.proyectoId,
    this.notaId,
  });

  @override
  State<EditorNotaScreen> createState() => _EditorNotaScreenState();
}

class _EditorNotaScreenState extends State<EditorNotaScreen> {
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;

  TextEditingController? _etiquetaController;

  final Set<String> _etiquetaIds = {};

  bool _inicializado = false;
  bool _hayCambios = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_inicializado) {
      return;
    }

    final appState = AppStateScope.of(context);
    final nota = widget.notaId == null
        ? null
        : appState.obtenerNota(widget.notaId!);

    _tituloController = TextEditingController(
      text: nota?.titulo ?? '',
    );

    _descripcionController = TextEditingController(
      text: nota?.descripcion ?? '',
    );

    if (nota != null) {
      _etiquetaIds.addAll(nota.etiquetaIds);
    }

    _inicializado = true;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final proyecto = appState.obtenerProyecto(widget.proyectoId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _manejarRetroceso,
  child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.notaId == null ? 'Nueva nota' : 'Editar nota',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (proyecto != null)
                  Text(
                    'Proyecto: ${proyecto.nombre}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: _tituloController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {
                      _hayCambios = true;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descripcionController,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  minLines: 8,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    hintText: 'Escribe el contenido de la nota...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {
                      _hayCambios = true;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Etiquetas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_etiquetaIds.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _etiquetaIds.map((id) {
                      final etiqueta = appState.obtenerEtiqueta(id);

                      if (etiqueta == null) {
                        return const SizedBox.shrink();
                      }

                      return InputChip(
                        label: Text(etiqueta.nombre),
                        onDeleted: () {
                          setState(() {
                            _etiquetaIds.remove(id);
                            _hayCambios = true;
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 10),
                Autocomplete<_OpcionEtiqueta>(
                  displayStringForOption: (opcion) => opcion.texto,
                  optionsBuilder: (textEditingValue) {
                    final texto = textEditingValue.text.trim();

                    if (texto.isEmpty) {
                      return const Iterable<_OpcionEtiqueta>.empty();
                    }

                    final textoNormalizado =
                        normalizarTexto(texto);

                    final opciones = appState.etiquetas
                        .where(
                          (etiqueta) =>
                              !_etiquetaIds.contains(etiqueta.id) &&
                              normalizarTexto(etiqueta.nombre)
                                  .contains(textoNormalizado),
                        )
                        .map(_OpcionEtiqueta.existente)
                        .toList();

                    final existeCoincidenciaExacta =
                        appState.etiquetas.any(
                      (etiqueta) =>
                          normalizarTexto(etiqueta.nombre) ==
                          textoNormalizado,
                    );

                    if (!existeCoincidenciaExacta) {
                      opciones.add(
                        _OpcionEtiqueta.nueva(texto),
                      );
                    }

                    return opciones;
                  },
                  onSelected: _seleccionarOpcionEtiqueta,
                  fieldViewBuilder: (
                    context,
                    controller,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    _etiquetaController = controller;

                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Agregar etiqueta',
                        hintText: 'Escribe para buscar o crear',
                        prefixIcon: Icon(Icons.label_outline),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _procesarComa,
                      onSubmitted: (valor) {
                        _agregarEtiquetaPorNombre(valor);
                        onFieldSubmitted();
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _guardar,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar nota'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _intentarSalir,
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _manejarRetroceso(
    bool didPop,
    Object? result,
  ) async {
    if (didPop) {
      return;
    }

    final puedeSalir = await _confirmarSalida();

    if (!mounted) {
      return;
    }

    if (!puedeSalir) {
      return;
    }

    Navigator.of(context).pop();
  }

  void _seleccionarOpcionEtiqueta(_OpcionEtiqueta opcion) {
    if (opcion.etiqueta != null) {
      _agregarEtiqueta(opcion.etiqueta!);
    } else if (opcion.nombreNueva != null) {
      _agregarEtiquetaPorNombre(opcion.nombreNueva!);
    }
  }

  void _procesarComa(String texto) {
    if (!texto.contains(',')) {
      return;
    }

    final partes = texto.split(',');

    for (var indice = 0; indice < partes.length - 1; indice++) {
      _agregarEtiquetaPorNombre(partes[indice]);
    }

    final resto = partes.last;
    _etiquetaController?.value = TextEditingValue(
      text: resto,
      selection: TextSelection.collapsed(
        offset: resto.length,
      ),
    );
  }

  void _agregarEtiquetaPorNombre(String nombre) {
    final appState = AppStateScope.of(context);
    final texto = nombre.trim();

    if (texto.isEmpty) {
      return;
    }

    final etiqueta = appState.crearEtiqueta(texto);

    if (etiqueta == null) {
      return;
    }

    _agregarEtiqueta(etiqueta);
  }

  void _agregarEtiqueta(Etiqueta etiqueta) {
    if (_etiquetaIds.contains(etiqueta.id)) {
      _etiquetaController?.clear();
      return;
    }

    setState(() {
      _etiquetaIds.add(etiqueta.id);
      _hayCambios = true;
    });

    _etiquetaController?.clear();
  }

  void _guardar() {
    final appState = AppStateScope.of(context);
    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título de la nota es obligatorio.'),
        ),
      );
      return;
    }

    if (widget.notaId == null) {
      appState.crearNota(
        proyectoId: widget.proyectoId,
        titulo: titulo,
        descripcion: _descripcionController.text,
        etiquetaIds: _etiquetaIds.toList(),
      );
    } else {
      appState.actualizarNota(
        id: widget.notaId!,
        titulo: titulo,
        descripcion: _descripcionController.text,
        etiquetaIds: _etiquetaIds.toList(),
      );
    }

    _hayCambios = false;
    Navigator.pop(context);
  }

  Future<bool> _confirmarSalida() async {
    if (!_hayCambios) {
      return true;
    }

    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cambios sin guardar'),
          content: const Text(
            'Si sales ahora, perderás los cambios realizados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Continuar editando'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    return salir == true;
  }

  Future<void> _intentarSalir() async {
    final puedeSalir = await _confirmarSalida();

    if (!mounted) {
      return;
    }

    if (!puedeSalir) {
      return;
    }

    Navigator.of(context).pop();
  }
}

class _OpcionEtiqueta {
  final Etiqueta? etiqueta;
  final String? nombreNueva;

  const _OpcionEtiqueta.existente(this.etiqueta)
      : nombreNueva = null;

  const _OpcionEtiqueta.nueva(String nombre)
      : etiqueta = null,
        nombreNueva = nombre;

  String get texto => etiqueta?.nombre ?? 'Crear "$nombreNueva"';
}