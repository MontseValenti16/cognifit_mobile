import '../../domain/entities/intervention_entity.dart';

class ActivePathModel extends ActivePathEntity {
  const ActivePathModel({
    required super.pathId,
    required super.exerciseRoute,
    required super.currentDifficulty,
    required super.routeCode,
    required super.routeReason,
  });

  factory ActivePathModel.fromJson(Map<String, dynamic> j) {
    final raw = j['exercise_route'];
    final route = raw is List ? raw.map((e) => e.toString()).toList() : <String>[];
    return ActivePathModel(
      pathId: (j['id'] ?? '') as String,
      exerciseRoute: route,
      currentDifficulty: (j['current_difficulty'] as num?)?.toInt() ?? 1,
      routeCode: (j['route_code'] ?? '') as String,
      routeReason: (j['route_reason'] ?? '') as String,
    );
  }
}

class ExerciseDetailModel extends ExerciseDetailEntity {
  const ExerciseDetailModel({
    required super.exerciseId,
    required super.tipo,
    required super.titulo,
    required super.instruccion,
    required super.usaTts,
    required super.usaStt,
    required super.nivel,
    required super.items,
    super.modalidad,
    super.texto,
    super.metaPalabrasPorMinuto,
    super.repeticiones,
    super.autoevaluacion,
    super.grid,
    super.gridColumnas,
    super.subtipo,
    super.paleta,
    super.iconos,
  });

  factory ExerciseDetailModel.fromJson(Map<String, dynamic> j) {
    final rawItems = j['items'] as List? ?? [];
    return ExerciseDetailModel(
      exerciseId: (j['exercise_id'] ?? '') as String,
      tipo: (j['tipo'] ?? '') as String,
      titulo: (j['titulo'] ?? '') as String,
      instruccion: (j['instruccion'] ?? '') as String,
      usaTts: (j['usa_tts'] as bool?) ?? false,
      usaStt: (j['usa_stt'] as bool?) ?? false,
      nivel: (j['nivel'] as num?)?.toInt() ?? 1,
      items: rawItems.cast<Map<String, dynamic>>(),
      modalidad: (j['modalidad'] ?? '') as String,
      // El banco guarda el texto de dos maneras: `texto` (uno corrido) y
      // `textos` (una lista de frases, en la lectura guiada). Leer solo la
      // primera dejaba TTS_lectura_guiada_N1 sin nada que mostrar, aunque el
      // servicio sí enviaba sus cinco frases.
      texto: j['texto'] as String? ??
          (j['textos'] is List
              ? (j['textos'] as List).map((e) => e.toString()).join('\n')
              : null),
      // El banco usa dos nombres para lo mismo según el ejercicio.
      metaPalabrasPorMinuto: (j['meta_palabras_por_minuto'] ?? j['velocidad_palabras_por_minuto']) is num
          ? ((j['meta_palabras_por_minuto'] ?? j['velocidad_palabras_por_minuto']) as num).toInt()
          : null,
      repeticiones: (j['repeticiones'] as num?)?.toInt(),
      autoevaluacion: j['autoevaluacion'] as bool? ?? false,
      grid: (j['grid'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      gridColumnas: (j['grid_columnas'] as num?)?.toInt() ?? 5,
      subtipo: (j['subtipo'] ?? '').toString(),
      paleta: (j['paleta'] as Map?)
              ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
          const {},
      iconos: (j['iconos'] as Map?)
              ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
          const {},
    );
  }
}

class NextExerciseModel extends NextExerciseEntity {
  const NextExerciseModel({
    required super.exerciseId,
    required super.action,
    super.support,
    super.exerciseDetail,
  });

  factory NextExerciseModel.fromJson(Map<String, dynamic> j) {
    final detailRaw = j['exercise_detail'] as Map<String, dynamic>?;
    return NextExerciseModel(
      exerciseId: j['exercise_id'] as String?,
      action: (j['action'] ?? 'complete') as String,
      support: j['support'] as String?,
      exerciseDetail: detailRaw != null ? ExerciseDetailModel.fromJson(detailRaw) : null,
    );
  }
}

class ComprehensionExerciseModel extends ComprehensionExerciseEntity {
  const ComprehensionExerciseModel({
    required super.exerciseId,
    required super.titulo,
    required super.subtipo,
    required super.instruccion,
    required super.modalidad,
    required super.totalPreguntas,
  });

  factory ComprehensionExerciseModel.fromJson(Map<String, dynamic> j) =>
      ComprehensionExerciseModel(
        exerciseId: (j['exercise_id'] ?? '').toString(),
        titulo: (j['titulo'] ?? '').toString(),
        subtipo: (j['subtipo'] ?? '').toString(),
        instruccion: (j['instruccion'] ?? '').toString(),
        modalidad: (j['modalidad'] ?? '').toString(),
        totalPreguntas: (j['total_preguntas'] as num?)?.toInt() ?? 0,
      );
}

class ComprehensionTrackModel extends ComprehensionTrackEntity {
  const ComprehensionTrackModel({
    required super.grade,
    required super.exercises,
    required super.gradosConContenido,
  });

  factory ComprehensionTrackModel.fromJson(Map<String, dynamic> j) {
    final raw = j['exercises'];
    return ComprehensionTrackModel(
      grade: (j['grade'] ?? '').toString(),
      exercises: raw is List
          ? raw
              .map((e) => ComprehensionExerciseModel.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      gradosConContenido: (j['grados_con_contenido'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
