import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../groups/di/groups_providers.dart';
import '../../../groups/domain/usecases/get_groups_usecase.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../di/tests_providers.dart';
import '../../domain/entities/screening_entity.dart';
import '../../domain/usecases/get_teacher_items_usecase.dart';
import '../../domain/usecases/submit_teacher_results_usecase.dart';
import '../../domain/usecases/get_catalog_usecase.dart';
import '../../domain/usecases/assign_battery_usecase.dart';
import '../../domain/usecases/open_session_usecase.dart';

const _unset = Object();

String _messageFor(Object error, String fallback) => error is ApiException ? error.userMessage : fallback;

class TestsState {
  final AsyncValue<void> load;
  final AsyncValue<void> submit;
  final List<TeacherItemEntity> teacherItems;
  final List<ScreeningModuleEntity> catalog;
  final Map<String, double> answers;
  final String? selectedStudentId;
  final TeacherResultEntity? teacherResult;
  final AssignmentResultEntity? assignmentResult;

  const TestsState({
    this.load = const AsyncValue.data(null),
    this.submit = const AsyncValue.data(null),
    this.teacherItems = const [],
    this.catalog = const [],
    this.answers = const {},
    this.selectedStudentId,
    this.teacherResult,
    this.assignmentResult,
  });

  bool get isLoading => load.isLoading;
  bool get isSubmitting => submit.isLoading;

  String? get error {
    final err = submit.error ?? load.error;
    if (err == null) return null;
    return _messageFor(err, 'Ocurrió un error.');
  }

  bool get questionnaireComplete => teacherItems.isNotEmpty && answers.length == teacherItems.length;

  Map<String, List<TeacherItemEntity>> get itemsPorCategoria => agruparPorCategoria(teacherItems);

  String moduleName(String code) => catalog.where((m) => m.moduleCode == code).firstOrNull?.name ?? code;

  TestsState copyWith({
    AsyncValue<void>? load,
    AsyncValue<void>? submit,
    List<TeacherItemEntity>? teacherItems,
    List<ScreeningModuleEntity>? catalog,
    Map<String, double>? answers,
    Object? selectedStudentId = _unset,
    Object? teacherResult = _unset,
    Object? assignmentResult = _unset,
  }) {
    return TestsState(
      load: load ?? this.load,
      submit: submit ?? this.submit,
      teacherItems: teacherItems ?? this.teacherItems,
      catalog: catalog ?? this.catalog,
      answers: answers ?? this.answers,
      selectedStudentId: identical(selectedStudentId, _unset) ? this.selectedStudentId : selectedStudentId as String?,
      teacherResult: identical(teacherResult, _unset) ? this.teacherResult : teacherResult as TeacherResultEntity?,
      assignmentResult: identical(assignmentResult, _unset) ? this.assignmentResult : assignmentResult as AssignmentResultEntity?,
    );
  }
}

class TestsNotifier extends Notifier<TestsState> {
  late GetTeacherItemsUseCase _getTeacherItems;
  late SubmitTeacherResultsUseCase _submitTeacherResults;
  late GetCatalogUseCase _getCatalog;
  late AssignBatteryUseCase _assignBattery;
  late OpenSessionUseCase _openSession;
  late GetGroupsUseCase _getGroups;
  Map<String, int> _gradePorGrupo = {};

  @override
  TestsState build() {
    final repo = ref.watch(screeningRepositoryProvider);
    _getTeacherItems = GetTeacherItemsUseCase(repo);
    _submitTeacherResults = SubmitTeacherResultsUseCase(repo);
    _getCatalog = GetCatalogUseCase(repo);
    _assignBattery = AssignBatteryUseCase(repo);
    _openSession = OpenSessionUseCase(repo);
    _getGroups = GetGroupsUseCase(ref.watch(groupRepositoryProvider));
    return const TestsState();
  }

  void selectStudent(String studentId) {
    state = state.copyWith(selectedStudentId: studentId, answers: const {}, teacherResult: null, assignmentResult: null);
  }

