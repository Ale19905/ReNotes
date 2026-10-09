class Proyecto {
  final String id;
  String nombre;
  String descripcion;
  final DateTime fechaCreacion;
  DateTime fechaModificacion;

  Proyecto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });
}