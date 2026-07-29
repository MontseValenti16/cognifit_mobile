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

  void _enviar() {
    if (_formKey.currentState?.validate() ?? false) ref.read(authViewModelProvider.notifier).login();
  }

  void _navigateByRole(AuthState vm) {
    final role = vm.currentUser?.role;
    final linkedId = vm.linkedStudentId;
    final linkedName = vm.linkedStudentName ?? 'Alumno';

    if (role == UserRole.student) {
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
    height: 100,
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
