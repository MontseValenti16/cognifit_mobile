import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../viewmodels/admin_viewmodel.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final AdminViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.adminViewModel;
    _vm.addListener(_rebuild);
    _vm.load();
  }

  @override
  void dispose() {
    _vm.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (!mounted) return;
    final msg = _vm.successMessage ?? _vm.error;
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: _vm.error != null ? AppTheme.riskRed : AppTheme.activeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      _vm.clearMessages();
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
        title: const Text('Gestión de usuarios'),
        actions: [
          Tooltip(
            message: _vm.includeInactive ? 'Mostrar solo activos' : 'Mostrar inactivos también',
            child: IconButton(
              icon: Icon(_vm.includeInactive ? Icons.visibility_off_rounded : Icons.visibility_rounded),
              onPressed: _vm.toggleInactive,
            ),
          ),
          IconButton(icon: const Icon(Icons.logout_rounded), tooltip: 'Cerrar sesión', onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nuevo usuario'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _vm.users.isEmpty
              ? _EmptyView(includeInactive: _vm.includeInactive)
              : _UserList(vm: _vm),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateUserSheet(vm: _vm),
    );
  }
}

// ─── Lista de usuarios ────────────────────────────────────────────────────────

class _UserList extends StatelessWidget {
  final AdminViewModel vm;
  const _UserList({required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: vm.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _UserTile(user: vm.users[i], vm: vm),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AdminUserEntity user;
  final AdminViewModel vm;
  const _UserTile({required this.user, required this.vm});

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(user.role);
    return Opacity(
      opacity: user.isActive ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text(user.email[0].toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ),
          title: Text(user.email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Row(children: [
            _RoleChip(role: user.role),
            if (!user.isActive) ...[
              const SizedBox(width: 6),
              const _InactiveChip(),
            ],
          ]),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
            onPressed: () => _showOptions(context),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserOptionsSheet(user: user, vm: vm),
    );
  }

  Color _roleColor(String role) => switch (role) {
    'ADMIN'      => const Color(0xFF7C3AED),
    'SPECIALIST' => AppTheme.tertiary,
    'TEACHER'    => AppTheme.primary,
    'PARENT'     => AppTheme.warning,
    'STUDENT'    => AppTheme.activeGreen,
    _            => Colors.grey,
  };
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  static const _labels = {
    'ADMIN': 'Admin', 'SPECIALIST': 'Especialista',
    'TEACHER': 'Docente', 'PARENT': 'Padre/Tutor', 'STUDENT': 'Alumno',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_labels[role] ?? role, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
    );
  }
}

class _InactiveChip extends StatelessWidget {
  const _InactiveChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: const Text('Inactivo', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Opciones de usuario ──────────────────────────────────────────────────────

class _UserOptionsSheet extends StatelessWidget {
  final AdminUserEntity user;
  final AdminViewModel vm;
  const _UserOptionsSheet({required this.user, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(user.email, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        const Divider(height: 24),
        ListTile(
          leading: const Icon(Icons.manage_accounts_rounded, color: AppTheme.primary),
          title: const Text('Cambiar rol'),
          onTap: () { Navigator.pop(context); _showRoleSheet(context); },
        ),
        if (user.role == 'PARENT')
          ListTile(
            leading: const Icon(Icons.link_rounded, color: AppTheme.warning),
            title: const Text('Vincular alumno'),
            onTap: () { Navigator.pop(context); _showLinkSheet(context); },
          ),
        if (user.isActive)
          ListTile(
            leading: const Icon(Icons.person_off_rounded, color: Colors.orange),
            title: const Text('Desactivar cuenta'),
            onTap: () { Navigator.pop(context); _confirm(context, 'Desactivar', () => vm.deactivateUser(user.id)); },
          )
        else
          ListTile(
            leading: const Icon(Icons.person_rounded, color: AppTheme.activeGreen),
            title: const Text('Reactivar cuenta'),
            onTap: () { Navigator.pop(context); vm.reactivateUser(user.id); },
          ),
        const SizedBox(height: 16),
      ]),
    );
  }

  void _showRoleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangeRoleSheet(user: user, vm: vm),
    );
  }

