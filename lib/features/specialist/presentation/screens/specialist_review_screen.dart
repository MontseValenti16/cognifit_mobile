import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../../features/tests/domain/entities/screening_entity.dart';
import '../viewmodels/specialist_viewmodel.dart';

class SpecialistReviewScreen extends StatefulWidget {
  const SpecialistReviewScreen({super.key});

  @override
  State<SpecialistReviewScreen> createState() => _SpecialistReviewScreenState();
}

class _SpecialistReviewScreenState extends State<SpecialistReviewScreen> {
  late final SpecialistViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.specialistViewModel;
    _vm.addListener(_rebuild);
    _vm.load();
  }

  @override
  void dispose() {
    _vm.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Revisión clínica'),
        backgroundColor: AppTheme.cardColor,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.outline.withValues(alpha: 0.3)),
        ),
        actions: [
          if (_vm.totalLabeled > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.activeGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_vm.totalLabeled} etiquetados',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.activeGreen, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          const ThemeToggleButton(),
        ],
      ),
      body: _vm.isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _vm.error != null
              ? _ErrorView(message: _vm.error!, onRetry: _vm.load)
              : _vm.pending.isEmpty
                  ? _EmptyView(totalLabeled: _vm.totalLabeled)
                  : RefreshIndicator(
                      onRefresh: _vm.load,
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _vm.pending.length,
                        itemBuilder: (_, i) => _DiagnosisCard(
                          diagnosis: _vm.pending[i],
                          onConfirm: () => _handleConfirm(_vm.pending[i]),
                          onCorrect: () => _showCorrectionSheet(_vm.pending[i]),
                        ),
                      ),
                    ),
    );
  }

  Future<void> _handleConfirm(PendingDiagnosisEntity d) async {
    final ok = await _vm.confirm(d);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Diagnóstico confirmado' : 'Error al confirmar'),
        backgroundColor: ok ? AppTheme.activeGreen : AppTheme.riskRed,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _showCorrectionSheet(PendingDiagnosisEntity d) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CorrectionSheet(diagnosis: d, vm: _vm),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _DiagnosisCard extends StatelessWidget {
  final PendingDiagnosisEntity diagnosis;
  final VoidCallback onConfirm;
  final VoidCallback onCorrect;

  const _DiagnosisCard({
    required this.diagnosis,
    required this.onConfirm,
    required this.onCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final d = diagnosis;
    final riskColor = d.autoRiskLevel == 'HIGH'
        ? AppTheme.riskRed
        : d.autoRiskLevel == 'MEDIUM'
            ? AppTheme.pendingOrange
            : AppTheme.activeGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header: student + date
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppTheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.person_rounded, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.studentName, style: Theme.of(context).textTheme.titleSmall),
              Text(
                'Grado ${d.grade ?? "?"} · ${_formatDate(d.diagnosedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD)),
              ),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                d.autoRiskLevel == 'HIGH' ? 'Alto' : d.autoRiskLevel == 'MEDIUM' ? 'Medio' : 'Bajo',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: riskColor, fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Auto-diagnosis chips
          Text('Diagnóstico automático', style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 0.8, color: const Color(0xFF9E9CAD), fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _Chip(label: d.subtypeLabel, color: AppTheme.primary),
            _Chip(label: d.severityLabel, color: AppTheme.tertiary),
            _Chip(
              label: '${(d.riskProbability * 100).toStringAsFixed(0)}% riesgo',
              color: riskColor,
            ),
          ]),

          if (d.mainErrorCodes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Errores: ${d.mainErrorCodes.join(", ")}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B6880))),
          ],

          if (d.plnSource == 'rule') ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.info_outline_rounded, size: 13, color: AppTheme.pendingOrange),
              const SizedBox(width: 4),
              Text('Modelo local (reglas)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.pendingOrange)),
            ]),
          ],

          const SizedBox(height: 14),

          // Action buttons
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCorrect,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Corregir'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.onSurface,
                  side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Confirmar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.activeGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color, fontWeight: FontWeight.w600,
      )),
  );
}

// ── Correction bottom sheet ───────────────────────────────────────────────────

class _CorrectionSheet extends StatefulWidget {
  final PendingDiagnosisEntity diagnosis;
  final SpecialistViewModel vm;
  const _CorrectionSheet({required this.diagnosis, required this.vm});

  @override
  State<_CorrectionSheet> createState() => _CorrectionSheetState();
}

class _CorrectionSheetState extends State<_CorrectionSheet> {
  static const _subtypes = [
    ('PHONOLOGICAL',   'Fonológico'),
    ('VISUAL_SURFACE', 'Visual/Superficial'),
    ('MIXED',          'Mixto'),
    ('FLUENCY',        'Fluidez'),
    ('COMPREHENSION',  'Comprensión'),
    ('NO_DYSLEXIA',    'Sin riesgo'),
  ];

  static const _severities = [
    ('MILD',     'Leve'),
    ('MODERATE', 'Moderado'),
    ('SEVERE',   'Severo'),
    ('NONE',     'Sin riesgo'),
  ];

  static const _riskLevels = [
    ('HIGH',   'Alto'),
    ('MEDIUM', 'Medio'),
    ('LOW',    'Bajo'),
  ];

  late String _subtype;
  late String _severity;
  late String _riskLevel;
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _subtype = widget.diagnosis.autoSubtype;
    _severity = widget.diagnosis.autoSeverity;
    _riskLevel = widget.diagnosis.autoRiskLevel;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          // Handle
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFD0CDD7), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollCtrl,
              padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Corregir diagnóstico',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(widget.diagnosis.studentName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD))),
                const SizedBox(height: 20),

                _DropdownField(
                  label: 'Subtipo',
                  value: _subtype,
                  items: _subtypes,
                  onChanged: (v) => setState(() => _subtype = v!),
                ),
                const SizedBox(height: 14),

                _DropdownField(
                  label: 'Severidad',
                  value: _severity,
                  items: _severities,
                  onChanged: (v) => setState(() => _severity = v!),
                ),
                const SizedBox(height: 14),

                _DropdownField(
                  label: 'Nivel de riesgo',
                  value: _riskLevel,
                  items: _riskLevels,
                  onChanged: (v) => setState(() => _riskLevel = v!),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Observaciones clínicas...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Guardar corrección',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final ok = await widget.vm.correct(
      diagnosisId: widget.diagnosis.id,
      subtype: _subtype,
      severity: _severity,
      riskLevel: _riskLevel,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Corrección guardada' : 'Error al guardar'),
        backgroundColor: ok ? AppTheme.activeGreen : AppTheme.riskRed,
        duration: const Duration(seconds: 2),
      ));
    }
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label, required this.value,
    required this.items, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        items: items.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

// ── Empty / Error views ───────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final int totalLabeled;
  const _EmptyView({required this.totalLabeled});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle_outline_rounded, size: 64, color: AppTheme.activeGreen.withValues(alpha: 0.7)),
        const SizedBox(height: 16),
        Text('¡Todo revisado!', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          totalLabeled > 0
              ? 'Etiquetaste $totalLabeled diagnóstico${totalLabeled > 1 ? "s" : ""} en esta sesión.'
              : 'No hay diagnósticos pendientes de revisión.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD)),
          textAlign: TextAlign.center,
        ),
      ]),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.riskRed.withValues(alpha: 0.7)),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
      ]),
    ),
  );
}
