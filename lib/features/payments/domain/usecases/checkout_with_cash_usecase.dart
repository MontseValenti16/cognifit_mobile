import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class CheckoutWithCashUseCase {
  final PaymentRepository repository;
  const CheckoutWithCashUseCase(this.repository);

  Future<PaymentEntity> call({required String planId}) => repository.checkoutWithCash(planId: planId);
}
