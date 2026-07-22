import '../entities/payment_entity.dart';
import '../entities/plan_entity.dart';

abstract class PaymentRepository {
  Future<List<PlanEntity>> getPlans();
  Future<PaymentEntity> checkoutWithCard({required String planId, required String tokenId});
  Future<PaymentEntity> checkoutWithCash({required String planId});
  Future<PaymentEntity> getPayment(String paymentId);
  Future<List<PaymentEntity>> listPayments();
}

/// Frontera aparte de PaymentRepository a propósito: tokenizar habla con la
/// API de Conekta (api.conekta.io), no con nuestro backend. Mezclarlo en el
/// mismo repositorio sugeriría que ambos comparten servidor y credenciales,
/// y no es así — ver ConektaTokenizationDataSource.
abstract class CardTokenizerRepository {
  Future<String> tokenize(CardInput card);
}
