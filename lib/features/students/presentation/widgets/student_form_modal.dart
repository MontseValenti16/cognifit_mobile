import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../domain/entities/student_entity.dart';

/// Bottom sheet form used for both "Nuevo alumno" and "Editar alumno".
/// Validation per API_UI_GUIA: full_name 1–180 chars, birth_year 2008–2022.
///
/// On create, the teacher picks a group from a dropdown (no UUID typing). If
/// they have no groups yet, an inline "create group" form lets them make one
/// on the spot — the backend auto-provisions the school, so no UUIDs needed.
class StudentFormModal extends StatefulWidget {
  final StudentEntity? existing;
  final List<GroupEntity> groups;
  final bool isSaving;
  final void Function(String groupId, String fullName, int? birthYear, String? gender) onSubmit;

  /// Creates a group and returns it (or null on failure) so it can be selected.
  final Future<GroupEntity?> Function(CreateGroupParams params) onCreateGroup;

  const StudentFormModal({
    super.key,
    this.existing,
    required this.groups,
    required this.isSaving,
    required this.onSubmit,
    required this.onCreateGroup,
  });

  @override
  State<StudentFormModal> createState() => _StudentFormModalState();
}

class _StudentFormModalState extends State<StudentFormModal> {
  late final TextEditingController _nameCtrl;
  String? _selectedGroupId;
  int? _birthYear;
  String? _gender;
  String? _nameError;
  String? _groupError;

