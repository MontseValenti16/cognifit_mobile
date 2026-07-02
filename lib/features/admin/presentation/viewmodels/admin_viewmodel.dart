import 'package:flutter/foundation.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/deactivate_user_usecase.dart';

class AdminViewModel extends ChangeNotifier {
  final GetUsersUseCase _getUsers;
  final CreateUserUseCase _createUser;
  final UpdateUserUseCase _updateUser;
  final DeactivateUserUseCase _deactivateUser;

  AdminViewModel({
    required GetUsersUseCase getUsers,
    required CreateUserUseCase createUser,
    required UpdateUserUseCase updateUser,
    required DeactivateUserUseCase deactivateUser,
  })  : _getUsers = getUsers,
        _createUser = createUser,
        _updateUser = updateUser,
        _deactivateUser = deactivateUser;

  List<AdminUserEntity> _users = [];
  bool _includeInactive = false;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  List<AdminUserEntity> get users => _users;
  bool get includeInactive => _includeInactive;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _getUsers(includeInactive: _includeInactive);
    } catch (e) {
      _error = 'No se pudo cargar la lista de usuarios';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleInactive() {
    _includeInactive = !_includeInactive;
    load();
  }

  Future<bool> createUser(CreateUserParams params) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      final created = await _createUser(params);
      _users = [created, ..._users];
      _successMessage = 'Usuario creado: ${created.email}';
      return true;
    } catch (e) {
      _error = 'No se pudo crear el usuario. Verifica que el correo no esté registrado.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    _error = null;
    _successMessage = null;
    try {
      final updated = await _updateUser(UpdateUserParams(userId: userId, role: newRole));
      _replaceUser(updated);
      _successMessage = 'Rol actualizado';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'No se pudo actualizar el rol';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateUser(String userId) async {
    _error = null;
    _successMessage = null;
    try {
      final updated = await _deactivateUser(userId);
      _replaceUser(updated);
      _successMessage = 'Usuario desactivado';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'No se pudo desactivar el usuario';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reactivateUser(String userId) async {
    _error = null;
    _successMessage = null;
    try {
      final updated = await _updateUser(UpdateUserParams(userId: userId, isActive: true));
      _replaceUser(updated);
      _successMessage = 'Usuario reactivado';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'No se pudo reactivar el usuario';
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
  }

  void _replaceUser(AdminUserEntity updated) {
    _users = [for (final u in _users) u.id == updated.id ? updated : u];
  }
}
