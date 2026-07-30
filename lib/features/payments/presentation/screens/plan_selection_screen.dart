import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cognifit_app_bar.dart';
import '../../domain/entities/plan_entity.dart';
import '../viewmodels/payment_viewmodel.dart';

class PlanSelectionScreen extends ConsumerStatefulWidget {
  const PlanSelectionScreen({super.key});
  @override
  ConsumerState<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends ConsumerState<PlanSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) ref.read(paymentViewModelProvider.notifier).loadPlans();
    });
  }

  void _choosePaymentMethod(PlanEntity plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
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
              leading: Icon(Icons.credit_card_rounded, color: AppTheme.primary),
              title: const Text('Tarjeta de crédito o débito'),
              subtitle: const Text('Cargo inmediato'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.cardCheckout, extra: {'plan': plan});
              },
            ),
            ListTile(
              leading: Icon(Icons.storefront_rounded, color: AppTheme.tertiary),
              title: const Text('Efectivo en OXXO'),
              subtitle: const Text('Genera una referencia para pagar en tienda'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.cashCheckout, extra: {'plan': plan});
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_rounded, color: AppTheme.tertiary),
              title: const Text('Transferencia SPEI'),
              subtitle: const Text('Genera una CLABE para transferir desde tu banco'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.transferCheckout, extra: {'plan': plan});
              },
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: const CogniFitAppBar(title: 'Planes de licencia', showBack: true),
      body: SafeArea(
        child: state.plansLoading || state.plansIdle
            ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : state.plansError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(state.plansError!, textAlign: TextAlign.center),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.plans.length,
                    itemBuilder: (_, i) => _PlanCard(plan: state.plans[i], onTap: () => _choosePaymentMethod(state.plans[i])),
                  ),
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
                Icon(Icons.chevron_right_rounded, color: AppTheme.primary),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
