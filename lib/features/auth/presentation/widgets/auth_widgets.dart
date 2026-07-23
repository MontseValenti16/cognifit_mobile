import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  final String subtitle;
  const AuthHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Image.asset(
        'assets/images/imagenCognifit.jpeg',
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      ),
      const SizedBox(height: 16),
      Text(
        'CogniFit',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText),
        textAlign: TextAlign.center,
      ),
    ]);
  }
}

class CogniFitTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  /// Validador del cliente. Espeja las reglas que el servidor ya impone con
  /// Pydantic — ver `core/validation/input_rules.dart`. No las reemplaza: el
  /// servidor sigue validando todo, porque quien ataca controla el cliente.
  final String? Function(String?)? validator;

  const CogniFitTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        // Se revalida mientras el usuario corrige: si el mensaje solo
        // apareciera al enviar, el alumno o el docente vuelven a tocar el
        // boton para saber si ya quedo bien.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppTheme.mutedText, size: 20)
              : null,
          suffix: suffixWidget,
        ),
      ),
    ]);
  }
}

class AuthTabToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const AuthTabToggle({
    super.key,
    required this.isLogin,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: onLoginTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isLogin ? AppTheme.cardColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isLogin
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                    : [],
              ),
              child: Center(
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isLogin ? AppTheme.primary : AppTheme.mutedText,
                    fontWeight: isLogin ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTap: onRegisterTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !isLogin ? AppTheme.cardColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: !isLogin
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                    : [],
              ),
              child: Center(
                child: Text(
                  'Register',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: !isLogin ? AppTheme.primary : AppTheme.mutedText,
                    fontWeight: !isLogin ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}