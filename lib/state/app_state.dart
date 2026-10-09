import 'package:flutter/foundation.dart';

import '../data/datos_prueba.dart';
import '../models/etiqueta.dart';
import '../models/nota.dart';
import '../models/proyecto.dart';
import '../utils/text_utils.dart';

class AppState extends ChangeNotifier {
  late final List<Proyecto> _proyectos;
  late final List<Nota> _notas;
  late final List<Etiqueta> _etiquetas;

  AppState() {
    _proyectos = DatosPrueba.proyectos.map(_copiarProyecto).toList();
    _notas = DatosPrueba.notas.map(_copiarNota).toList();
    _etiquetas = DatosPrueba.etiquetas.map(_copiarEtiqueta).toList();
  }

  List<Proyecto> get proyectos => List.unmodifiable(_proyectos);

  List<Nota> get notas => List.unmodifiable(_notas);

  List<Etiqueta> get etiquetas => List.unmodifiable(_etiquetas);

  Proyecto? obtenerProyecto(String id) {
    for (final proyecto in _proyectos) {
      if (proyecto.id == id) {
        return proyecto;
      }
    }
    return null;
  }

  Nota? obtenerNota(String id) {
    for (final nota in _notas) {
      if (nota.id == id) {
        return nota;
      }
    }
    return null;
  }

  Etiqueta? obtenerEtiqueta(String id) {
    for (final etiqueta in _etiquetas) {
      if (etiqueta.id == id) {
        return etiqueta;
      }
    }
    return null;
  }

  List<Nota> notasDelProyecto(String proyectoId) {
    return _notas
        .where((nota) => nota.proyectoId == proyectoId)
        .toList();
  }

  List<Etiqueta> etiquetasDeNota(Nota nota) {
    return nota.etiquetaIds
        .map(obtenerEtiqueta)
        .whereType<Etiqueta>()
        .toList();
  }

  List<Etiqueta> etiquetasDelProyecto(String proyectoId) {
    final ids = <String>{};

    for (final nota in notasDelProyecto(proyectoId)) {
      ids.addAll(nota.etiquetaIds);
    }

    return _etiquetas
        .where((etiqueta) => ids.contains(etiqueta.id))
        .toList();
  }

  Proyecto? crearProyecto({
    required String nombre,
    String descripcion = '',
  }) {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      return null;
    }

    final ahora = DateTime.now();

    final proyecto = Proyecto(
      id: _nuevoId('proyecto'),
      nombre: nombreLimpio,
      descripcion: descripcion.trim(),
      fechaCreacion: ahora,
      fechaModificacion: ahora,
    );

    _proyectos.add(proyecto);
    notifyListeners();

