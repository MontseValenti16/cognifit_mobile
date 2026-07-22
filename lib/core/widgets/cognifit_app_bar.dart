import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'theme_toggle_button.dart';

/// Shared AppBar used across all teacher screens.
class CogniFitAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;

  const CogniFitAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: subtitle != null
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ])
          : Text(title, style: Theme.of(context).textTheme.titleLarge),
      actions: [...?actions, const ThemeToggleButton()],
    );
  }
}
