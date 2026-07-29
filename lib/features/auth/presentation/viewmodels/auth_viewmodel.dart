import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../students/domain/usecases/get_linked_student_usecase.dart';
import '../../di/auth_providers.dart';
import '../../../../core/di/core_providers.dart';
import '../../../students/di/students_providers.dart';

/// Estado inmutable de auth. `submission` es un [AsyncValue] que representa
/// únicamente la operación de login/registro/restauración en curso — no la
/// sesión en sí. `currentUser` vive aparte porque debe sobrevivir a un
/// `reset()` del formulario (el usuario sigue autenticado tras navegar).
class AuthState {
  final AsyncValue<void> submission;
  final UserEntity? currentUser;
  final String? linkedStudentId;
  final String? linkedStudentName;
  final bool obscurePassword;
  final String name;
  final String email;
  final String password;

  const AuthState({
    this.submission = const AsyncValue.data(null),
    this.currentUser,
    this.linkedStudentId,
    this.linkedStudentName,
    this.obscurePassword = true,
    this.name = '',
    this.email = '',
    this.password = '',
  });

  bool get isLoading => submission.isLoading;

  String? get errorMessage {
    final err = submission.error;
    if (err == null) return null;
    return err is ApiException ? err.userMessage : 'Ocurrió un error. Intenta de nuevo.';
  }

  String? get errorField {
    final err = submission.error;
    return err is ApiException ? err.fieldError : null;
  }

  AuthState copyWith({
    AsyncValue<void>? submission,
    UserEntity? currentUser,
    String? linkedStudentId,
    String? linkedStudentName,
    bool? obscurePassword,
    String? name,
    String? email,
    String? password,
  }) {
    return AuthState(
      submission: submission ?? this.submission,
      currentUser: currentUser ?? this.currentUser,
      linkedStudentId: linkedStudentId ?? this.linkedStudentId,
      linkedStudentName: linkedStudentName ?? this.linkedStudentName,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late LoginUseCase _login;
  late LogoutUseCase _logout;
  late GetMeUseCase _getMe;
  late RegisterUseCase _register;
  late GetLinkedStudentUseCase _getLinkedStudent;
  late TokenStorage _tokenStorage;

  @override
  AuthState build() {
    final repo = ref.watch(authRepositoryProvider);
    _login = LoginUseCase(repo);
    _logout = LogoutUseCase(repo);
    _getMe = GetMeUseCase(repo);
    _register = RegisterUseCase(repo);
    _tokenStorage = ref.watch(tokenStorageProvider);
    _getLinkedStudent = GetLinkedStudentUseCase(ref.watch(studentRepositoryProvider));
    return const AuthState();
  }

  void togglePasswordVisibility() => state = state.copyWith(obscurePassword: !state.obscurePassword);
  void setName(String v) => state = state.copyWith(name: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);

  Future<void> _fetchLinkedStudent() async {
    final result = await _getLinkedStudent();
    state = state.copyWith(linkedStudentId: result?.id, linkedStudentName: result?.fullName);
  }

  Future<void> login() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(submission: AsyncValue.error('Por favor completa todos los campos.', StackTrace.current));
      return;
    }
    state = state.copyWith(submission: const AsyncValue.loading());
    state = state.copyWith(
      submission: await AsyncValue.guard(() async {
        await _login(state.email, state.password, deviceInfo: 'Flutter App');
        final user = await _getMe();
        state = state.copyWith(currentUser: user);
        if (user.role == UserRole.student || user.role == UserRole.parent) {
          await _fetchLinkedStudent();
        }
      }),
    );
  }

  Future<void> register() async {
    if (state.name.isEmpty || state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(submission: AsyncValue.error('Por favor completa todos los campos.', StackTrace.current));
      return;
    }
    state = state.copyWith(submission: const AsyncValue.loading());
    state = state.copyWith(
      submission: await AsyncValue.guard(() async {
        await _register(state.name, state.email, state.password);
        final user = await _getMe();
        state = state.copyWith(currentUser: user);
      }),
    );
  }

  Future<bool> tryRestoreSession() async {
    if (!await _tokenStorage.hasSession) return false;
    try {
      final user = await _getMe();
      state = state.copyWith(currentUser: user);
      if (user.role == UserRole.student || user.role == UserRole.parent) {
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
    state = const AuthState();
  }

  /// Limpia el formulario y el resultado de la última operación tras
  /// consumirla (p. ej. después de navegar en un login exitoso), sin tocar
  /// `currentUser` — la sesión sigue activa.
  void reset() {
    state = state.copyWith(submission: const AsyncValue.data(null), name: '', email: '', password: '');
  }
}

final authViewModelProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
