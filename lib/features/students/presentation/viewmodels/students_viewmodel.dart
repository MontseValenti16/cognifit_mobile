import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/domain/usecases/get_groups_usecase.dart';
import '../../../groups/domain/usecases/create_group_usecase.dart';
import '../../../groups/domain/usecases/delete_group_usecase.dart';
import '../../../groups/di/groups_providers.dart';
import '../../di/students_providers.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/usecases/get_students_usecase.dart';
import '../../domain/usecases/get_student_by_id_usecase.dart';
import '../../domain/usecases/create_student_usecase.dart';
import '../../domain/usecases/update_student_usecase.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/permanent_delete_student_usecase.dart';
import '../../domain/usecases/activate_student_usecase.dart';

const _unset = Object();

String _messageFor(Object error, String fallback) => error is ApiException ? error.userMessage : fallback;

class StudentsState {
  final AsyncValue<void> load;
  final AsyncValue<void> mutation;
  final List<StudentEntity> allStudents;
  final List<GroupEntity> groups;
  final String query;
  final String? groupFilter;

  const StudentsState({
    this.load = const AsyncValue.data(null),
    this.mutation = const AsyncValue.data(null),
    this.allStudents = const [],
    this.groups = const [],
    this.query = '',
    this.groupFilter,
  });

  bool get isLoading => load.isLoading;
  bool get isMutating => mutation.isLoading;

  String? get error {
    final err = mutation.error ?? load.error;
    if (err == null) return null;
    return _messageFor(err, 'Ocurrió un error.');
  }

  bool get hasGroups => groups.isNotEmpty;
  GroupEntity? get defaultGroup => groups.isNotEmpty ? groups.first : null;
  int get totalCount => allStudents.length;
  int get activeCount => allStudents.where((s) => s.isActive).length;

