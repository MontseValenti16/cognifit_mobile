import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../splash/presentation/widgets/circuit_background.dart';
import '../../domain/entities/user_entity.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.authViewModel;
    _vm.addListener(_onChanged);
  }

  @override
  void dispose() { _vm.removeListener(_onChanged); super.dispose(); }

  void _onChanged() {
    if (!mounted) return;
    if (_vm.status == AuthStatus.success) {
      _navigateByRole();
      _vm.reset();
    } else if (_vm.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_vm.errorMessage ?? 'Error'),
        backgroundColor: AppTheme.riskRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
    setState(() {});
  }

  void _navigateByRole() {
    final role = _vm.currentUser?.role;
    final linkedId = _vm.linkedStudentId;
    final linkedName = _vm.linkedStudentName ?? 'Alumno';

    if (role == UserRole.student) {
      // Los alumnos no inician sesión en la app — el docente activa "Modo niño"
      // en su propio dispositivo durante la evaluación.
      _vm.logout();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Los alumnos no necesitan iniciar sesión. Pide a tu docente que abra la evaluación.'),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
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
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(children: [
        const CircuitBackground(),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.hPad),
            child: Column(children: [
              const SizedBox(height: 48),
              const AuthHeader(subtitle: 'Inicia sesión para continuar'),
              const SizedBox(height: 32),

              CogniFitTextField(
                label: 'Correo institucional',
                hint: 'docente@colegio.edu',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                onChanged: _vm.setEmail,
              ),
              const SizedBox(height: 20),

              ListenableBuilder(
                listenable: _vm,
                builder: (_, __) => CogniFitTextField(
                  label: 'Contraseña', hint: '• • • • • • • •', obscureText: _vm.obscurePassword,
                  suffixWidget: GestureDetector(
                    onTap: _vm.togglePasswordVisibility,
                    child: Icon(_vm.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFFADA9B9), size: 20),
                  ),
                  onChanged: _vm.setPassword,
                ),
              ),
              const SizedBox(height: 32),

              ListenableBuilder(
                listenable: _vm,
                builder: (_, __) => ElevatedButton(
                  onPressed: _vm.isLoading ? null : _vm.login,
                  child: _vm.isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Iniciar sesión'),
                ),
              ),
              const SizedBox(height: 16),

              Text('¿Olvidaste tu contraseña? Contacta al administrador del centro.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD))),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ]),
    );
  }
}
