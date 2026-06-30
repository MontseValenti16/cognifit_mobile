import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  final String subtitle;
  const AuthHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9B78D8), Color(0xFF5BC8AF)]),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 42),
      ),
      const SizedBox(height: 16),
      Text('CogniFit', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6880)), textAlign: TextAlign.center),
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

  const CogniFitTextField({
    super.key, required this.label, required this.hint,
    this.prefixIcon, this.suffixWidget, this.obscureText = false,
    this.keyboardType = TextInputType.text, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFFADA9B9), size: 20) : null,
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
        color: AppTheme.outline.withOpacity(0.2),
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
                color: isLogin ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isLogin ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
              ),
              child: Center(
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isLogin ? AppTheme.primary : const Color(0xFF6B6880),
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
                color: !isLogin ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: !isLogin ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
              ),
              child: Center(
                child: Text(
                  'Register',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: !isLogin ? AppTheme.primary : const Color(0xFF6B6880),
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
