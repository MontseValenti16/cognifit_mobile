import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/circuit_background.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checkedSession = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final vm = ServiceLocator.instance.authViewModel;
    final restored = await vm.tryRestoreSession();
    if (!mounted) return;
    if (restored) {
      _navigateByRole(vm);
    } else {
      setState(() => _checkedSession = true);
    }
  }

  void _navigateByRole(AuthViewModel vm) {
    final role = vm.currentUser?.role;
    final linkedId = vm.linkedStudentId;
    final linkedName = vm.linkedStudentName ?? 'Alumno';

    if (role == UserRole.student) {
      vm.logout();
      setState(() => _checkedSession = true);
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
    if (!_checkedSession) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          const CircuitBackground(),
          SafeArea(
            child: SizedBox(
              height: screenHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── Parte superior: logo + título + ilustración ──
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        _BrainLogo(),
                        const SizedBox(height: 10),
                        Text(
                          'CogniFit',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tecnología y seguimiento para dislexia',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF6B6880),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _SplashIllustration(),
                      ],
                    ),

                    // ── Parte inferior: botón ──
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRouter.login),
                        child: const Text('Iniciar sesión'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrainLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/imagenCognifit.jpeg',
      width: 80,
      height: 80,
      fit: BoxFit.contain,
    );
  }
}

class _SplashIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Toma el 40% de la altura de la pantalla para que siempre quepa
    final height = MediaQuery.of(context).size.height * 0.40;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        'assets/images/foto.png',
        width: double.infinity,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}