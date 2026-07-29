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

  final String modalidad;
  final String? texto;
  final int? metaPalabrasPorMinuto;
  final int? repeticiones;

  final bool autoevaluacion;

  final List<String> grid;
  final int gridColumnas;
  final String subtipo;

  final Map<String, String> paleta;

  final Map<String, String> iconos;

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
    this.grid = const [],
    this.gridColumnas = 5,
    this.subtipo = '',
    this.paleta = const {},
    this.iconos = const {},
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

class ComprehensionExerciseEntity {
  final String exerciseId;
  final String titulo;
  final String subtipo;
  final String instruccion;
  final String modalidad;
  final int totalPreguntas;

  const ComprehensionExerciseEntity({
    required this.exerciseId,
    required this.titulo,
    required this.subtipo,
    required this.instruccion,
    required this.modalidad,
    required this.totalPreguntas,
  });
}

class ComprehensionTrackEntity {
  final String grade;
  final List<ComprehensionExerciseEntity> exercises;
  final List<String> gradosConContenido;

  const ComprehensionTrackEntity({
    required this.grade,
    required this.exercises,
    required this.gradosConContenido,
  });

  bool get hayContenido => exercises.isNotEmpty;
}
