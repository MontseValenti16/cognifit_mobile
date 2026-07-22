import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cognifit_app_bar.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../viewmodels/payment_viewmodel.dart';

class CardCheckoutScreen extends StatefulWidget {
  final PlanEntity plan;
  const CardCheckoutScreen({super.key, required this.plan});

  @override
  State<CardCheckoutScreen> createState() => _CardCheckoutScreenState();
}

class _CardCheckoutScreenState extends State<CardCheckoutScreen> {
  late final PaymentViewModel _vm;
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController(); // MM/AA
  final _cvcCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.paymentViewModel;
    _vm.resetCheckout();
    _vm.addListener(_onChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    if (_vm.checkoutStatus == CheckoutStatus.error && _vm.checkoutError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_vm.checkoutError!),
        backgroundColor: AppTheme.riskRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final parts = _expiryCtrl.text.split('/');
    if (parts.length != 2) return;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return;

    await _vm.payWithCard(
      planId: widget.plan.id,
      card: CardInput(
        number: _numberCtrl.text,
        expMonth: month,
        expYear: 2000 + year,
        cvc: _cvcCtrl.text,
        cardholderName: _nameCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: const CogniFitAppBar(title: 'Pago con tarjeta', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _vm.checkoutStatus == CheckoutStatus.success ? _SuccessView(plan: widget.plan) : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final busy = _vm.checkoutStatus == CheckoutStatus.tokenizing || _vm.checkoutStatus == CheckoutStatus.processing;
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text('${widget.plan.name} — ${widget.plan.priceLabel}${widget.plan.periodLabel}',
                  style: Theme.of(context).textTheme.titleSmall)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        CogniFitTextField(
          controller: _nameCtrl,
          label: 'Nombre en la tarjeta',
          hint: 'Como aparece en la tarjeta',
          prefixIcon: Icons.person_outline_rounded,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre del titular' : null,
        ),
        const SizedBox(height: 20),
        CogniFitTextField(
          controller: _numberCtrl,
          label: 'Número de tarjeta',
          hint: '4242 4242 4242 4242',
          prefixIcon: Icons.credit_card_rounded,
          keyboardType: TextInputType.number,
          validator: (v) {
            final digits = (v ?? '').replaceAll(' ', '');
            if (digits.length < 13 || digits.length > 19) return 'Número de tarjeta inválido';
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: CogniFitTextField(
              controller: _expiryCtrl,
              label: 'Vencimiento',
              hint: 'MM/AA',
              prefixIcon: Icons.calendar_month_outlined,
              keyboardType: TextInputType.number,
              validator: (v) => RegExp(r'^\d{2}/\d{2}$').hasMatch(v ?? '') ? null : 'Formato MM/AA',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CogniFitTextField(
              controller: _cvcCtrl,
              label: 'CVC',
              hint: '123',
              prefixIcon: Icons.lock_outline_rounded,
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (v) => (v != null && v.length >= 3) ? null : 'CVC inválido',
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text(
          'Tus datos de tarjeta se envían directo a la pasarela de pago (Conekta) y nunca pasan por los servidores de CogniFit.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD)),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: busy ? null : _submit,
          child: busy
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text('Pagar ${widget.plan.priceLabel}'),
        ),
      ]),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final PlanEntity plan;
  const _SuccessView({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 40),
      Container(
        width: 88, height: 88,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.activeGreen.withValues(alpha: 0.15)),
        child: Icon(Icons.check_circle_rounded, color: AppTheme.activeGreen, size: 52),
      ),
      const SizedBox(height: 24),
      Text('Pago confirmado', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(
        'Tu escuela ya tiene el plan ${plan.name} activo.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6880)),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: () => context.pop(),
        child: const Text('Listo'),
      ),
    ]);
  }
}
