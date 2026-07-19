class ActivePathEntity {
  final String pathId;
  final List<String> exerciseRoute;
  final int currentDifficulty;
  final String routeCode;
  final String routeReason;

  const ActivePathEntity({
    required this.pathId,
    required this.exerciseRoute,
    required this.currentDifficulty,
    required this.routeCode,
    required this.routeReason,
  });
}

class ExerciseDetailEntity {
  final String exerciseId;
  final String tipo;
  final String titulo;
  final String instruccion;
  final bool usaTts;
  final bool usaStt;
  final int nivel;
  final List<Map<String, dynamic>> items;

  /// Texto corrido de los ejercicios de lectura (guiada, repetida,
  /// temporizada, karaoke). 13 de los 29 ejercicios del banco no traen
  /// `items` sino este texto: sin él la pantalla no tenía nada que mostrar
  /// y el ejercicio no se podía hacer dentro de la app.
  final String modalidad;
  final String? texto;
  final int? metaPalabrasPorMinuto;
  final int? repeticiones;

  /// Pide al alumno predecir cuántas preguntas acertará antes de responder.
  /// Es el ejercicio de metacognición de la vía de comprensión.
  final bool autoevaluacion;

  const ExerciseDetailEntity({
    required this.exerciseId,
    required this.tipo,
    required this.titulo,
    required this.instruccion,
    required this.usaTts,
    required this.usaStt,
    required this.nivel,
    required this.items,
    this.modalidad = '',
    this.texto,
    this.metaPalabrasPorMinuto,
    this.repeticiones,
    this.autoevaluacion = false,
  });
}

class NextExerciseEntity {
  final String? exerciseId;
  final String action;
  final String? support;
  final ExerciseDetailEntity? exerciseDetail;

  const NextExerciseEntity({
    required this.exerciseId,
    required this.action,
    this.support,
    this.exerciseDetail,
  });

  bool get isComplete => action == 'complete' || exerciseId == null;
}