  Future<void> selectStudentAndLoad(StudentEntity student) async {
    final grade = gradeDesdeGrupo(student.groupId, _gradePorGrupo);
    state = state.copyWith(
      selectedStudentId: student.id,
      answers: const {},
      teacherResult: null,
      assignmentResult: null,
      load: const AsyncValue.loading(),
    );
    final result = await AsyncValue.guard(() => _getTeacherItems(grade: grade));
    state = result.when(
      data: (items) => state.copyWith(load: const AsyncValue.data(null), teacherItems: items),
      error: (e, st) => state.copyWith(load: AsyncValue.error(e, st)),
      loading: () => state,
    );
  }

  Future<void> loadTeacherItemsAndCatalog() async {
    state = state.copyWith(load: const AsyncValue.loading());
    final result = await AsyncValue.guard(() async {
      final raw = await _getCatalog();
      final seen = <String>{};
      final catalog = raw.where((m) => seen.add(m.moduleCode)).toList();
      final grupos = await _getGroups();
      _gradePorGrupo = {for (final g in grupos) g.id: g.grade};
      return catalog;
    });
    state = result.when(
      data: (catalog) => state.copyWith(load: const AsyncValue.data(null), catalog: catalog),
      error: (e, st) => state.copyWith(load: AsyncValue.error(e, st)),
      loading: () => state,
    );
  }

  void answerQuestion(String itemCode, double value) {
    state = state.copyWith(answers: {...state.answers, itemCode: value});
  }

  Future<bool> submitQuestionnaire() async {
    if (state.selectedStudentId == null || !state.questionnaireComplete) return false;
    state = state.copyWith(submit: const AsyncValue.loading());
    try {
      final list = state.teacherItems.map((i) => TeacherAnswer(itemCode: i.itemCode, value: state.answers[i.itemCode]!)).toList();
      final result = await _submitTeacherResults(state.selectedStudentId!, list);
      state = state.copyWith(submit: const AsyncValue.data(null), teacherResult: result);
      return true;
    } catch (e, st) {
      state = state.copyWith(submit: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> assignBattery() async {
    if (state.selectedStudentId == null || state.teacherResult == null) return false;
    state = state.copyWith(submit: const AsyncValue.loading());
    try {
      final result = await _assignBattery(state.selectedStudentId!, state.teacherResult!.score, state.teacherResult!.riskFlags);
      state = state.copyWith(submit: const AsyncValue.data(null), assignmentResult: result);
      return true;
    } catch (e, st) {
      state = state.copyWith(submit: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<ScreeningSessionEntity?> openFirstSession() async {
    final assignmentResult = state.assignmentResult;
    if (assignmentResult == null || assignmentResult.assignments.isEmpty) return null;
    final first = assignmentResult.assignments.first;
    try {
      return await _openSession(assignmentId: first.id, moduleCode: first.moduleCode, deviceId: 'flutter-app', appVersion: '1.0.0');
    } on ApiException catch (e, st) {
      state = state.copyWith(submit: AsyncValue.error(e, st));
      return null;
    }
  }

  void reset() {
    state = state.copyWith(
      answers: const {},
      selectedStudentId: null,
      teacherResult: null,
      assignmentResult: null,
      submit: const AsyncValue.data(null),
    );
  }
}

final testsViewModelProvider = NotifierProvider<TestsNotifier, TestsState>(TestsNotifier.new);

Map<String, List<TeacherItemEntity>> agruparPorCategoria(List<TeacherItemEntity> items) {
  const orden = ['HISTORIA_CLINICA', 'RIESGO', 'DISCREPANCIA'];
  final mapa = <String, List<TeacherItemEntity>>{};
  for (final cat in orden) {
    final delGrupo = items.where((i) => i.categoria == cat).toList();
    if (delGrupo.isNotEmpty) mapa[cat] = delGrupo;
  }
  return mapa;
}

int? gradeDesdeGrupo(String groupId, Map<String, int> gradePorGrupo) => gradePorGrupo[groupId];
