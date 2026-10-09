class Nota {
  final String id;
  final String proyectoId;
  String titulo;
  String descripcion;
  final DateTime fechaCreacion;
  DateTime fechaModificacion;
  final List<String> etiquetaIds;

  Nota({
    required this.id,
    required this.proyectoId,
    required this.titulo,
    this.descripcion = '',
    required this.fechaCreacion,
    required this.fechaModificacion,
    List<String>? etiquetaIds,
  }) : etiquetaIds = List<String>.from(etiquetaIds ?? []);
}