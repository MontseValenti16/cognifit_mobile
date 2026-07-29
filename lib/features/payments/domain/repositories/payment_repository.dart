import '../entities/payment_entity.dart';
import '../entities/plan_entity.dart';

abstract class PaymentRepository {
  Future<List<PlanEntity>> getPlans();
  Future<PaymentEntity> checkoutWithCard({required String planId, required String tokenId});
  Future<PaymentEntity> checkoutWithCash({required String planId});
  Future<PaymentEntity> getPayment(String paymentId);
  Future<List<PaymentEntity>> listPayments();
}

abstract class CardTokenizerRepository {
  Future<String> tokenize(CardInput card);
}
