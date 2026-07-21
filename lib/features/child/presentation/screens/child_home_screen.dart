import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/child_game_widgets.dart';
import 'child_games_catalog_screen.dart';

/// Pantalla de inicio gamificada para el niño.
/// El docente pulsa "Modo niño" en el perfil del alumno y esta pantalla aparece.
/// Muestra el saludo y las tarjetas de actividad.
///
/// No lleva barra de XP, nivel ni medallas: existían escritas a mano —"Nivel
/// 3", 72/100 XP, logros con `unlocked` fijo— y nunca cambiaban con lo que el
/// alumno hacía. Una recompensa que miente es peor que ninguna, sobre todo con
/// niños que están trabajando una dificultad.
class ChildHomeScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  final String? pendingSessionId;      // sesión de diagnóstico pendiente (puede ser null)
  final String? pendingModuleTitle;

  const ChildHomeScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    this.pendingSessionId,
    this.pendingModuleTitle,
  });

  String get _firstName => studentName.split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(child: CustomScrollView(slivers: [
        // ── Header con saludo ──
        SliverToBoxAdapter(child: _GreetingHeader(firstName: _firstName)),
        // ── Tarjetas de actividad ──
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Text('¿Qué quieres hacer hoy?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            if (pendingSessionId != null)
              _ActivityCard(
                emoji: '📝',
                title: 'El test de hoy',
                subtitle: pendingModuleTitle ?? 'Continúa tu evaluación',
                color: AppTheme.primary,
                onTap: () => context.push(
                  '/exercise-session/$pendingSessionId',
                  extra: {'moduleTitle': pendingModuleTitle ?? 'Módulo'},
                ),
              ),
            if (pendingSessionId != null) const SizedBox(height: 14),
            _ActivityCard(
              emoji: '🔎',
              title: 'Mis juegos',
              subtitle: 'Cuadrículas · b/d · p/q · sílabas · palabras',
              color: AppTheme.tertiary,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ChildGamesCatalogScreen(studentName: studentName),
              )),
            ),
            const SizedBox(height: 28),
          ]),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ])),
    );
  }
}

// ─── Subwidgets privados ─────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String firstName;
  const _GreetingHeader({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF7C5CBF), Color(0xFF5BC8AF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('⭐ ¡Hola, $firstName!',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
          const SizedBox(height: 6),
          const Text('¡Lo estás haciendo genial!\nSigue así, campeón.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4)),
        ])),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(child: Text('🧠', style: TextStyle(fontSize: 36))),
        ),
      ]),
    );
  }
}


class _ActivityCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.emoji, required this.title, required this.subtitle,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD), fontSize: 12)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
        ]),
      ),
    );
  }
}

