import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/screening_entity.dart';
import '../models/screening_model.dart';

/// Maps 1:1 to SCREENING section of API_UI_GUIA.md / API_UI_EJEMPLOS.md
abstract class ScreeningRemoteDataSource {
  Future<List<TeacherItemModel>> getTeacherItems({int? grade});
  Future<TeacherResultModel> submitTeacherResults(String studentId, List<TeacherAnswer> answers);
  Future<List<ScreeningModuleModel>> getCatalog();
  Future<AssignmentResultModel> assignBattery(String studentId, double teacherScore, List<RiskFlag> riskFlags);
  Future<ScreeningSessionModel> openSession({required String assignmentId, required String moduleCode, String? deviceId, String? appVersion});
  Future<SessionItemsResultModel> getSessionItems(String sessionId);
  Future<List<ResponseResultModel>> submitResponses(String sessionId, List<ItemResponseSubmission> responses);
  Future<DiagnosisModel> diagnose(String sessionId);
  Future<DiagnosisModel?> getLatestRisk(String studentId);
  Future<List<PendingModuleModel>> getStudentAssignments(String studentId);
  Future<List<TeacherAssignmentModel>> getTeacherAssignments({String status});
  Future<List<PendingDiagnosisModel>> getPendingDiagnoses({int limit});
  Future<LabelResultModel> labelDiagnosis({
    required String diagnosisId,
    required String confirmedSubtype,
    required String confirmedSeverity,
    required String confirmedRiskLevel,
    String? notes,
  });
}

class ScreeningRemoteDataSourceImpl implements ScreeningRemoteDataSource {
  final ApiClient client;
  const ScreeningRemoteDataSourceImpl(this.client);

  @override
  Future<List<TeacherItemModel>> getTeacherItems({int? grade}) async {
    // El grado elige el ciclo del cuestionario: PRODISLEX tiene un protocolo
    // por ciclo y sus preguntas difieren. Sin esto todos los grados reciben
    // el mismo cuestionario.
    final json = await client.get(
      '/screening/teacher-items',
      query: grade != null ? {'grade': grade} : null,
    );
    return (json as List)
        .map((e) => TeacherItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TeacherResultModel> submitTeacherResults(String studentId, List<TeacherAnswer> answers) async {
    // ⚠️ API requires EXACTLY 8 answers
    assert(answers.length == 8, 'El cuestionario docente requiere exactamente 8 respuestas');
    final json = await client.post('/screening/teacher-results', data: {
      'student_id': studentId,
      'answers': answers.map((a) => {'item_code': a.itemCode, 'value': a.value}).toList(),
    });
    return TeacherResultModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<ScreeningModuleModel>> getCatalog() async {
    final json = await client.get('/screening/catalog');
    return (json as List).map((e) => ScreeningModuleModel.fromJson(e)).toList();
  }

  @override
  Future<AssignmentResultModel> assignBattery(String studentId, double teacherScore, List<RiskFlag> riskFlags) async {
    final json = await client.post('/screening/assignments', data: {
      'student_id': studentId,
      'teacher_score': teacherScore,
      'risk_flags': riskFlags.map((f) => {'flag': f.flag, 'level': f.level}).toList(),
    });
    return AssignmentResultModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<ScreeningSessionModel> openSession({required String assignmentId, required String moduleCode, String? deviceId, String? appVersion}) async {
    final json = await client.post('/screening/sessions', data: {
      'assignment_id': assignmentId,
      'module_code': moduleCode,
      if (deviceId != null) 'device_id': deviceId,
      if (appVersion != null) 'app_version': appVersion,
      'raw_client_payload': {},
    });
    return ScreeningSessionModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<SessionItemsResultModel> getSessionItems(String sessionId) async {
    final json = await client.get('/screening/sessions/$sessionId/items');
    return SessionItemsResultModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<ResponseResultModel>> submitResponses(String sessionId, List<ItemResponseSubmission> responses) async {
    final json = await client.post('/screening/sessions/$sessionId/responses', data: {
      'responses': responses.map((r) => {
        'item_id': r.itemId,
        'raw_response': r.rawResponse,
        'response_time_ms': r.responseTimeMs,
        'capture_modality': r.captureModality,
        if (r.sttConfidence != null) 'stt_confidence': r.sttConfidence,
        if (r.responseAudioUrl != null) 'response_audio_url': r.responseAudioUrl,
        if (r.timingDetail != null) 'timing_detail': r.timingDetail!.toJson(),
      }).toList(),
    });
    final map = json as Map<String, dynamic>;
    return (map['responses'] as List).map((e) => ResponseResultModel.fromJson(e)).toList();
  }

  @override
  Future<DiagnosisModel> diagnose(String sessionId) async {
    final json = await client.post('/screening/sessions/$sessionId/diagnose');
    return DiagnosisModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<DiagnosisModel?> getLatestRisk(String studentId) async {
    try {
      final json = await client.get('/screening/students/$studentId/latest-risk');
      return DiagnosisModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('No latest risk for $studentId: $e');
      return null;
    }
  }

  @override
  Future<List<PendingModuleModel>> getStudentAssignments(String studentId) async {
    try {
      final json = await client.get('/screening/students/$studentId/assignments');
      return (json as List).map((e) => PendingModuleModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('No assignments for $studentId: $e');
      return [];
    }
  }

  @override
  Future<List<TeacherAssignmentModel>> getTeacherAssignments({String status = 'PENDING,IN_PROGRESS'}) async {
    try {
      final json = await client.get('/screening/assignments?status=${Uri.encodeComponent(status)}');
      return (json as List).map((e) => TeacherAssignmentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('getTeacherAssignments error: $e');
      return [];
    }
  }

  @override
  Future<List<PendingDiagnosisModel>> getPendingDiagnoses({int limit = 50}) async {
    try {
      final json = await client.get('/screening/diagnoses/pending-review?limit=$limit');
      return (json as List).map((e) => PendingDiagnosisModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('getPendingDiagnoses error: $e');
      return [];
    }
  }

  @override
  Future<LabelResultModel> labelDiagnosis({
    required String diagnosisId,
    required String confirmedSubtype,
    required String confirmedSeverity,
    required String confirmedRiskLevel,
    String? notes,
  }) async {
    final json = await client.post(
      '/screening/diagnoses/$diagnosisId/label',
      data: {
        'confirmed_subtype': confirmedSubtype,
        'confirmed_severity': confirmedSeverity,
        'confirmed_risk_level': confirmedRiskLevel,
        if (notes != null) 'notes': notes,
      },
    );
    return LabelResultModel.fromJson(json as Map<String, dynamic>);
  }
}
