import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class CheckoutWithCardUseCase {
  final PaymentRepository repository;
  const CheckoutWithCardUseCase(this.repository);

  Future<PaymentEntity> call({required String planId, required String tokenId}) =>
      repository.checkoutWithCard(planId: planId, tokenId: tokenId);
}
