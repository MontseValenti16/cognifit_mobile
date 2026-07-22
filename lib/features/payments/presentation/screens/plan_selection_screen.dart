import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cognifit_app_bar.dart';
import '../../domain/entities/plan_entity.dart';
import '../viewmodels/payment_viewmodel.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});
  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  late final PaymentViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.paymentViewModel;
    _vm.addListener(_onChanged);
    _vm.loadPlans();
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _choosePaymentMethod(PlanEntity plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('¿Cómo quieres pagar?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('${plan.name} — ${plan.priceLabel}${plan.periodLabel}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: AppTheme.primary),
              title: const Text('Tarjeta de crédito o débito'),
              subtitle: const Text('Cargo inmediato'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.cardCheckout, extra: {'plan': plan});
              },
            ),
            ListTile(
              leading: const Icon(Icons.storefront_rounded, color: AppTheme.tertiary),
              title: const Text('Efectivo en OXXO'),
              subtitle: const Text('Genera una referencia para pagar en tienda'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.cashCheckout, extra: {'plan': plan});
              },
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: const CogniFitAppBar(title: 'Planes de licencia', showBack: true),
      body: SafeArea(
        child: switch (_vm.plansStatus) {
          PlansStatus.loading || PlansStatus.idle =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          PlansStatus.error => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_vm.plansError ?? 'Error', textAlign: TextAlign.center),
              ),
            ),
          PlansStatus.loaded => ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _vm.plans.length,
              itemBuilder: (_, i) => _PlanCard(plan: _vm.plans[i], onTap: () => _choosePaymentMethod(_vm.plans[i])),
            ),
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PlanEntity plan;
  final VoidCallback onTap;
  const _PlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(plan.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: Text(plan.licenseTier.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: plan.priceLabel, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextSpan(text: plan.periodLabel, style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Elegir', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary)),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.primary),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
