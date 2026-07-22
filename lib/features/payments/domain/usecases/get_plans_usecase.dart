import '../entities/plan_entity.dart';
import '../repositories/payment_repository.dart';

class GetPlansUseCase {
  final PaymentRepository repository;
  const GetPlansUseCase(this.repository);

  Future<List<PlanEntity>> call() => repository.getPlans();
}
