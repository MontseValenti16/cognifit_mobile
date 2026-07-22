import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../viewmodels/reports_viewmodel.dart';

class ReportBottomSheet extends StatefulWidget {
  final ReportsViewModel vm;
  final String studentId;
  final String studentName;

  const ReportBottomSheet({
    super.key,
    required this.vm,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  @override
  void initState() {
    super.initState();
    widget.vm.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.vm.removeListener(_rebuild);
    widget.vm.reset();
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  String _statusLabel() => switch (widget.vm.status) {
    ReportStatus.requesting  => 'Solicitando reporte...',
    ReportStatus.generating  => 'Generando PDF...',
    ReportStatus.downloading => 'Descargando archivo...',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text('Generar reporte — ${widget.studentName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
            IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero),
          ]),
          const SizedBox(height: 16),

          // Type picker (only when idle or error)
          if (vm.isIdle || vm.status == ReportStatus.error) ...[
            _TypeOption(
              label: 'Resumen para padres',
              subtitle: 'Redacción sencilla, sin tecnicismos',
              value: 'PARENT_SUMMARY',
              groupValue: vm.reportType,
              onChanged: vm.setReportType,
            ),
            const SizedBox(height: 8),
            _TypeOption(
              label: 'Informe completo (especialista)',
              subtitle: 'Datos clínicos, métricas y recomendaciones detalladas',
              value: 'SPECIALIST_FULL',
              groupValue: vm.reportType,
              onChanged: vm.setReportType,
            ),
            const SizedBox(height: 20),
          ],

          // Busy state
          if (vm.isBusy) ...[
            const SizedBox(height: 16),
            Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            const SizedBox(height: 12),
            Text(_statusLabel(), textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD))),
            const SizedBox(height: 24),
          ],

          // Error
          if (vm.status == ReportStatus.error && vm.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.riskRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: Text(vm.error!, style: TextStyle(color: AppTheme.riskRed)),
            ),
            const SizedBox(height: 16),
          ],

          // Ready — share button
          if (vm.isReady) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.activeGreen.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.activeGreen.withValues(alpha: 0.3))),
              child: Row(children: [
                Icon(Icons.check_circle_rounded, color: AppTheme.activeGreen),
                const SizedBox(width: 8),
                Text('PDF listo', style: TextStyle(color: AppTheme.activeGreen, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.share_rounded),
              label: const Text('Compartir / Descargar PDF'),
              onPressed: vm.share,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: vm.reset,
              child: const Text('Generar otro reporte'),
            ),
          ],

          // Generate button
          if (vm.isIdle || vm.status == ReportStatus.error)
            ElevatedButton(
              onPressed: () => vm.generate(widget.studentId),
              child: const Text('Generar reporte'),
            ),
        ]),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _TypeOption({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.outline.withValues(alpha: 0.4), width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Radio<String>(value: value, groupValue: groupValue, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primary, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD))),
          ])),
        ]),
      ),
    );
  }
}
