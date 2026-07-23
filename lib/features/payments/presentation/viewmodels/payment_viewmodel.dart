import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../data/datasources/conekta_tokenization_datasource.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/usecases/checkout_with_card_usecase.dart';
import '../../domain/usecases/checkout_with_cash_usecase.dart';
import '../../domain/usecases/get_payment_usecase.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/tokenize_card_usecase.dart';

enum PlansStatus { idle, loading, loaded, error }

enum CheckoutStatus { idle, tokenizing, processing, success, error }

class PaymentViewModel extends ChangeNotifier {
  final GetPlansUseCase _getPlans;
  final TokenizeCardUseCase _tokenizeCard;
  final CheckoutWithCardUseCase _checkoutWithCard;
  final CheckoutWithCashUseCase _checkoutWithCash;
  final GetPaymentUseCase _getPayment;

  PaymentViewModel({
    required GetPlansUseCase getPlans,
    required TokenizeCardUseCase tokenizeCard,
    required CheckoutWithCardUseCase checkoutWithCard,
    required CheckoutWithCashUseCase checkoutWithCash,
    required GetPaymentUseCase getPayment,
  })  : _getPlans = getPlans,
        _tokenizeCard = tokenizeCard,
        _checkoutWithCard = checkoutWithCard,
        _checkoutWithCash = checkoutWithCash,
        _getPayment = getPayment;

  PlansStatus plansStatus = PlansStatus.idle;
  List<PlanEntity> plans = [];
  String? plansError;

  CheckoutStatus checkoutStatus = CheckoutStatus.idle;
  String? checkoutError;
  PaymentEntity? lastPayment;

  Future<void> loadPlans() async {
    plansStatus = PlansStatus.loading;
    plansError = null;
    notifyListeners();
    try {
      plans = await _getPlans();
      plansStatus = PlansStatus.loaded;
    } on ApiException catch (e) {
      plansStatus = PlansStatus.error;
      plansError = e.userMessage;
    } catch (_) {
      plansStatus = PlansStatus.error;
      plansError = 'No se pudieron cargar los planes disponibles.';
    }
    notifyListeners();
  }

  Future<bool> payWithCard({required String planId, required CardInput card}) async {
    checkoutStatus = CheckoutStatus.tokenizing;
    checkoutError = null;
    notifyListeners();
    try {
      final tokenId = await _tokenizeCard(card);
      checkoutStatus = CheckoutStatus.processing;
      notifyListeners();
      lastPayment = await _checkoutWithCard(planId: planId, tokenId: tokenId);
      checkoutStatus = lastPayment!.status == PaymentStatus.paid ? CheckoutStatus.success : CheckoutStatus.error;
      if (checkoutStatus == CheckoutStatus.error) {
        checkoutError = 'El pago no se pudo completar. Intenta con otra tarjeta.';
      }
      return checkoutStatus == CheckoutStatus.success;
    } on CardTokenizationException catch (e) {
      checkoutStatus = CheckoutStatus.error;
      checkoutError = e.userMessage;
      return false;
    } on ApiException catch (e) {
      checkoutStatus = CheckoutStatus.error;
      checkoutError = e.userMessage;
      return false;
    } catch (_) {
      checkoutStatus = CheckoutStatus.error;
      checkoutError = 'No se pudo procesar el pago. Intenta de nuevo.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> payWithCash({required String planId}) async {
    checkoutStatus = CheckoutStatus.processing;
    checkoutError = null;
    notifyListeners();
    try {
      lastPayment = await _checkoutWithCash(planId: planId);
      // Efectivo siempre queda 'pending' al responder: la confirmación llega
      // por webhook cuando el ADMIN paga físicamente en OXXO.
      checkoutStatus = CheckoutStatus.success;
      return true;
    } on ApiException catch (e) {
      checkoutStatus = CheckoutStatus.error;
      checkoutError = e.userMessage;
      return false;
    } catch (_) {
      checkoutStatus = CheckoutStatus.error;
      checkoutError = 'No se pudo generar la referencia de pago. Intenta de nuevo.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshPaymentStatus(String paymentId) async {
    try {
      lastPayment = await _getPayment(paymentId);
      notifyListeners();
    } catch (_) {
      // Silencioso: el polling reintenta solo, un error de red pasajero no
      // debe tirar un snackbar en cada intento.
    }
  }

  void resetCheckout() {
    checkoutStatus = CheckoutStatus.idle;
    checkoutError = null;
    lastPayment = null;
    notifyListeners();
  }
}
