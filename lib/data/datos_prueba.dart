import '../models/etiqueta.dart';
import '../models/nota.dart';
import '../models/proyecto.dart';

String _descripcionLarga(String tema) {
  return '''
Esta nota contiene información de investigación relacionada con $tema.

El objetivo es recopilar, organizar y analizar los datos relevantes para comprender
mejor el problema estudiado. Durante el proceso se deben registrar las fuentes
consultadas, los principales hallazgos y las decisiones tomadas por el equipo.

También es importante comparar diferentes perspectivas, identificar coincidencias
y diferencias, y dejar documentados los criterios utilizados para llegar a las
conclusiones. Esta información podrá ser revisada posteriormente por otros
integrantes del proyecto.

La investigación debe mantenerse actualizada y ordenada. Cada modificación debe
reflejar claramente qué cambió, cuándo se realizó y cuál fue el motivo del cambio.
De esta manera se facilita la trazabilidad y se evita perder información relevante.

Como siguiente paso, se recomienda validar estos resultados con el equipo,
incorporar nuevas fuentes y definir las acciones necesarias para continuar con
el proyecto de investigación.
''';
}

class DatosPrueba {
  static final List<Proyecto> proyectos = [
    Proyecto(
      id: 'proyecto-1',
      nombre: 'Inteligencia artificial educativa',
      descripcion: 'Aplicaciones de la inteligencia artificial en la educación.',
      fechaCreacion: DateTime(2026, 1, 10),
      fechaModificacion: DateTime(2026, 3, 15),
    ),
    Proyecto(
      id: 'proyecto-2',
      nombre: 'Cambio climático',
      descripcion: 'Análisis de impactos ambientales y posibles soluciones.',
      fechaCreacion: DateTime(2026, 1, 20),
      fechaModificacion: DateTime(2026, 3, 12),
    ),
    Proyecto(
      id: 'proyecto-3',
      nombre: 'Salud digital',
      descripcion: 'Tecnología aplicada a la prevención y atención sanitaria.',
      fechaCreacion: DateTime(2026, 2, 5),
      fechaModificacion: DateTime(2026, 3, 10),
    ),
  ];

  static final List<Etiqueta> etiquetas = [
    Etiqueta(id: 'etiqueta-1', nombre: 'Metodología'),
    Etiqueta(id: 'etiqueta-2', nombre: 'Bibliografía'),
    Etiqueta(id: 'etiqueta-3', nombre: 'Análisis'),
    Etiqueta(id: 'etiqueta-4', nombre: 'Resultados'),
    Etiqueta(id: 'etiqueta-5', nombre: 'Tecnología'),
    Etiqueta(id: 'etiqueta-6', nombre: 'Educación'),
    Etiqueta(id: 'etiqueta-7', nombre: 'Sostenibilidad'),

    // Esta etiqueta se mantiene sin notas para cumplir el requisito del PDF.
    Etiqueta(id: 'etiqueta-8', nombre: 'Sin uso'),
  ];

