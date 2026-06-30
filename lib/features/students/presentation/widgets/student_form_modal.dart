import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/student_entity.dart';

/// Bottom sheet form used for both "Nuevo alumno" and "Editar alumno".
/// Validation per API_UI_GUIA: full_name 1–180 chars, birth_year 2008–2022.
class StudentFormModal extends StatefulWidget {
  final StudentEntity? existing; // null = create mode
  final String defaultGroupId;
  final bool isSaving;
  final void Function(String fullName, int? birthYear, String? gender) onSubmit;

  const StudentFormModal({
    super.key,
    this.existing,
    required this.defaultGroupId,
    required this.isSaving,
    required this.onSubmit,
  });

  @override
  State<StudentFormModal> createState() => _StudentFormModalState();
}

class _StudentFormModalState extends State<StudentFormModal> {
  late final TextEditingController _nameCtrl;
  int? _birthYear;
  String? _gender;
  String? _nameError;

  static const _years = [2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.fullName ?? '');
    _birthYear = widget.existing?.birthYear;
    _gender = widget.existing?.gender;
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || name.length > 180) {
      setState(() => _nameError = 'El nombre debe tener entre 1 y 180 caracteres.');
      return;
    }
    setState(() => _nameError = null);
    widget.onSubmit(name, _birthYear, _gender);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(context.hPad, 12, context.hPad, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 20),

          Text(isEdit ? 'Editar alumno' : 'Nuevo alumno',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

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

          Text('Año de nacimiento', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _birthYear,
            isExpanded: true,
            hint: const Text('Selecciona el año'),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.cake_outlined, size: 20, color: Color(0xFFADA9B9))),
            items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
            onChanged: (v) => setState(() => _birthYear = v),
          ),
          const SizedBox(height: 18),

          Text('Género', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(children: [
            _GenderChip(label: 'Femenino', value: 'F', selected: _gender == 'F', onTap: () => setState(() => _gender = 'F')),
            const SizedBox(width: 10),
            _GenderChip(label: 'Masculino', value: 'M', selected: _gender == 'M', onTap: () => setState(() => _gender = 'M')),
            const SizedBox(width: 10),
            _GenderChip(label: 'Otro', value: 'O', selected: _gender == 'O', onTap: () => setState(() => _gender = 'O')),
          ]),
          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: widget.isSaving ? null : _submit,
            child: widget.isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isEdit ? 'Guardar cambios' : 'Crear alumno'),
          ),
        ]),
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