  void _showLinkSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LinkStudentSheet(user: user, vm: vm),
    );
  }

  void _confirm(BuildContext context, String action, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action usuario'),
        content: Text('¿Seguro que deseas $action la cuenta de ${user.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () { Navigator.pop(context); onConfirm(); },
            child: Text(action, style: const TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}

// ─── Cambio de rol ────────────────────────────────────────────────────────────

class _ChangeRoleSheet extends StatefulWidget {
  final AdminUserEntity user;
  final AdminViewModel vm;
  const _ChangeRoleSheet({required this.user, required this.vm});
  @override
  State<_ChangeRoleSheet> createState() => _ChangeRoleSheetState();
}

class _ChangeRoleSheetState extends State<_ChangeRoleSheet> {
  static const _roles = ['ADMIN', 'SPECIALIST', 'TEACHER', 'PARENT', 'STUDENT'];
  static const _labels = {
    'ADMIN': 'Administrador', 'SPECIALIST': 'Especialista',
    'TEACHER': 'Docente', 'PARENT': 'Padre / Tutor', 'STUDENT': 'Alumno',
  };

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Cambiar rol', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        ..._roles.map((role) => ListTile(
          title: Text(_labels[role] ?? role),
          trailing: _selected == role
              ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
              : const Icon(Icons.circle_outlined, color: Colors.grey),
          onTap: () => setState(() => _selected = role),
        )),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: _selected == widget.user.role ? null : () async {
                final ok = await widget.vm.updateUserRole(widget.user.id, _selected);
                if (ok && context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            )),
          ]),
        ),
      ]),
    );
  }
}

// ─── Vincular alumno a padre/tutor ───────────────────────────────────────────

class _LinkStudentSheet extends StatefulWidget {
  final AdminUserEntity user;
  final AdminViewModel vm;
  const _LinkStudentSheet({required this.user, required this.vm});
  @override
  State<_LinkStudentSheet> createState() => _LinkStudentSheetState();
}

class _LinkStudentSheetState extends State<_LinkStudentSheet> {
  final _searchCtrl = TextEditingController();
  String? _selectedId;
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.vm.loadStudentsForPicker();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    final all = widget.vm.studentsForPicker;
    if (_query.isEmpty) return all;
    return all.where((s) => (s['full_name'] as String? ?? '').toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Vincular alumno', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar alumno…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          if (widget.vm.isLoadingStudents)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: _filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Sin resultados', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final s = _filtered[i];
                        final id = s['id'] as String;
                        final name = s['full_name'] as String? ?? 'Alumno';
                        return ListTile(
                          leading: const Icon(Icons.child_care_rounded, color: AppTheme.primary),
                          title: Text(name),
                          trailing: _selectedId == id
                              ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
                              : const Icon(Icons.circle_outlined, color: Colors.grey),
                          onTap: () => setState(() => _selectedId = id),
                        );
                      },
                    ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: _selectedId == null ? null : () async {
                  final ok = await widget.vm.linkParent(widget.user.id, _selectedId!);
                  if (ok && context.mounted) Navigator.pop(context);
                },
                child: const Text('Vincular'),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Crear usuario ────────────────────────────────────────────────────────────

class _CreateUserSheet extends StatefulWidget {
  final AdminViewModel vm;
  const _CreateUserSheet({required this.vm});
  @override
  State<_CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends State<_CreateUserSheet> {
  static const _roles = ['TEACHER', 'SPECIALIST', 'PARENT', 'ADMIN'];
  static const _labels = {
    'ADMIN': 'Administrador', 'SPECIALIST': 'Especialista',
    'TEACHER': 'Docente', 'PARENT': 'Padre / Tutor', 'STUDENT': 'Alumno',
  };

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'TEACHER';
  bool _obscure = true;
  bool _saving = false;
  String? _localError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Nuevo usuario', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 20),
            _Field(
              controller: _emailCtrl,
              label: 'Correo electrónico',
              hint: 'docente@colegio.edu',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _passCtrl,
              label: 'Contraseña (mín. 8 caracteres)',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Rol', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 6),
            InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _role,
                  isExpanded: true,
                  items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(_labels[r] ?? r))).toList(),
                  onChanged: (v) => setState(() => _role = v!),
                ),
              ),
            ),
            if (_localError != null) ...[
              const SizedBox(height: 10),
              Text(_localError!, style: const TextStyle(color: AppTheme.riskRed, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Crear usuario'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _localError = 'Completa todos los campos');
      return;
    }
    if (pass.length < 8) {
      setState(() => _localError = 'La contraseña debe tener al menos 8 caracteres');
      return;
    }
    setState(() { _saving = true; _localError = null; });
    final ok = await widget.vm.createUser(CreateUserParams(email: email, password: pass, role: _role));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ]);
  }
}

// ─── Vista vacía ──────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final bool includeInactive;
  const _EmptyView({required this.includeInactive});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.group_off_rounded, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          includeInactive ? 'No hay usuarios registrados' : 'No hay usuarios activos',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ]),
    );
  }
}
