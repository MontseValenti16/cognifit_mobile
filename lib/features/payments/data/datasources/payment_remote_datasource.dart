import '../../../../core/network/api_client.dart';
import '../models/payment_model.dart';
import '../models/plan_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PlanModel>> getPlans();
  Future<PaymentModel> checkoutWithCard({required String planId, required String tokenId});
  Future<PaymentModel> checkoutWithCash({required String planId});
  Future<PaymentModel> getPayment(String paymentId);
  Future<List<PaymentModel>> listPayments();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient client;
  const PaymentRemoteDataSourceImpl(this.client);

  @override
  Future<List<PlanModel>> getPlans() async {
    final json = await client.get('/payments/plans');
    return (json as List).map((e) => PlanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PaymentModel> checkoutWithCard({required String planId, required String tokenId}) async {
    final json = await client.post('/payments/checkout/card', data: {
      'plan_id': planId,
      'token_id': tokenId,
    });
    return PaymentModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<PaymentModel> checkoutWithCash({required String planId}) async {
    final json = await client.post('/payments/checkout/cash', data: {'plan_id': planId});
    return PaymentModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<PaymentModel> getPayment(String paymentId) async {
    final json = await client.get('/payments/$paymentId');
    return PaymentModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<PaymentModel>> listPayments() async {
    final json = await client.get('/payments');
    return (json as List).map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
