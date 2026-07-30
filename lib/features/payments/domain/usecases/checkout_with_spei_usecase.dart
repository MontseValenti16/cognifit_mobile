import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class CheckoutWithSpeiUseCase {
  final PaymentRepository repository;
  const CheckoutWithSpeiUseCase(this.repository);

  Future<PaymentEntity> call({required String planId}) => repository.checkoutWithSpei(planId: planId);
}
