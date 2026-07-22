import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.planId,
    required super.methodType,
    required super.status,
    required super.amountCents,
    required super.currency,
    super.cashReference,
    super.cashBarcodeUrl,
    super.cashExpiresAt,
    super.paidAt,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'].toString(),
    planId: json['plan_id'].toString(),
    methodType: paymentMethodFromString(json['payment_method_type'] as String),
    status: paymentStatusFromString(json['status'] as String),
    amountCents: json['amount_cents'] as int,
    currency: json['currency'] as String? ?? 'MXN',
    cashReference: json['cash_reference'] as String?,
    cashBarcodeUrl: json['cash_barcode_url'] as String?,
    cashExpiresAt: json['cash_expires_at'] != null ? DateTime.tryParse(json['cash_expires_at'].toString()) : null,
    paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
    createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
  );
}