  // Inline "create group" state.
  bool _creatingGroup = false;          // form visible
  bool _savingGroup = false;            // request in flight
  int _newGrade = 1;
  final _labelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: '2025-2026');
  String? _labelError;

  static const _years = [2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022];

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.existing?.fullName ?? '');
    _birthYear = widget.existing?.birthYear;
    _gender    = widget.existing?.gender;
    _selectedGroupId = widget.existing?.groupId ?? widget.groups.firstOrNull?.id;
    // Brand-new teacher with no groups: open the create-group form by default.
    _creatingGroup = widget.existing == null && widget.groups.isEmpty;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _labelCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final label = _labelCtrl.text.trim();
    if (label.isEmpty || label.length > 16) {
      setState(() => _labelError = 'Indica el grupo (ej. "A", "B").');
      return;
    }
    setState(() { _labelError = null; _savingGroup = true; });
    final year = _yearCtrl.text.trim();
    final group = await widget.onCreateGroup(CreateGroupParams(
      grade: _newGrade,
      groupLabel: label,
      schoolYear: year.isEmpty ? '2025-2026' : year,
    ));
    if (!mounted) return;
    setState(() {
      _savingGroup = false;
      if (group != null) {
        _selectedGroupId = group.id;
        _creatingGroup = false;
        _groupError = null;
        _labelCtrl.clear();
      }
    });
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    bool hasError = false;

    if (name.isEmpty || name.length > 180) {
      setState(() => _nameError = 'El nombre debe tener entre 1 y 180 caracteres.');
      hasError = true;
    } else {
      setState(() => _nameError = null);
    }

    final isEdit = widget.existing != null;
    if (!isEdit && (_selectedGroupId == null || _selectedGroupId!.isEmpty)) {
      setState(() => _groupError = 'Selecciona o crea un grupo.');
      hasError = true;
    } else {
      setState(() => _groupError = null);
    }

    if (hasError) return;
    widget.onSubmit(_selectedGroupId ?? widget.existing!.groupId, name, _birthYear, _gender);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        context.hPad, 12, context.hPad,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(4)),
            )),
            const SizedBox(height: 20),

            Text(isEdit ? 'Editar alumno' : 'Nuevo alumno',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // ── Group (create mode only) ─────────────────────────────────────
            if (!isEdit) ...[
              Text('Grupo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (widget.groups.isNotEmpty && !_creatingGroup) ...[
                DropdownButtonFormField<String>(
                  value: _selectedGroupId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    errorText: _groupError,
                    prefixIcon: const Icon(Icons.group_outlined, size: 20, color: Color(0xFFADA9B9)),
                  ),
                  items: widget.groups
                      .map((g) => DropdownMenuItem(value: g.id, child: Text(g.displayName)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGroupId = v),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _creatingGroup = true),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Crear grupo nuevo'),
                  ),
                ),
              ] else
                _GroupCreateForm(
                  grade: _newGrade,
                  labelCtrl: _labelCtrl,
                  yearCtrl: _yearCtrl,
                  labelError: _labelError,
                  saving: _savingGroup,
                  canCancel: widget.groups.isNotEmpty,
                  onGradeChanged: (g) => setState(() => _newGrade = g),
                  onCreate: _createGroup,
                  onCancel: () => setState(() => _creatingGroup = false),
                ),
              const SizedBox(height: 18),
            ],

            // ── Full name ────────────────────────────────────────────────────
            Text('Nombre completo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'Ej. María Pérez López',
                errorText: _nameError,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFFADA9B9)),
              ),
            ),
            const SizedBox(height: 18),

            // ── Birth year ───────────────────────────────────────────────────
            Text('Año de nacimiento', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _birthYear,
              isExpanded: true,
              hint: const Text('Selecciona el año'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.cake_outlined, size: 20, color: Color(0xFFADA9B9)),
              ),
              items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
              onChanged: (v) => setState(() => _birthYear = v),
            ),
            const SizedBox(height: 18),

            // ── Gender ───────────────────────────────────────────────────────
            Text('Género', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(children: [
              _GenderChip(label: 'Femenino',  value: 'F', selected: _gender == 'F', onTap: () => setState(() => _gender = 'F')),
              const SizedBox(width: 10),
              _GenderChip(label: 'Masculino', value: 'M', selected: _gender == 'M', onTap: () => setState(() => _gender = 'M')),
              const SizedBox(width: 10),
              _GenderChip(label: 'Otro',      value: 'O', selected: _gender == 'O', onTap: () => setState(() => _gender = 'O')),
            ]),
            const SizedBox(height: 28),

            // ── Submit ───────────────────────────────────────────────────────
            ElevatedButton(
              onPressed: widget.isSaving ? null : _submit,
              child: widget.isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(isEdit ? 'Guardar cambios' : 'Crear alumno'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline mini-form to create a group without leaving the student sheet.
class _GroupCreateForm extends StatelessWidget {
  final int grade;
  final TextEditingController labelCtrl;
  final TextEditingController yearCtrl;
  final String? labelError;
  final bool saving;
  final bool canCancel;
  final ValueChanged<int> onGradeChanged;
  final VoidCallback onCreate;
  final VoidCallback onCancel;

  const _GroupCreateForm({
    required this.grade,
    required this.labelCtrl,
    required this.yearCtrl,
    required this.labelError,
    required this.saving,
    required this.canCancel,
    required this.onGradeChanged,
    required this.onCreate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nuevo grupo',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: grade,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Grado'),
                  items: [1,2,3,4,5,6]
                      .map((g) => DropdownMenuItem(value: g, child: Text('$g°')))
                      .toList(),
                  onChanged: saving ? null : (v) => onGradeChanged(v ?? grade),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: labelCtrl,
                  enabled: !saving,
                  decoration: InputDecoration(labelText: 'Grupo', hintText: 'A', errorText: labelError),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: yearCtrl,
            enabled: !saving,
            decoration: const InputDecoration(labelText: 'Ciclo escolar', hintText: '2025-2026'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (canCancel)
                Expanded(
                  child: OutlinedButton(
                    onPressed: saving ? null : onCancel,
                    child: const Text('Cancelar'),
                  ),
                ),
              if (canCancel) const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: saving ? null : onCreate,
                  child: saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Crear grupo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _GenderChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryContainer : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.outline, width: selected ? 2 : 1),
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? AppTheme.primary : AppTheme.onSurface,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
        ),
      ),
    );
  }
}