    return proyecto;
  }

  void actualizarProyecto({
    required String id,
    required String nombre,
    required String descripcion,
  }) {
    final proyecto = obtenerProyecto(id);

    if (proyecto == null || nombre.trim().isEmpty) {
      return;
    }

    proyecto.nombre = nombre.trim();
    proyecto.descripcion = descripcion.trim();
    proyecto.fechaModificacion = DateTime.now();

    notifyListeners();
  }

  void eliminarProyecto(String id) {
    _proyectos.removeWhere((proyecto) => proyecto.id == id);
    _notas.removeWhere((nota) => nota.proyectoId == id);

    notifyListeners();
  }

  Nota? crearNota({
    required String proyectoId,
    required String titulo,
    String descripcion = '',
    List<String> etiquetaIds = const [],
  }) {
    final tituloLimpio = titulo.trim();

    if (tituloLimpio.isEmpty || obtenerProyecto(proyectoId) == null) {
      return null;
    }

    final ahora = DateTime.now();

    final nota = Nota(
      id: _nuevoId('nota'),
      proyectoId: proyectoId,
      titulo: tituloLimpio,
      descripcion: descripcion,
      fechaCreacion: ahora,
      fechaModificacion: ahora,
      etiquetaIds: etiquetaIds,
    );

    _notas.add(nota);

    final proyecto = obtenerProyecto(proyectoId);
    proyecto?.fechaModificacion = ahora;

    notifyListeners();

    return nota;
  }

  void actualizarNota({
    required String id,
    required String titulo,
    required String descripcion,
    required List<String> etiquetaIds,
  }) {
    final nota = obtenerNota(id);

    if (nota == null || titulo.trim().isEmpty) {
      return;
    }

    nota.titulo = titulo.trim();
    nota.descripcion = descripcion;
    nota.etiquetaIds
      ..clear()
      ..addAll(etiquetaIds);
    nota.fechaModificacion = DateTime.now();

    final proyecto = obtenerProyecto(nota.proyectoId);
    proyecto?.fechaModificacion = nota.fechaModificacion;

    notifyListeners();
  }

  void eliminarNota(String id) {
    final nota = obtenerNota(id);

    if (nota == null) {
      return;
    }

    _notas.removeWhere((elemento) => elemento.id == id);

    final proyecto = obtenerProyecto(nota.proyectoId);
    proyecto?.fechaModificacion = DateTime.now();

    notifyListeners();
  }

  Etiqueta? crearEtiqueta(String nombre) {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      return null;
    }

    final existente = _buscarEtiquetaPorNombre(nombreLimpio);

    if (existente != null) {
      return existente;
    }

    final etiqueta = Etiqueta(
      id: _nuevoId('etiqueta'),
      nombre: nombreLimpio,
    );

    _etiquetas.add(etiqueta);
    notifyListeners();

    return etiqueta;
  }

  bool renombrarEtiqueta({
    required String id,
    required String nuevoNombre,
  }) {
    final nombreLimpio = nuevoNombre.trim();

    if (nombreLimpio.isEmpty) {
      return false;
    }

    final etiqueta = obtenerEtiqueta(id);

    if (etiqueta == null) {
      return false;
    }

    final otraEtiqueta = _buscarEtiquetaPorNombre(
      nombreLimpio,
      excluirId: id,
    );

    if (otraEtiqueta != null) {
      return false;
    }

    etiqueta.nombre = nombreLimpio;
    notifyListeners();

    return true;
  }

  int eliminarEtiqueta(String id) {
    final cantidadAfectada = _notas
        .where((nota) => nota.etiquetaIds.contains(id))
        .length;

    for (final nota in _notas) {
      nota.etiquetaIds.remove(id);
    }

    _etiquetas.removeWhere((etiqueta) => etiqueta.id == id);

    notifyListeners();

    return cantidadAfectada;
  }

  List<Nota> buscarNotas({
    String texto = '',
    String? proyectoId,
    Set<String> etiquetaIds = const {},
    bool todasLasEtiquetas = false,
  }) {
    final consulta = normalizarTexto(texto);

    final resultados = _notas.where((nota) {
      if (proyectoId != null && nota.proyectoId != proyectoId) {
        return false;
      }

      if (consulta.isNotEmpty) {
        final contenido =
            '${nota.titulo} ${nota.descripcion}';

        if (!normalizarTexto(contenido).contains(consulta)) {
          return false;
        }
      }

      if (etiquetaIds.isNotEmpty) {
        final notaTieneTodas = etiquetaIds.every(
          nota.etiquetaIds.contains,
        );

        final notaTieneAlguna = etiquetaIds.any(
          nota.etiquetaIds.contains,
        );

        if (todasLasEtiquetas && !notaTieneTodas) {
          return false;
        }

        if (!todasLasEtiquetas && !notaTieneAlguna) {
          return false;
        }
      }

      return true;
    }).toList();

    resultados.sort(
      (a, b) => b.fechaModificacion.compareTo(a.fechaModificacion),
    );

    return resultados;
  }

  List<Nota> notasConEtiquetas({
    required Set<String> etiquetaIds,
    required bool todas,
  }) {
    return buscarNotas(
      etiquetaIds: etiquetaIds,
      todasLasEtiquetas: todas,
    );
  }

  Etiqueta? _buscarEtiquetaPorNombre(
    String nombre, {
    String? excluirId,
  }) {
    final nombreNormalizado = normalizarTexto(nombre);

    for (final etiqueta in _etiquetas) {
      if (etiqueta.id == excluirId) {
        continue;
      }

      if (normalizarTexto(etiqueta.nombre) == nombreNormalizado) {
        return etiqueta;
      }
    }

    return null;
  }

  String _nuevoId(String prefijo) {
    return '$prefijo-${DateTime.now().microsecondsSinceEpoch}';
  }

  static Proyecto _copiarProyecto(Proyecto proyecto) {
    return Proyecto(
      id: proyecto.id,
      nombre: proyecto.nombre,
      descripcion: proyecto.descripcion,
      fechaCreacion: proyecto.fechaCreacion,
      fechaModificacion: proyecto.fechaModificacion,
    );
  }

  static Nota _copiarNota(Nota nota) {
    return Nota(
      id: nota.id,
      proyectoId: nota.proyectoId,
      titulo: nota.titulo,
      descripcion: nota.descripcion,
      fechaCreacion: nota.fechaCreacion,
      fechaModificacion: nota.fechaModificacion,
      etiquetaIds: nota.etiquetaIds,
    );
  }

  static Etiqueta _copiarEtiqueta(Etiqueta etiqueta) {
    return Etiqueta(
      id: etiqueta.id,
      nombre: etiqueta.nombre,
    );
  }
}