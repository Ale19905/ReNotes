import 'package:flutter/material.dart';

import '../models/proyecto.dart';
import '../state/app_state_scope.dart';
import 'notas_proyecto_screen.dart';

class ProyectosScreen extends StatelessWidget {
  const ProyectosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final proyectos = appState.proyectos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis proyectos'),
      ),
      body: proyectos.isEmpty
          ? const Center(
              child: Text(
                'Todavía no hay proyectos.\nCrea el primero con el botón +',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: proyectos.length,
              itemBuilder: (context, indice) {
                final proyecto = proyectos[indice];
                final cantidadNotas =
                    appState.notasDelProyecto(proyecto.id).length;

                return _TarjetaProyecto(
                  proyecto: proyecto,
                  cantidadNotas: cantidadNotas,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotasProyectoScreen(
                          proyectoId: proyecto.id,
                        ),
                      ),
                    );
                  },
                  onEditar: () {
                    _mostrarDialogoProyecto(
                      context,
                      proyecto: proyecto,
                    );
                  },
                  onEliminar: () {
                    _confirmarEliminarProyecto(
                      context,
                      proyecto,
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mostrarDialogoProyecto(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proyecto'),
      ),
    );
  }

  Future<void> _mostrarDialogoProyecto(
    BuildContext context, {
    Proyecto? proyecto,
  }) async {
    final appState = AppStateScope.of(context);

    final datos = await showDialog<_DatosProyecto>(
      context: context,
      builder: (_) => _FormularioProyectoDialogo(proyecto: proyecto),
    );

    if (datos == null || !context.mounted) return;

    if (proyecto == null) {
      appState.crearProyecto(
        nombre: datos.nombre,
        descripcion: datos.descripcion,
      );
    } else {
      appState.actualizarProyecto(
        id: proyecto.id,
        nombre: datos.nombre,
        descripcion: datos.descripcion,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          proyecto == null
              ? 'Proyecto creado correctamente.'
              : 'Proyecto actualizado correctamente.',
        ),
      ),
    );
  }

  Future<void> _confirmarEliminarProyecto(
    BuildContext context,
    Proyecto proyecto,
  ) async {
    final appState = AppStateScope.of(context);
    final cantidadNotas =
        appState.notasDelProyecto(proyecto.id).length;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar proyecto'),
          content: Text(
            cantidadNotas == 0
                ? '¿Deseas eliminar el proyecto "${proyecto.nombre}"?'
                : 'El proyecto contiene $cantidadNotas nota(s). '
                    'Al eliminarlo también se eliminarán sus notas.',
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
      appState.eliminarProyecto(proyecto.id);
    }
  }
}

// Mantener los controladores dentro del dialogo evita liberarlos
// durante la animacion de cierre de showDialog.
class _DatosProyecto {
  final String nombre;
  final String descripcion;

  const _DatosProyecto({required this.nombre, required this.descripcion});
}

class _FormularioProyectoDialogo extends StatefulWidget {
  final Proyecto? proyecto;

  const _FormularioProyectoDialogo({this.proyecto});

  @override
  State<_FormularioProyectoDialogo> createState() =>
      _FormularioProyectoDialogoState();
}

class _FormularioProyectoDialogoState
    extends State<_FormularioProyectoDialogo> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.proyecto?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.proyecto?.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _DatosProyecto(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(
        widget.proyecto == null ? 'Nuevo proyecto' : 'Editar proyecto',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej. Investigación de mercado',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción corta',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _TarjetaProyecto extends StatelessWidget {
  final Proyecto proyecto;
  final int cantidadNotas;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaProyecto({
    required this.proyecto,
    required this.cantidadNotas,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          child: const Icon(Icons.folder),
        ),
        title: Text(
          proyecto.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${proyecto.descripcion.isEmpty ? 'Sin descripción' : proyecto.descripcion}\n'
            '$cantidadNotas nota(s) · Modificado ${_formatearFecha(proyecto.fechaModificacion)}',
          ),
        ),
        isThreeLine: true,
        onTap: onTap,
        trailing: PopupMenuButton<String>(
          onSelected: (opcion) {
            if (opcion == 'editar') {
              onEditar();
            } else if (opcion == 'eliminar') {
              onEliminar();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'editar',
              child: Text('Editar'),
            ),
            PopupMenuItem(
              value: 'eliminar',
              child: Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');

  return '$dia/$mes/${fecha.year}';
}