import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardViewModel _vm;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.dashboardViewModel;
    _vm.addListener(_rebuild);
    _vm.loadDashboard();
  }

  @override
  void dispose() { _vm.removeListener(_rebuild); super.dispose(); }
  void _rebuild() { if (mounted) setState(() {}); }

  void _onTabTap(int index) {
    if (index == 1) { context.push(AppRouter.students); return; }
    if (index == 2) { context.push(AppRouter.tests); return; }
    setState(() => _tab = index);
  }

  Future<void> _logout() async {
    await ServiceLocator.instance.authViewModel.logout();
    ServiceLocator.instance.resetSessionScopedViewModels();
    if (mounted) context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator.instance.authViewModel.currentUser;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: _vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _vm.loadDashboard,
              color: AppTheme.primary,
              child: CustomScrollView(slivers: [
                SliverToBoxAdapter(child: _header(context, user?.email ?? '')),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: context.hPad),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    _sectionLabel(context, 'RESUMEN'),
                    const SizedBox(height: 12),
                    Row(children: [
                      StatCard(value: _vm.totalStudents.toString(), label: 'Alumnos', color: AppTheme.primary),
                      const SizedBox(width: 10),
                      StatCard(value: _vm.atRiskCount.toString(), label: 'En riesgo', color: AppTheme.riskRed),
                      const SizedBox(width: 10),
                      StatCard(value: _vm.unreadAlerts.length.toString(), label: 'Alertas', color: AppTheme.tertiary, onTap: () => context.push(AppRouter.alerts)),
                    ]),
                    const SizedBox(height: 12),
                    _CalendarioBanner(onTap: () => context.push(AppRouter.calendario)),
                    const SizedBox(height: 16),
                    if (_vm.topAlert != null)
                      AlertBanner(
                        message: _vm.topAlert!.message,
                        onTap: () => context.push('/student/${_vm.topAlert!.studentId}', extra: {'name': 'Alumno'}),
                      ),
                    const SizedBox(height: 24),
                    if (_vm.groupSummaries.isNotEmpty) ...[
                      _sectionLabel(context, 'GRUPOS'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 148,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _vm.groupSummaries.length,
                          itemBuilder: (_, i) => GroupRiskSummaryCard(
                            summary: _vm.groupSummaries[i],
                            onTap: () => context.push(
                              AppRouter.students,
                              extra: {'groupId': _vm.groupSummaries[i].groupId},
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (user?.role == UserRole.admin) ...[
                      _sectionLabel(context, 'ADMINISTRACIÓN'),
                      const SizedBox(height: 10),
                      _AdminBanner(onTap: () => context.push(AppRouter.adminUsers)),
                      const SizedBox(height: 24),
                    ],
                    if (user?.role == UserRole.specialist || user?.role == UserRole.admin) ...[
                      _sectionLabel(context, 'REVISIÓN CLÍNICA'),
                      const SizedBox(height: 10),
                      _SpecialistBanner(onTap: () => context.push(AppRouter.specialistReview)),
                      const SizedBox(height: 24),
                    ],
                    if (_vm.pendingAssignments.isNotEmpty) ...[
                      _sectionLabel(context, 'TESTS PENDIENTES'),
                      const SizedBox(height: 10),
                      ..._vm.pendingAssignments.map((a) => _AssignmentTile(
                        studentName: a.studentName,
                        moduleName: a.moduleName,
                        status: a.status,
                        isCompleted: false,
                        onTap: () => context.push('/student/${a.studentId}', extra: {'name': a.studentName}),
                      )),
                      const SizedBox(height: 24),
                    ],
                    if (_vm.recentCompleted.isNotEmpty) ...[
                      _sectionLabel(context, 'TESTS COMPLETADOS RECIENTES'),
                      const SizedBox(height: 10),
                      ..._vm.recentCompleted.map((a) => _AssignmentTile(
                        studentName: a.studentName,
                        moduleName: a.moduleName,
                        status: a.status,
                        isCompleted: true,
                        onTap: () => context.push('/student/${a.studentId}', extra: {'name': a.studentName}),
                      )),
                      const SizedBox(height: 24),
                    ],
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      _sectionLabel(context, 'ALUMNOS'),
                      TextButton(
                        onPressed: () => context.push(AppRouter.students),
                        child: Text('Ver todos', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    if (_vm.recentStudents.isEmpty)
                      Padding(padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Aún no hay alumnos registrados', style: Theme.of(context).textTheme.bodyMedium)))
                    else
                      ..._vm.recentStudents.map((s) => DashboardStudentTile(
                        student: s, atRisk: _vm.isStudentAtRisk(s.id),
                        onTap: () => context.push('/student/${s.id}', extra: {'name': s.fullName}),
                      )),
                    const SizedBox(height: 100),
                  ])),
                ),
              ]),
            ),
      ),
      bottomNavigationBar: _BottomNav(selected: _tab, onTap: _onTabTap),
    );
  }

  Widget _header(BuildContext context, String email) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.hPad, 16, context.hPad, 0),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppTheme.primaryContainer, shape: BoxShape.circle),
          child: const Icon(Icons.person_rounded, color: AppTheme.primary)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(email.isNotEmpty ? email.split('@').first : 'Docente', style: Theme.of(context).textTheme.titleLarge),
          Text('Panel de control', style: Theme.of(context).textTheme.bodyMedium),
        ])),
        IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout, color: AppTheme.onSurface),
      ]),
    );
  }

  Widget _sectionLabel(BuildContext ctx, String text) =>
    Text(text, style: Theme.of(ctx).textTheme.labelMedium?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700, color: const Color(0xFF9E9CAD)));
}

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppTheme.outline.withOpacity(0.4))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, -4))]),
      child: BottomNavigationBar(
        currentIndex: selected, onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group_rounded), label: 'Alumnos'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment_rounded), label: 'Tests'),
        ],
      ),
    );
  }
}

class _SpecialistBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SpecialistBanner({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withValues(alpha: 0.08), AppTheme.tertiary.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primaryContainer, shape: BoxShape.circle),
          child: const Icon(Icons.rate_review_rounded, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Diagnósticos pendientes de revisión',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Confirma o corrige los resultados del modelo ML',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD))),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppTheme.primary),
      ]),
    ),
  );
}

class _AdminBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AdminBanner({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C3AED).withValues(alpha: 0.08), AppTheme.primary.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.12), shape: BoxShape.circle),
          child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFF7C3AED), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gestión de usuarios',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Crear, editar y desactivar cuentas por rol',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD))),
        ])),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C3AED)),
      ]),
    ),
  );
}

class _CalendarioBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CalendarioBanner({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: const Icon(Icons.event_available_rounded, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Qué evaluar y cuándo',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('El calendario de tamizaje de tus alumnos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD))),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppTheme.primary),
      ]),
    ),
  );
}

class _AssignmentTile extends StatelessWidget {
  final String studentName;
  final String moduleName;
  final String status;
  final bool isCompleted;
  final VoidCallback onTap;

  const _AssignmentTile({
    required this.studentName,
    required this.moduleName,
    required this.status,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppTheme.activeGreen : AppTheme.pendingOrange;
    final icon = isCompleted ? Icons.check_circle_outline_rounded : Icons.schedule_rounded;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(studentName, style: Theme.of(context).textTheme.titleSmall),
            Text(moduleName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(
              isCompleted ? 'Completado' : (status == 'IN_PROGRESS' ? 'En curso' : 'Pendiente'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
      ),
    );
  }
}
