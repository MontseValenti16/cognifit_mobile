import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/validation/input_rules.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../splash/presentation/widgets/circuit_background.dart';
import '../../domain/entities/user_entity.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Valida antes de salir a la red. Si algo no cumple, no se gasta la
  /// peticion: el servidor devolveria un 422 con el mismo veredicto, pero
  /// despues de un viaje de ida y vuelta que en una escuela con senal
  /// intermitente puede costar varios segundos o fallar del todo.
  void _enviar() {
    if (_formKey.currentState?.validate() ?? false) ref.read(authViewModelProvider.notifier).login();
  }

  void _navigateByRole(AuthState vm) {
    final role = vm.currentUser?.role;
    final linkedId = vm.linkedStudentId;
    final linkedName = vm.linkedStudentName ?? 'Alumno';

    if (role == UserRole.student) {
      // Los alumnos no inician sesión en la app — el docente activa "Modo niño"
      // en su propio dispositivo durante la evaluación.
      ref.read(authViewModelProvider.notifier).logout();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Los alumnos no necesitan iniciar sesión. Pide a tu docente que abra la evaluación.'),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    if (role == UserRole.superadmin) {
      context.go(AppRouter.superadminInstitutions);
      return;
    }

    if (role == UserRole.parent && linkedId != null) {
      context.go(AppRouter.parentHome, extra: {'studentId': linkedId, 'name': linkedName});
    } else {
      context.go(AppRouter.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(authViewModelProvider);

    // Reemplaza el addListener/removeListener manual: ref.listen reacciona
    // a los cambios de estado (navegar al tener éxito, mostrar el error) sin
    // que la pantalla tenga que suscribirse/desuscribirse a mano.
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      final justSucceeded = (previous?.isLoading ?? false) && !next.isLoading && next.currentUser != null;
      if (justSucceeded) {
        _navigateByRole(next);
        ref.read(authViewModelProvider.notifier).reset();
      } else if (next.submission.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage ?? 'Error'),
          backgroundColor: AppTheme.riskRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(children: [
        const CircuitBackground(),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12, top: 4),
              child: ThemeToggleButton(),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.hPad),
            child: Form(
              key: _formKey,
              child: Column(children: [
              const SizedBox(height: 48),
              const AuthHeader(subtitle: 'Inicia sesión para continuar'),
              const SizedBox(height: 32),
              Image.asset(
    'assets/images/foto.png',
    height: 100, // Ajusta la altura según lo que necesites
    fit: BoxFit.contain,
  ),

              CogniFitTextField(
                label: 'Correo institucional',
                hint: 'docente@colegio.edu',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                onChanged: ref.read(authViewModelProvider.notifier).setEmail,
                validator: Validators.correo,
              ),
              const SizedBox(height: 20),

              CogniFitTextField(
                label: 'Contraseña', hint: '• • • • • • • •', obscureText: vm.obscurePassword,
                suffixWidget: GestureDetector(
                  onTap: ref.read(authViewModelProvider.notifier).togglePasswordVisibility,
                  child: Icon(vm.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.mutedText, size: 20),
                ),
                onChanged: ref.read(authViewModelProvider.notifier).setPassword,
                // Solo "no vacia": LoginRequest.password no declara minimo,
                // y exigir 12 aqui dejaria fuera a las cuentas creadas con
                // la regla de 8 del registro de institucion.
                validator: Validators.passwordAcceso,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: vm.isLoading ? null : _enviar,
                child: vm.isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 16),

              Text('¿Olvidaste tu contraseña? Contacta al administrador del centro.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText)),
              const SizedBox(height: 12),

              Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text('¿Tu institución no está registrada? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText)),
                GestureDetector(
                  onTap: () => context.push(AppRouter.registerInstitution),
                  child: Text('Regístrala aquí',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ),
              ]),

              const SizedBox(height: 40),
            ]),
            ),
          ),
        ),
      ]),
    );
  }
}
