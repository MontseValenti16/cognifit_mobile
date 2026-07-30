import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/api_exception.dart';
import '../../data/datasources/conekta_tokenization_datasource.dart';
import '../../di/payments_providers.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/usecases/checkout_with_card_usecase.dart';
import '../../domain/usecases/checkout_with_cash_usecase.dart';
import '../../domain/usecases/checkout_with_spei_usecase.dart';
import '../../domain/usecases/get_payment_usecase.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/tokenize_card_usecase.dart';

class PaymentState {
  final AsyncValue<List<PlanEntity>> plansAsync;
  final AsyncValue<PaymentEntity?> checkoutAsync;

  const PaymentState({
    this.plansAsync = const AsyncValue.data([]),
    this.checkoutAsync = const AsyncValue.data(null),
  });

  List<PlanEntity> get plans => plansAsync.valueOrNull ?? const [];
  bool get plansLoading => plansAsync.isLoading;
  bool get plansIdle => !plansLoading && !plansAsync.hasError && plansAsync.valueOrNull == null;
  String? get plansError {
    final err = plansAsync.error;
    if (err == null) return null;
    return err is ApiException ? err.userMessage : 'No se pudieron cargar los planes disponibles.';
  }

  PaymentEntity? get lastPayment => checkoutAsync.valueOrNull;
  bool get checkoutBusy => checkoutAsync.isLoading;
  bool get checkoutSuccess => checkoutAsync.hasValue && lastPayment != null;
  String? get checkoutError {
    final err = checkoutAsync.error;
    if (err == null) return null;
    if (err is CardTokenizationException) return err.userMessage;
    if (err is ApiException) return err.userMessage;
    if (err is _CheckoutFailure) return err.message;
    return 'No se pudo procesar el pago. Intenta de nuevo.';
  }

  PaymentState copyWith({AsyncValue<List<PlanEntity>>? plansAsync, AsyncValue<PaymentEntity?>? checkoutAsync}) {
    return PaymentState(
      plansAsync: plansAsync ?? this.plansAsync,
      checkoutAsync: checkoutAsync ?? this.checkoutAsync,
    );
  }
}

class _CheckoutFailure {
  final String message;
  const _CheckoutFailure(this.message);
}

class PaymentNotifier extends Notifier<PaymentState> {
  late GetPlansUseCase _getPlans;
  late TokenizeCardUseCase _tokenizeCard;
  late CheckoutWithCardUseCase _checkoutWithCard;
  late CheckoutWithCashUseCase _checkoutWithCash;
  late CheckoutWithSpeiUseCase _checkoutWithSpei;
  late GetPaymentUseCase _getPayment;

  @override
  PaymentState build() {
    final repo = ref.watch(paymentRepositoryProvider);
    _getPlans = GetPlansUseCase(repo);
    _tokenizeCard = TokenizeCardUseCase(ref.watch(cardTokenizerRepositoryProvider));
    _checkoutWithCard = CheckoutWithCardUseCase(repo);
    _checkoutWithCash = CheckoutWithCashUseCase(repo);
    _checkoutWithSpei = CheckoutWithSpeiUseCase(repo);
    _getPayment = GetPaymentUseCase(repo);
    return const PaymentState();
  }

  Future<void> loadPlans() async {
    state = state.copyWith(plansAsync: const AsyncValue.loading());
    state = state.copyWith(plansAsync: await AsyncValue.guard(_getPlans));
  }

  Future<bool> payWithCard({required String planId, required CardInput card}) async {
    state = state.copyWith(checkoutAsync: const AsyncValue.loading());
    try {
      final tokenId = await _tokenizeCard(card);
      final payment = await _checkoutWithCard(planId: planId, tokenId: tokenId);
      if (payment.status != PaymentStatus.paid) {
        state = state.copyWith(
          checkoutAsync: AsyncValue.error(const _CheckoutFailure('El pago no se pudo completar. Intenta con otra tarjeta.'), StackTrace.current),
        );
        return false;
      }
      state = state.copyWith(checkoutAsync: AsyncValue.data(payment));
      return true;
    } on CardTokenizationException catch (e, st) {
      state = state.copyWith(checkoutAsync: AsyncValue.error(e, st));
      return false;
    } on ApiException catch (e, st) {
      state = state.copyWith(checkoutAsync: AsyncValue.error(e, st));
      return false;
    } catch (_) {
      state = state.copyWith(
        checkoutAsync: AsyncValue.error(const _CheckoutFailure('No se pudo procesar el pago. Intenta de nuevo.'), StackTrace.current),
      );
      return false;
    }
  }

  Future<bool> payWithCash({required String planId}) async {
    state = state.copyWith(checkoutAsync: const AsyncValue.loading());
    try {
      final payment = await _checkoutWithCash(planId: planId);
      state = state.copyWith(checkoutAsync: AsyncValue.data(payment));
      return true;
    } on ApiException catch (e, st) {
      state = state.copyWith(checkoutAsync: AsyncValue.error(e, st));
      return false;
    } catch (_) {
      state = state.copyWith(
        checkoutAsync: AsyncValue.error(const _CheckoutFailure('No se pudo generar la referencia de pago. Intenta de nuevo.'), StackTrace.current),
      );
      return false;
    }
  }

  Future<bool> payWithSpei({required String planId}) async {
    state = state.copyWith(checkoutAsync: const AsyncValue.loading());
    try {
      final payment = await _checkoutWithSpei(planId: planId);
      state = state.copyWith(checkoutAsync: AsyncValue.data(payment));
      return true;
    } on ApiException catch (e, st) {
      state = state.copyWith(checkoutAsync: AsyncValue.error(e, st));
      return false;
    } catch (_) {
      state = state.copyWith(
        checkoutAsync: AsyncValue.error(const _CheckoutFailure('No se pudo generar la referencia de transferencia. Intenta de nuevo.'), StackTrace.current),
      );
      return false;
    }
  }

  Future<void> refreshPaymentStatus(String paymentId) async {
    try {
      final payment = await _getPayment(paymentId);
      state = state.copyWith(checkoutAsync: AsyncValue.data(payment));
    } catch (_) {
    }
  }

  void resetCheckout() => state = state.copyWith(checkoutAsync: const AsyncValue.data(null));
}

final paymentViewModelProvider = NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);
