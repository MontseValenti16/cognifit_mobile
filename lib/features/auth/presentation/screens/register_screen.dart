import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../splash/presentation/widgets/circuit_background.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    if (_vm.status == AuthStatus.success) { context.go(AppRouter.dashboard); _vm.reset(); }
    else if (_vm.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_vm.errorMessage ?? 'Error'),
        backgroundColor: AppTheme.riskRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(children: [
        const CircuitBackground(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const SizedBox(height: 36),
              const AuthHeader(subtitle: 'Crea una cuenta para comenzar'),
              const SizedBox(height: 28),
              AuthTabToggle(isLogin: false, onLoginTap: () => context.pop(), onRegisterTap: () {}),
              const SizedBox(height: 28),
              CogniFitTextField(label: 'Name', hint: 'Enter your name', prefixIcon: Icons.person_outline_rounded, onChanged: _vm.setName),
              const SizedBox(height: 20),
              CogniFitTextField(label: 'Email', hint: 'Enter your email', prefixIcon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, onChanged: _vm.setEmail),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: _vm,
                builder: (_, __) => CogniFitTextField(
                  label: 'Password', hint: '• • • • • • • •', obscureText: _vm.obscurePassword,
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
                  onPressed: _vm.isLoading ? null : _vm.register,
                  child: _vm.isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Create account'),
                ),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('¿Ya tienes cuenta? ', style: Theme.of(context).textTheme.bodyMedium),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text('Inicia sesión', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ]),
    );
  }
}
