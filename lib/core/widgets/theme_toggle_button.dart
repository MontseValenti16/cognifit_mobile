import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// Interruptor sol/luna para cambiar entre modo claro y oscuro: se piden
/// ambos íconos visibles a la vez (no un solo ícono que alterna), con el
/// modo activo resaltado. Se escucha a sí mismo (ListenableBuilder sobre
/// ThemeController) para poder colocarse en cualquier AppBar/header sin que
/// esa pantalla sepa nada de temas.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDark;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppTheme.outline.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _ModeButton(
              icon: Icons.light_mode_rounded,
              selected: !isDark,
              onTap: () { if (isDark) ThemeController.instance.toggle(); },
              tooltip: 'Modo claro',
            ),
            _ModeButton(
              icon: Icons.dark_mode_rounded,
              selected: isDark,
              onTap: () { if (!isDark) ThemeController.instance.toggle(); },
              tooltip: 'Modo oscuro',
            ),
          ]),
        );
      },
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;
  const _ModeButton({required this.icon, required this.selected, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 18, color: selected ? Colors.white : AppTheme.mutedText),
        ),
      ),
    );
  }
}
