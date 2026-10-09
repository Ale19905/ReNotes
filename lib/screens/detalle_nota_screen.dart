import 'package:flutter/material.dart';

import '../models/nota.dart';
import '../state/app_state_scope.dart';
import 'editor_nota_screen.dart';
import 'etiquetas_screen.dart';

class DetalleNotaScreen extends StatelessWidget {
  final String notaId;

  const DetalleNotaScreen({
    super.key,
    required this.notaId,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final nota = appState.obtenerNota(notaId);

    if (nota == null) {
      return const Scaffold(
        body: Center(
          child: Text('La nota ya no existe.'),
        ),
      );
    }

    final proyecto = appState.obtenerProyecto(nota.proyectoId);
    final etiquetas = appState.etiquetasDeNota(nota);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de nota'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditorNotaScreen(
                    proyectoId: nota.proyectoId,
                    notaId: nota.id,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _confirmarEliminar(context, nota);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nota.titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Proyecto: ${proyecto?.nombre ?? 'Desconocido'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Creada: ${_formatearFecha(nota.fechaCreacion)}',
            ),
            Text(
              'Modificada: ${_formatearFecha(nota.fechaModificacion)}',
            ),
            const SizedBox(height: 24),
            if (etiquetas.isNotEmpty) ...[
              Text(
                'Etiquetas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: etiquetas.map((etiqueta) {
                  return ActionChip(
                    label: Text(etiqueta.nombre),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EtiquetasScreen(
                            filtroInicial: etiqueta.id,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              nota.descripcion.isEmpty
                  ? 'Sin descripción'
                  : nota.descripcion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(
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
            '¿Deseas eliminar "${nota.titulo}"?',
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

    if (confirmado == true && context.mounted) {
      appState.eliminarNota(nota.id);
      Navigator.pop(context);
    }
  }
}

String _formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');

  return '$dia/$mes/${fecha.year}';
}