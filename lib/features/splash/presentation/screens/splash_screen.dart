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
      // Cuenta de alumno — no se usa en la app; el docente activa "Modo niño".
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
      return const Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          const CircuitBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _BrainLogo(),
                  const SizedBox(height: 24),
                  Text('CogniFit', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Tecnología y seguimiento para dislexia',
                    style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF6B6880)),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  _SplashIllustration(),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => context.push(AppRouter.login),
                    child: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 40),
                ],
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
    return Container(
      width: 90, height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF9B78D8), Color(0xFF5BC8AF)],
        ),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha:0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 48),
    );
  }
}

class _SplashIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 220,
      decoration: BoxDecoration(color: const Color(0xFFE8F8F2), borderRadius: BorderRadius.circular(32)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _Letter('A', const Offset(40, 40), AppTheme.riskRed, 28),
          _Letter('B', const Offset(85, 18), AppTheme.warning, 24),
          _Letter('C', const Offset(132, 34), AppTheme.tertiary, 26),
          _Letter('D', const Offset(172, 16), AppTheme.primary, 24),
          _Letter('E', const Offset(60, 82), AppTheme.activeGreen, 22),
          _Letter('F', const Offset(116, 76), AppTheme.secondary, 22),
          Positioned(
            left: 24, bottom: 16,
            child: Container(
              width: 64, height: 80,
              decoration: BoxDecoration(color: const Color(0xFFFFD54F).withValues(alpha:0.3), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.child_care_rounded, color: Color(0xFFFFD54F), size: 36),
            ),
          ),
          Positioned(
            right: 24, bottom: 16,
            child: Container(
              width: 64, height: 80,
              decoration: BoxDecoration(color: const Color(0xFF80DEEA).withValues(alpha:0.3), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.face_rounded, color: Color(0xFF80DEEA), size: 36),
            ),
          ),
          Positioned(top: 28, right: 52, child: Icon(Icons.star_rounded, color: AppTheme.warning.withValues(alpha:0.6), size: 16)),
          Positioned(top: 60, left: 22, child: Icon(Icons.star_rounded, color: AppTheme.primary.withValues(alpha:0.4), size: 12)),
        ],
      ),
    );
  }
}

class _Letter extends StatelessWidget {
  final String letter;
  final Offset pos;
  final Color color;
  final double size;
  const _Letter(this.letter, this.pos, this.color, this.size);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: pos.dx, top: pos.dy,
      child: Text(letter, style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, color: color,
        shadows: [Shadow(color: color.withValues(alpha:0.3), blurRadius: 4, offset: const Offset(1, 2))])),
    );
  }
}
