import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cognifit_app_bar.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../viewmodels/payment_viewmodel.dart';

class CashCheckoutScreen extends ConsumerStatefulWidget {
  final PlanEntity plan;
  const CashCheckoutScreen({super.key, required this.plan});

  @override
  ConsumerState<CashCheckoutScreen> createState() => _CashCheckoutScreenState();
}

class _CashCheckoutScreenState extends ConsumerState<CashCheckoutScreen> {
  PaymentNotifier get _notifier => ref.read(paymentViewModelProvider.notifier);
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) _notifier.resetCheckout();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    final paymentId = ref.read(paymentViewModelProvider).lastPayment?.id;
    if (paymentId == null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (ref.read(paymentViewModelProvider).lastPayment?.status == PaymentStatus.paid) {
        timer.cancel();
        return;
      }
      _notifier.refreshPaymentStatus(paymentId);
    });
  }

  Future<void> _generate() => _notifier.payWithCash(planId: widget.plan.id);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);

    ref.listen<PaymentState>(paymentViewModelProvider, (previous, next) {
      if (next.checkoutSuccess && _pollTimer == null) {
        _startPolling();
      }
      if (next.checkoutError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.checkoutError!),
          backgroundColor: AppTheme.riskRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: const CogniFitAppBar(title: 'Pago en OXXO', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: state.lastPayment != null ? _ReferenceView(payment: state.lastPayment!) : _buildIntro(state),
        ),
      ),
    );
  }

  Widget _buildIntro(PaymentState state) {
    final busy = state.checkoutBusy;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      Text('Vas a generar una referencia de pago para presentar en cualquier tienda OXXO.',
          style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 8),
      Text('La licencia se activa automáticamente en cuanto se registre el pago (puede tardar unos minutos).',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText)),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: busy ? null : _generate,
        child: busy
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('Generar referencia de pago'),
      ),
    ]);
  }
}

class _ReferenceView extends StatelessWidget {
  final PaymentEntity payment;
  const _ReferenceView({required this.payment});

  @override
  Widget build(BuildContext context) {
    if (payment.status == PaymentStatus.paid) {
      return Column(children: [
        const SizedBox(height: 40),
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.activeGreen.withValues(alpha: 0.15)),
          child: Icon(Icons.check_circle_rounded, color: AppTheme.activeGreen, size: 52),
        ),
        const SizedBox(height: 24),
        Text('Pago recibido', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('La licencia de tu escuela ya está activa.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: () => context.pop(), child: const Text('Listo')),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppTheme.pendingOrange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.schedule_rounded, color: AppTheme.pendingOrange, size: 18),
          const SizedBox(width: 8),
          Text('Pendiente de pago', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.pendingOrange, fontWeight: FontWeight.w700)),
        ]),
      ),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text('Referencia de pago', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            SelectableText(
              payment.cashReference ?? '—',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w800),
            ),
            if (payment.cashBarcodeUrl != null) ...[
              const SizedBox(height: 16),
              Image.network(payment.cashBarcodeUrl!, height: 80, fit: BoxFit.contain),
            ],
            if (payment.cashExpiresAt != null) ...[
              const SizedBox(height: 16),
              Text('Vence: ${payment.cashExpiresAt}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ]),
        ),
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => SharePlus.instance.share(ShareParams(
          text: 'Referencia de pago CogniFit Escolar: ${payment.cashReference}. Preséntala en cualquier OXXO.',
        )),
        icon: const Icon(Icons.share_rounded),
        label: const Text('Compartir referencia'),
      ),
    ]);
  }
}
