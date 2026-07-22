enum PaymentMethodType { card, cash }

enum PaymentStatus { pending, paid, expired, canceled, failed, refunded }

PaymentMethodType paymentMethodFromString(String s) =>
    s == 'cash' ? PaymentMethodType.cash : PaymentMethodType.card;

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
    this.paidAt,
    required this.createdAt,
  });
}

/// Parámetros de una tarjeta capturados en el formulario. Vive solo en
/// memoria el tiempo suficiente para tokenizar contra Conekta — nunca se
/// serializa ni se guarda en storage.
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
