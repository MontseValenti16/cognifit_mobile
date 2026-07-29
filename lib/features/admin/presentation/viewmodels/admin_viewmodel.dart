import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/admin_providers.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/deactivate_user_usecase.dart';
import '../../domain/usecases/get_students_for_picker_usecase.dart';
import '../../domain/usecases/link_parent_usecase.dart';

const _unset = Object();

class AdminState {
  final AsyncValue<void> busy;
  final AsyncValue<void> studentsBusy;
  final List<AdminUserEntity> users;
  final List<Map<String, dynamic>> studentsForPicker;
  final bool includeInactive;
  final String? error;
  final String? successMessage;

  const AdminState({
    this.busy = const AsyncValue.data(null),
    this.studentsBusy = const AsyncValue.data(null),
    this.users = const [],
    this.studentsForPicker = const [],
    this.includeInactive = false,
    this.error,
    this.successMessage,
  });

  bool get isLoading => busy.isLoading;
  bool get isLoadingStudents => studentsBusy.isLoading;

  AdminState copyWith({
    AsyncValue<void>? busy,
    AsyncValue<void>? studentsBusy,
    List<AdminUserEntity>? users,
    List<Map<String, dynamic>>? studentsForPicker,
    bool? includeInactive,
    Object? error = _unset,
    Object? successMessage = _unset,
  }) {
    return AdminState(
      busy: busy ?? this.busy,
      studentsBusy: studentsBusy ?? this.studentsBusy,
      users: users ?? this.users,
      studentsForPicker: studentsForPicker ?? this.studentsForPicker,
      includeInactive: includeInactive ?? this.includeInactive,
      error: identical(error, _unset) ? this.error : error as String?,
      successMessage: identical(successMessage, _unset) ? this.successMessage : successMessage as String?,
    );
  }
}

class AdminNotifier extends Notifier<AdminState> {
  late GetUsersUseCase _getUsers;
  late CreateUserUseCase _createUser;
  late UpdateUserUseCase _updateUser;
  late DeactivateUserUseCase _deactivateUser;
  late GetStudentsForPickerUseCase _getStudentsForPicker;
  late LinkParentUseCase _linkParent;

  @override
  AdminState build() {
    final repo = ref.watch(adminRepositoryProvider);
    _getUsers = GetUsersUseCase(repo);
    _createUser = CreateUserUseCase(repo);
    _updateUser = UpdateUserUseCase(repo);
    _deactivateUser = DeactivateUserUseCase(repo);
    _getStudentsForPicker = GetStudentsForPickerUseCase(repo);
    _linkParent = LinkParentUseCase(repo);
    return const AdminState();
  }

  Future<void> load() async {
    state = state.copyWith(busy: const AsyncValue.loading(), error: null);
    try {
      final users = await _getUsers(includeInactive: state.includeInactive);
      state = state.copyWith(busy: const AsyncValue.data(null), users: users);
    } catch (e, st) {
      state = state.copyWith(busy: AsyncValue.error(e, st), error: 'No se pudo cargar la lista de usuarios');
    }
  }

  void toggleInactive() {
    state = state.copyWith(includeInactive: !state.includeInactive);
    load();
  }

  Future<bool> createUser(CreateUserParams params) async {
    state = state.copyWith(busy: const AsyncValue.loading(), error: null, successMessage: null);
    try {
      final created = await _createUser(params);
      state = state.copyWith(
        busy: const AsyncValue.data(null),
        users: [created, ...state.users],
        successMessage: 'Usuario creado: ${created.email}',
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(
        busy: AsyncValue.error(e, st),
        error: 'No se pudo crear el usuario. Verifica que el correo no esté registrado.',
      );
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    state = state.copyWith(error: null, successMessage: null);
    try {
      final updated = await _updateUser(UpdateUserParams(userId: userId, role: newRole));
      state = state.copyWith(users: _replaceUser(updated), successMessage: 'Rol actualizado');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'No se pudo actualizar el rol');
      return false;
    }
  }

  Future<bool> deactivateUser(String userId) async {
    state = state.copyWith(error: null, successMessage: null);
    try {
      final updated = await _deactivateUser(userId);
      state = state.copyWith(users: _replaceUser(updated), successMessage: 'Usuario desactivado');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'No se pudo desactivar el usuario');
      return false;
    }
  }

  Future<bool> reactivateUser(String userId) async {
    state = state.copyWith(error: null, successMessage: null);
    try {
      final updated = await _updateUser(UpdateUserParams(userId: userId, isActive: true));
      state = state.copyWith(users: _replaceUser(updated), successMessage: 'Usuario reactivado');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'No se pudo reactivar el usuario');
      return false;
    }
  }

  Future<void> loadStudentsForPicker() async {
    state = state.copyWith(studentsBusy: const AsyncValue.loading());
    try {
      final students = await _getStudentsForPicker();
      state = state.copyWith(studentsBusy: const AsyncValue.data(null), studentsForPicker: students);
    } catch (e, st) {
      state = state.copyWith(studentsBusy: AsyncValue.error(e, st), studentsForPicker: const []);
    }
  }

  Future<bool> linkParent(String userId, String studentId) async {
    state = state.copyWith(error: null, successMessage: null);
    try {
      await _linkParent(userId, studentId);
      state = state.copyWith(successMessage: 'Alumno vinculado correctamente');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'No se pudo vincular el alumno');
      return false;
    }
  }

  void clearMessages() => state = state.copyWith(error: null, successMessage: null);

  List<AdminUserEntity> _replaceUser(AdminUserEntity updated) =>
      [for (final u in state.users) u.id == updated.id ? updated : u];
}

final adminViewModelProvider = NotifierProvider<AdminNotifier, AdminState>(AdminNotifier.new);
