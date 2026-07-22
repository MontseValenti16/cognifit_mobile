import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/conekta_tokenization_datasource.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remote;
  const PaymentRepositoryImpl(this.remote);

  @override
  Future<List<PlanEntity>> getPlans() => remote.getPlans();

  @override
  Future<PaymentEntity> checkoutWithCard({required String planId, required String tokenId}) =>
      remote.checkoutWithCard(planId: planId, tokenId: tokenId);

  @override
  Future<PaymentEntity> checkoutWithCash({required String planId}) => remote.checkoutWithCash(planId: planId);

  @override
  Future<PaymentEntity> getPayment(String paymentId) => remote.getPayment(paymentId);

  @override
  Future<List<PaymentEntity>> listPayments() => remote.listPayments();
}

class CardTokenizerRepositoryImpl implements CardTokenizerRepository {
  final ConektaTokenizationDataSource datasource;
  const CardTokenizerRepositoryImpl(this.datasource);

  @override
  Future<String> tokenize(CardInput card) => datasource.tokenize(card);
}
