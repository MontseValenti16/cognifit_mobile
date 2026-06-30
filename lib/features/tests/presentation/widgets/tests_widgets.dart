import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/test_entity.dart';

// ── Difficulty badge ──────────────────────────────────────────────────────────
class DifficultyBadge extends StatelessWidget {
  final TestDifficulty difficulty;
  const DifficultyBadge({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      TestDifficulty.basic    => ('Básico',    AppTheme.activeGreen),
      TestDifficulty.mild     => ('Leve',      AppTheme.tertiary),
      TestDifficulty.moderate => ('Moderado',  AppTheme.pendingOrange),
      TestDifficulty.severe   => ('Severo',    AppTheme.riskRed),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ── Test category icon ────────────────────────────────────────────────────────
IconData _categoryIcon(TestCategory cat) => switch (cat) {
  TestCategory.screening   => Icons.checklist_rounded,
  TestCategory.phonological => Icons.record_voice_over_rounded,
  TestCategory.visual      => Icons.visibility_rounded,
  TestCategory.cognitive   => Icons.psychology_rounded,
};

// ── Single test tile ──────────────────────────────────────────────────────────
class TestTile extends StatelessWidget {
  final TestEntity test;
  final VoidCallback onTap;
  const TestTile({super.key, required this.test, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outline.withOpacity(0.5)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(_categoryIcon(test.category), color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(test.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            DifficultyBadge(difficulty: test.difficulty),
          ])),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
        ]),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class TestSectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const TestSectionHeader({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700, color: const Color(0xFF9E9CAD)))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
          child: Text('$count', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
class TestSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const TestSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por habilidad...',
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFADA9B9), size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      ),
    );
  }
}