  List<StudentEntity> get students {
    var list = groupFilter == null ? allStudents : allStudents.where((s) => s.groupId == groupFilter).toList();
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((s) => s.fullName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  StudentsState copyWith({
    AsyncValue<void>? load,
    AsyncValue<void>? mutation,
    List<StudentEntity>? allStudents,
    List<GroupEntity>? groups,
    String? query,
    Object? groupFilter = _unset,
  }) {
    return StudentsState(
      load: load ?? this.load,
      mutation: mutation ?? this.mutation,
      allStudents: allStudents ?? this.allStudents,
      groups: groups ?? this.groups,
      query: query ?? this.query,
      groupFilter: identical(groupFilter, _unset) ? this.groupFilter : groupFilter as String?,
    );
  }
}

class StudentsNotifier extends Notifier<StudentsState> {
  late GetStudentsUseCase _getStudents;
  late GetStudentByIdUseCase _getStudentById;
  late CreateStudentUseCase _createStudent;
  late UpdateStudentUseCase _updateStudent;
  late DeleteStudentUseCase _deleteStudent;
  late PermanentDeleteStudentUseCase _permanentDeleteStudent;
  late ActivateStudentUseCase _activateStudent;
  late GetGroupsUseCase _getGroups;
  late CreateGroupUseCase _createGroup;
  late DeleteGroupUseCase _deleteGroup;

  @override
  StudentsState build() {
    final studentRepo = ref.watch(studentRepositoryProvider);
    final groupRepo = ref.watch(groupRepositoryProvider);
    _getStudents = GetStudentsUseCase(studentRepo);
    _getStudentById = GetStudentByIdUseCase(studentRepo);
    _createStudent = CreateStudentUseCase(studentRepo);
    _updateStudent = UpdateStudentUseCase(studentRepo);
    _deleteStudent = DeleteStudentUseCase(studentRepo);
    _permanentDeleteStudent = PermanentDeleteStudentUseCase(studentRepo);
    _activateStudent = ActivateStudentUseCase(studentRepo);
    _getGroups = GetGroupsUseCase(groupRepo);
    _createGroup = CreateGroupUseCase(groupRepo);
    _deleteGroup = DeleteGroupUseCase(groupRepo);
    return const StudentsState();
  }

  Future<void> loadStudents() async {
    state = state.copyWith(load: const AsyncValue.loading());
    final result = await AsyncValue.guard(() async {
      final results = await Future.wait([_getGroups(), _getStudents()]);
      return (groups: results[0] as List<GroupEntity>, students: results[1] as List<StudentEntity>);
    });
    result.when(
      data: (r) => state = state.copyWith(load: const AsyncValue.data(null), groups: r.groups, allStudents: r.students),
      error: (e, st) => state = state.copyWith(load: AsyncValue.error(e, st)),
      loading: () {},
    );
  }

  Future<GroupEntity?> createGroup(CreateGroupParams params) async {
    state = state.copyWith(mutation: const AsyncValue.loading());
    try {
      final created = await _createGroup(params);
      state = state.copyWith(mutation: const AsyncValue.data(null), groups: [created, ...state.groups]);
      return created;
    } catch (e, st) {
      state = state.copyWith(mutation: AsyncValue.error(e, st));
      return null;
    }
  }

  Future<bool> deleteGroup(String id) async {
    state = state.copyWith(mutation: const AsyncValue.loading());
    try {
      await _deleteGroup(id);
      state = state.copyWith(
        mutation: const AsyncValue.data(null),
        groups: state.groups.where((g) => g.id != id).toList(),
        groupFilter: state.groupFilter == id ? null : state.groupFilter,
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(mutation: AsyncValue.error(e, st));
      return false;
    }
  }

  void search(String query) => state = state.copyWith(query: query);
  void filterByGroup(String? groupId) => state = state.copyWith(groupFilter: groupId);

  Future<StudentEntity?> getDetail(String id) async {
    try {
      return await _getStudentById(id);
    } on ApiException catch (e, st) {
      state = state.copyWith(mutation: AsyncValue.error(e, st));
      return null;
    }
  }

  Future<bool> create(CreateStudentParams params) async {
    state = state.copyWith(mutation: const AsyncValue.loading());
    try {
      final created = await _createStudent(params);
      state = state.copyWith(mutation: const AsyncValue.data(null), allStudents: [...state.allStudents, created]);
      return true;
    } catch (e, st) {
      state = state.copyWith(mutation: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> update(UpdateStudentParams params) async {
    state = state.copyWith(mutation: const AsyncValue.loading());
    try {
      final updated = await _updateStudent(params);
      state = state.copyWith(
        mutation: const AsyncValue.data(null),
        allStudents: state.allStudents.map((s) => s.id == updated.id ? updated : s).toList(),
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(mutation: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> delete(String id) async {
    state = state.copyWith(mutation: const AsyncValue.loading());
    try {
      await _deleteStudent(id);
      state = state.copyWith(
        mutation: const AsyncValue.data(null),
        allStudents: state.allStudents.map((s) => s.id == id ? s.copyWith(isActive: false) : s).toList(),
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(mutation: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> permanentDelete(String id) async {
    state = state.copyWith(mutation: const AsyncValue.loading());
    try {
      await _permanentDeleteStudent(id);
      state = state.copyWith(mutation: const AsyncValue.data(null), allStudents: state.allStudents.where((s) => s.id != id).toList());
      return true;
    } catch (e, st) {
      state = state.copyWith(mutation: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> activate(String id) async {
    state = state.copyWith(mutation: const AsyncValue.loading());
    try {
      final updated = await _activateStudent(id);
      state = state.copyWith(
        mutation: const AsyncValue.data(null),
        allStudents: state.allStudents.map((s) => s.id == id ? updated : s).toList(),
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(mutation: AsyncValue.error(e, st));
      return false;
    }
  }
}

final studentsViewModelProvider = NotifierProvider<StudentsNotifier, StudentsState>(StudentsNotifier.new);
