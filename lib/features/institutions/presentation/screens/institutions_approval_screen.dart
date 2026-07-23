import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../domain/entities/institution_entity.dart';
import '../viewmodels/institution_viewmodel.dart';

class InstitutionsApprovalScreen extends StatefulWidget {
  const InstitutionsApprovalScreen({super.key});
  @override
  State<InstitutionsApprovalScreen> createState() => _InstitutionsApprovalScreenState();
}

class _InstitutionsApprovalScreenState extends State<InstitutionsApprovalScreen> {
  late final InstitutionViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.institutionViewModel;
    _vm.addListener(_rebuild);
    _vm.loadPending();
  }

  @override
  void dispose() {
    _vm.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (!mounted) return;
    if (_vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_vm.error!),
        backgroundColor: AppTheme.riskRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
    setState(() {});
  }

  Future<void> _logout() async {
    await ServiceLocator.instance.authViewModel.logout();
    ServiceLocator.instance.resetSessionScopedViewModels();
    if (mounted) context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Instituciones pendientes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _vm.loadPending),
          IconButton(icon: const Icon(Icons.logout_rounded), tooltip: 'Cerrar sesión', onPressed: _logout),
          const ThemeToggleButton(),
        ],
      ),
      body: _vm.isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _vm.pending.isEmpty
              ? const _EmptyView()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: _vm.pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _InstitutionCard(institution: _vm.pending[i], vm: _vm),
                ),
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  final InstitutionEntity institution;
  final InstitutionViewModel vm;
  const _InstitutionCard({required this.institution, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(institution.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        if (institution.cct != null) Text('CCT: ${institution.cct}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          [institution.municipality, institution.state].where((s) => s != null && s.isNotEmpty).join(', '),
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _confirmReject(context),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.riskRed),
              child: const Text('Rechazar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => vm.approveInstitution(institution.id),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.activeGreen),
              child: const Text('Aprobar'),
            ),
          ),
        ]),
      ]),
    );
  }

  void _confirmReject(BuildContext context) {
    final motivoCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Rechazar ${institution.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('La solicitud saldrá de pendientes y se avisará por correo a quien la hizo.'),
            const SizedBox(height: 12),
            TextField(
              controller: motivoCtrl,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                helperText: 'Se incluye en el correo al solicitante.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.riskRed),
            onPressed: () {
              final motivo = motivoCtrl.text.trim();
              Navigator.pop(dialogCtx);
              vm.rejectInstitution(institution.id, reason: motivo.isEmpty ? null : motivo);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('No hay instituciones pendientes', style: TextStyle(color: Colors.grey, fontSize: 16)),
      ]),
    );
  }
}
