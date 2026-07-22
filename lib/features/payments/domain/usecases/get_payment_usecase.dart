import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentUseCase {
  final PaymentRepository repository;
  const GetPaymentUseCase(this.repository);

  Future<PaymentEntity> call(String paymentId) => repository.getPayment(paymentId);
}
