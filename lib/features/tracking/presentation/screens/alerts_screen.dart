import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../domain/entities/tracking_entity.dart';
import '../viewmodels/tracking_viewmodel.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late final TrackingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.trackingViewModel;
    _vm.addListener(_rebuild);
    _vm.loadAlerts();
  }

  @override
  void dispose() {
    _vm.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  Future<void> _onTapAlert(AlertEntity alert) async {
    if (!alert.isRead) await _vm.markRead(alert.id);
    if (!mounted) return;
    context.push('/student/${alert.studentId}', extra: {'name': 'Alumno'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alertas', style: Theme.of(context).textTheme.titleLarge),
          if (_vm.unreadAlerts.isNotEmpty)
            Text('${_vm.unreadAlerts.length} sin leer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.warning)),
        ]),
        actions: const [ThemeToggleButton()],
      ),
      body: _vm.isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _vm.loadAlerts,
              color: AppTheme.primary,
              child: _vm.alerts.isEmpty
                  ? _EmptyAlerts()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _vm.alerts.length,
                      itemBuilder: (_, i) => _AlertTile(
                        alert: _vm.alerts[i],
                        onTap: () => _onTapAlert(_vm.alerts[i]),
                      ),
                    ),
            ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.check_circle_outline_rounded, size: 56, color: AppTheme.activeGreen.withValues(alpha: 0.6)),
      const SizedBox(height: 12),
      Text('Sin alertas nuevas', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF9E9CAD))),
      const SizedBox(height: 6),
      Text('Los alumnos están progresando sin estancamientos.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFFADA9B9))),
    ]),
  ));
}

class _AlertTile extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback onTap;
  const _AlertTile({required this.alert, required this.onTap});

  Color get _urgencyColor => switch (alert.urgency) {
    'HIGH'   => AppTheme.riskRed,
    'MEDIUM' => AppTheme.pendingOrange,
    _        => AppTheme.activeGreen,
  };

  String get _urgencyLabel => switch (alert.urgency) {
    'HIGH'   => 'Alta',
    'MEDIUM' => 'Media',
    _        => 'Baja',
  };

  IconData get _typeIcon => alert.alertType == 'LEVEL_UP'
      ? Icons.trending_up_rounded
      : Icons.warning_amber_rounded;

  @override
  Widget build(BuildContext context) {
    final unread = !alert.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unread ? AppTheme.primary.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _urgencyColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_typeIcon, color: _urgencyColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _urgencyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_urgencyLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _urgencyColor, fontWeight: FontWeight.w700)),
              ),
              if (unread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                ),
              ],
            ]),
            const SizedBox(height: 6),
            Text(alert.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: unread ? FontWeight.w600 : FontWeight.w400)),
            const SizedBox(height: 4),
            Text(alert.suggestedAction,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD))),
            const SizedBox(height: 6),
            Text(_formatDate(alert.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFFADA9B9))),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFADA9B9), size: 20),
        ]),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return iso;
    }
  }
}
