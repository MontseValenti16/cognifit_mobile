import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../students/domain/usecases/get_linked_student_usecase.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final GetMeUseCase _getMe;
  final RegisterUseCase _register;
  final TokenStorage _tokenStorage;
  final GetLinkedStudentUseCase _getLinkedStudent;

  AuthViewModel({
    required LoginUseCase login,
    required LogoutUseCase logout,
    required GetMeUseCase getMe,
    required RegisterUseCase register,
    required TokenStorage tokenStorage,
    required GetLinkedStudentUseCase getLinkedStudent,
  })  : _login = login, _logout = logout, _getMe = getMe, _register = register,
        _tokenStorage = tokenStorage, _getLinkedStudent = getLinkedStudent;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  String? _errorField;
  bool _obscurePassword = true;
  UserEntity? currentUser;
  String? linkedStudentId;
  String? linkedStudentName;

  String name = '';
  String email = '';
  String password = '';

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get errorField => _errorField;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _status == AuthStatus.loading;

  void togglePasswordVisibility() { _obscurePassword = !_obscurePassword; notifyListeners(); }
  void setName(String v) => name = v;
  void setEmail(String v) => email = v;
  void setPassword(String v) => password = v;

  Future<void> _fetchLinkedStudent() async {
    linkedStudentId = null;
    linkedStudentName = null;
    final result = await _getLinkedStudent();
    linkedStudentId = result?.id;
    linkedStudentName = result?.fullName;
  }

  Future<void> login() async {
    if (email.isEmpty || password.isEmpty) { _setError('Por favor completa todos los campos.'); return; }
    _setLoading();
    try {
      await _login(email, password, deviceInfo: 'Flutter App');
      currentUser = await _getMe();
      final role = currentUser?.role;
      if (role == UserRole.student || role == UserRole.parent) {
        await _fetchLinkedStudent();
      }
      _status = AuthStatus.success;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.userMessage, field: e.fieldError);
    } catch (e) {
      _setError('No se pudo iniciar sesión. Intenta de nuevo.');
    }
  }

  Future<void> register() async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) { _setError('Por favor completa todos los campos.'); return; }
    _setLoading();
    try {
      await _register(name, email, password);
      currentUser = await _getMe();
      _status = AuthStatus.success;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.userMessage, field: e.fieldError);
    } catch (e) {
      _setError('No se pudo registrar. Intenta de nuevo.');
    }
  }

  Future<bool> tryRestoreSession() async {
    if (!await _tokenStorage.hasSession) return false;
    try {
      currentUser = await _getMe();
      final role = currentUser?.role;
      if (role == UserRole.student || role == UserRole.parent) {
        await _fetchLinkedStudent();
      }
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }

  Future<void> logout() async {
    await _logout();
    currentUser = null;
    linkedStudentId = null;
    linkedStudentName = null;
    reset();
  }

  void _setLoading() { _status = AuthStatus.loading; _errorMessage = null; _errorField = null; notifyListeners(); }
  void _setError(String msg, {String? field}) { _errorMessage = msg; _errorField = field; _status = AuthStatus.error; notifyListeners(); }

  void reset() { _status = AuthStatus.idle; _errorMessage = null; _errorField = null; name = ''; email = ''; password = ''; notifyListeners(); }
}
