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

  const ExerciseDetailEntity({
    required this.exerciseId,
    required this.tipo,
    required this.titulo,
    required this.instruccion,
    required this.usaTts,
    required this.usaStt,
    required this.nivel,
    required this.items,
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
