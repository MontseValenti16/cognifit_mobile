import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../domain/entities/student_entity.dart';

String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

Color _avatarColor(String seed) {
  const colors = [AppTheme.primary, AppTheme.tertiary, AppTheme.secondary, AppTheme.pendingOrange, AppTheme.activeGreen];
  final idx = seed.codeUnits.fold<int>(0, (a, b) => a + b) % colors.length;
  return colors[idx];
}

class StudentListTile extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onActivate;

  const StudentListTile({
    super.key, required this.student, required this.onTap,
    required this.onEdit, required this.onDelete, required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(student.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Center(child: Text(_initialsOf(student.fullName),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(student.fullName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Row(children: [
                  if (student.birthYear != null) ...[
                    Icon(Icons.cake_outlined, size: 13, color: const Color(0xFF9E9CAD)),
                    const SizedBox(width: 3),
                    Text('${student.age} años', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 10),
                  ],
                  if (!student.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.riskRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text('Inactivo', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.riskRed)),
                    ),
                ]),
              ])),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'deactivate') onDelete();
                  if (v == 'activate') onActivate();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Row(children: [
                    const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary), const SizedBox(width: 10), const Text('Editar'),
                  ])),
                  if (student.isActive)
                    PopupMenuItem(value: 'deactivate', child: Row(children: [
                      Icon(Icons.block_rounded, size: 18, color: AppTheme.riskRed), const SizedBox(width: 10),
                      Text('Desactivar', style: TextStyle(color: AppTheme.riskRed)),
                    ]))
                  else
                    PopupMenuItem(value: 'activate', child: Row(children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18, color: AppTheme.activeGreen), const SizedBox(width: 10),
                      Text('Reactivar', style: TextStyle(color: AppTheme.activeGreen)),
                    ])),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class StudentsSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const StudentsSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar alumno...',
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFADA9B9), size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        fillColor: Colors.white, filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      ),
    );
  }
}

class StudentsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const StudentsEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.groups_outlined, size: 56, color: AppTheme.outline),
        const SizedBox(height: 12),
        Text('Aún no hay alumnos', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF9E9CAD))),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Agregar alumno')),
      ]),
    ));
  }
}

class GroupFilterChips extends StatelessWidget {
  final List<GroupEntity> groups;
  final String? selectedGroupId;
  final ValueChanged<String?> onSelected;

  const GroupFilterChips({
    super.key,
    required this.groups,
    required this.selectedGroupId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'Todos',
            selected: selectedGroupId == null,
            onTap: () => onSelected(null),
          ),
          ...groups.map((g) => _Chip(
            label: g.displayName,
            selected: selectedGroupId == g.id,
            onTap: () => onSelected(g.id),
          )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.outline),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : const Color(0xFF6B6880),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