  static final List<Nota> notas = [
    Nota(
      id: 'nota-1',
      proyectoId: 'proyecto-1',
      titulo: 'Estado actual de la inteligencia artificial',
      descripcion: _descripcionLarga('la inteligencia artificial educativa'),
      fechaCreacion: DateTime(2026, 2, 1),
      fechaModificacion: DateTime(2026, 3, 1),
      etiquetaIds: ['etiqueta-1', 'etiqueta-2', 'etiqueta-5'],
    ),
    Nota(
      id: 'nota-2',
      proyectoId: 'proyecto-1',
      titulo: 'Herramientas para personalizar el aprendizaje',
      descripcion:
          'Se analizaron diferentes herramientas capaces de adaptar los contenidos educativos al ritmo y las necesidades de cada estudiante.',
      fechaCreacion: DateTime(2026, 2, 4),
      fechaModificacion: DateTime(2026, 3, 3),
      etiquetaIds: ['etiqueta-3', 'etiqueta-6'],
    ),
    Nota(
      id: 'nota-3',
      proyectoId: 'proyecto-1',
      titulo: 'Beneficios para docentes y estudiantes',
      descripcion: _descripcionLarga('los beneficios para docentes y estudiantes'),
      fechaCreacion: DateTime(2026, 2, 8),
      fechaModificacion: DateTime(2026, 3, 5),
      etiquetaIds: ['etiqueta-4', 'etiqueta-6'],
    ),
    Nota(
      id: 'nota-4',
      proyectoId: 'proyecto-1',
      titulo: 'Riesgos y consideraciones éticas',
      descripcion:
          'La incorporación de inteligencia artificial exige revisar la privacidad, la transparencia y la responsabilidad en el uso de los datos.',
      fechaCreacion: DateTime(2026, 2, 12),
      fechaModificacion: DateTime(2026, 3, 7),
      etiquetaIds: ['etiqueta-3', 'etiqueta-5'],
    ),
    Nota(
      id: 'nota-5',
      proyectoId: 'proyecto-1',
      titulo: 'Preguntas para futuras investigaciones',
      descripcion: '',
      fechaCreacion: DateTime(2026, 2, 15),
      fechaModificacion: DateTime(2026, 3, 8),
      etiquetaIds: [],
    ),

    Nota(
      id: 'nota-6',
      proyectoId: 'proyecto-2',
      titulo: 'Principales causas del cambio climático',
      descripcion: _descripcionLarga('las causas del cambio climático'),
      fechaCreacion: DateTime(2026, 2, 3),
      fechaModificacion: DateTime(2026, 3, 2),
      etiquetaIds: ['etiqueta-1', 'etiqueta-3', 'etiqueta-7'],
    ),
    Nota(
      id: 'nota-7',
      proyectoId: 'proyecto-2',
      titulo: 'Efectos sobre los ecosistemas',
      descripcion:
          'El aumento de la temperatura y la modificación de los patrones de lluvia afectan a numerosas especies y ecosistemas.',
      fechaCreacion: DateTime(2026, 2, 7),
      fechaModificacion: DateTime(2026, 3, 4),
      etiquetaIds: ['etiqueta-3', 'etiqueta-7'],
    ),
    Nota(
      id: 'nota-8',
      proyectoId: 'proyecto-2',
      titulo: 'Políticas públicas ambientales',
      descripcion: _descripcionLarga('las políticas públicas ambientales'),
      fechaCreacion: DateTime(2026, 2, 10),
      fechaModificacion: DateTime(2026, 3, 6),
      etiquetaIds: ['etiqueta-2', 'etiqueta-4', 'etiqueta-7'],
    ),
    Nota(
      id: 'nota-9',
      proyectoId: 'proyecto-2',
      titulo: 'Fuentes de energía renovable',
      descripcion:
          'La energía solar, eólica e hidráulica constituyen alternativas para reducir la dependencia de combustibles fósiles.',
      fechaCreacion: DateTime(2026, 2, 14),
      fechaModificacion: DateTime(2026, 3, 9),
      etiquetaIds: ['etiqueta-2', 'etiqueta-5', 'etiqueta-7'],
    ),
    Nota(
      id: 'nota-10',
      proyectoId: 'proyecto-2',
      titulo: 'Medidas de adaptación',
      descripcion:
          'Las comunidades necesitan desarrollar medidas de adaptación que reduzcan los efectos de fenómenos climáticos extremos.',
      fechaCreacion: DateTime(2026, 2, 18),
      fechaModificacion: DateTime(2026, 3, 10),
      etiquetaIds: ['etiqueta-1', 'etiqueta-4'],
    ),

    Nota(
      id: 'nota-11',
      proyectoId: 'proyecto-3',
      titulo: 'Telemedicina y acceso a la salud',
      descripcion: _descripcionLarga('la telemedicina y el acceso a la salud'),
      fechaCreacion: DateTime(2026, 2, 6),
      fechaModificacion: DateTime(2026, 3, 1),
      etiquetaIds: ['etiqueta-2', 'etiqueta-5'],
    ),
    Nota(
      id: 'nota-12',
      proyectoId: 'proyecto-3',
      titulo: 'Aplicaciones móviles para pacientes',
      descripcion:
          'Las aplicaciones móviles permiten registrar información, recibir recordatorios y mantener una comunicación más directa con los profesionales.',
      fechaCreacion: DateTime(2026, 2, 11),
      fechaModificacion: DateTime(2026, 3, 3),
      etiquetaIds: ['etiqueta-5', 'etiqueta-4'],
    ),
    Nota(
      id: 'nota-13',
      proyectoId: 'proyecto-3',
      titulo: 'Protección de datos médicos',
      descripcion: _descripcionLarga('la protección de los datos médicos'),
      fechaCreacion: DateTime(2026, 2, 16),
      fechaModificacion: DateTime(2026, 3, 5),
      etiquetaIds: ['etiqueta-1', 'etiqueta-3'],
    ),
    Nota(
      id: 'nota-14',
      proyectoId: 'proyecto-3',
      titulo: 'Tecnologías de monitoreo remoto',
      descripcion:
          'Los sensores y dispositivos conectados pueden ayudar a monitorear signos vitales y detectar cambios importantes.',
      fechaCreacion: DateTime(2026, 2, 20),
      fechaModificacion: DateTime(2026, 3, 7),
      etiquetaIds: ['etiqueta-3', 'etiqueta-5'],
    ),
    Nota(
      id: 'nota-15',
      proyectoId: 'proyecto-3',
      titulo: 'Resultados preliminares',
      descripcion:
          'Los resultados iniciales muestran oportunidades para mejorar la prevención y facilitar el seguimiento de los pacientes.',
      fechaCreacion: DateTime(2026, 2, 25),
      fechaModificacion: DateTime(2026, 3, 10),
      etiquetaIds: ['etiqueta-4', 'etiqueta-6'],
    ),
  ];
}