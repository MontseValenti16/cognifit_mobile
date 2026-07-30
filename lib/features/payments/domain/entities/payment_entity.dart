enum PaymentMethodType { card, cash, spei }

enum PaymentStatus { pending, paid, expired, canceled, failed, refunded }

PaymentMethodType paymentMethodFromString(String s) => switch (s) {
  'cash' => PaymentMethodType.cash,
  'spei' => PaymentMethodType.spei,
  _ => PaymentMethodType.card,
};

PaymentStatus paymentStatusFromString(String s) => switch (s) {
  'paid' => PaymentStatus.paid,
  'expired' => PaymentStatus.expired,
  'canceled' => PaymentStatus.canceled,
  'failed' => PaymentStatus.failed,
  'refunded' => PaymentStatus.refunded,
  _ => PaymentStatus.pending,
};

class PaymentEntity {
  final String id;
  final String planId;
  final PaymentMethodType methodType;
  final PaymentStatus status;
  final int amountCents;
  final String currency;
  final String? cashReference;
  final String? cashBarcodeUrl;
  final DateTime? cashExpiresAt;
  final String? speiClabe;
  final String? speiBank;
  final DateTime? speiExpiresAt;
  final DateTime? paidAt;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.planId,
    required this.methodType,
    required this.status,
    required this.amountCents,
    required this.currency,
    this.cashReference,
    this.cashBarcodeUrl,
    this.cashExpiresAt,
    this.speiClabe,
    this.speiBank,
    this.speiExpiresAt,
    this.paidAt,
    required this.createdAt,
  });
}

class CardInput {
  final String number;
  final int expMonth;
  final int expYear;
  final String cvc;
  final String cardholderName;

  const CardInput({
    required this.number,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
    required this.cardholderName,
  });
}
