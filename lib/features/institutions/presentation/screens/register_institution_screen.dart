import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../../splash/presentation/widgets/circuit_background.dart';
import '../../domain/entities/institution_entity.dart';
import '../viewmodels/institution_viewmodel.dart';

class RegisterInstitutionScreen extends StatefulWidget {
  const RegisterInstitutionScreen({super.key});
  @override
  State<RegisterInstitutionScreen> createState() => _RegisterInstitutionScreenState();
}

class _RegisterInstitutionScreenState extends State<RegisterInstitutionScreen> {
  late final InstitutionViewModel _vm;

  final _schoolNameCtrl = TextEditingController();
  final _cctCtrl = TextEditingController();
  final _municipalityCtrl = TextEditingController();
  final _adminEmailCtrl = TextEditingController();
  final _adminPasswordCtrl = TextEditingController();
  bool _obscure = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.institutionViewModel;
    _vm.addListener(_onChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _schoolNameCtrl.dispose();
    _cctCtrl.dispose();
    _municipalityCtrl.dispose();
    _adminEmailCtrl.dispose();
    _adminPasswordCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    if (_vm.registerStatus == RegisterInstitutionStatus.success) {
      setState(() => _submitted = true);
    } else if (_vm.registerStatus == RegisterInstitutionStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_vm.registerError ?? 'Error'),
        backgroundColor: AppTheme.riskRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (_schoolNameCtrl.text.trim().isEmpty || _adminEmailCtrl.text.trim().isEmpty || _adminPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa nombre de la escuela, correo y contraseña')));
      return;
    }
    await _vm.registerInstitution(RegisterInstitutionParams(
      schoolName: _schoolNameCtrl.text.trim(),
      cct: _cctCtrl.text.trim().isEmpty ? null : _cctCtrl.text.trim(),
      municipality: _municipalityCtrl.text.trim().isEmpty ? null : _municipalityCtrl.text.trim(),
      adminEmail: _adminEmailCtrl.text.trim(),
      adminPassword: _adminPasswordCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(children: [
        const CircuitBackground(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const SizedBox(height: 36),
              if (_submitted) _SuccessView(onBackToLogin: () => context.pop()) else _buildForm(),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildForm() {
    return Column(children: [
      const AuthHeader(subtitle: 'Registra tu escuela para empezar a usar CogniFit'),
      const SizedBox(height: 28),
      CogniFitTextField(
        controller: _schoolNameCtrl,
        label: 'Nombre de la escuela',
        hint: 'Escuela Primaria Benito Juárez',
        prefixIcon: Icons.school_outlined,
      ),
      const SizedBox(height: 20),
      CogniFitTextField(
        controller: _cctCtrl,
        label: 'CCT (opcional)',
        hint: 'Clave de Centro de Trabajo (SEP)',
        prefixIcon: Icons.badge_outlined,
      ),
      const SizedBox(height: 20),
      CogniFitTextField(
        controller: _municipalityCtrl,
        label: 'Municipio (opcional)',
        hint: 'Tuxtla Gutiérrez',
        prefixIcon: Icons.location_on_outlined,
      ),
      const SizedBox(height: 28),
      Divider(color: AppTheme.outline.withValues(alpha: 0.3)),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Text('Cuenta del administrador', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 16),
      CogniFitTextField(
        controller: _adminEmailCtrl,
        label: 'Correo del administrador',
        hint: 'director@escuela.edu',
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 20),
      CogniFitTextField(
        controller: _adminPasswordCtrl,
        label: 'Contraseña (mín. 8 caracteres)',
        hint: '• • • • • • • •',
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: _obscure,
        suffixWidget: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFFADA9B9), size: 20),
        ),
      ),
      const SizedBox(height: 32),
      ListenableBuilder(
        listenable: _vm,
        builder: (_, __) => ElevatedButton(
          onPressed: _vm.registerStatus == RegisterInstitutionStatus.loading ? null : _submit,
          child: _vm.registerStatus == RegisterInstitutionStatus.loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text('Registrar mi institución'),
        ),
      ),
      const SizedBox(height: 24),
      Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('¿Ya tienes cuenta? ', style: Theme.of(context).textTheme.bodyMedium),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text('Inicia sesión', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
        ),
      ]),
    ]);
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onBackToLogin;
  const _SuccessView({required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 60),
      Container(
        width: 88, height: 88,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.activeGreen.withValues(alpha: 0.15)),
        child: const Icon(Icons.check_circle_rounded, color: AppTheme.activeGreen, size: 52),
      ),
      const SizedBox(height: 24),
      Text('Solicitud enviada', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(
        'Tu escuela fue registrada y está pendiente de aprobación. Te avisaremos por correo cuando puedas iniciar sesión.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6880)),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      ElevatedButton(onPressed: onBackToLogin, child: const Text('Volver a inicio de sesión')),
    ]);
  }
}
