import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_config.dart';
import '../../domain/entities/payment_entity.dart';

class CardTokenizationException implements Exception {
  final String userMessage;
  const CardTokenizationException(this.userMessage);
  @override
  String toString() => userMessage;
}

class ConektaTokenizationDataSource {
  late final Dio _dio;

  ConektaTokenizationDataSource() {
    final auth = base64Encode(utf8.encode('${ApiConfig.conektaPublicKey}:'));
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.conektaBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': 'Basic $auth',
        'Accept': 'application/vnd.conekta-v${ApiConfig.conektaApiVersion}+json',
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<String> tokenize(CardInput card) async {
    try {
      final response = await _dio.post('/tokens', data: {
        'card': {
          'number': card.number.replaceAll(' ', ''),
          'name': card.cardholderName,
          'exp_month': card.expMonth.toString().padLeft(2, '0'),
          'exp_year': card.expYear.toString(),
          'cvc': card.cvc,
        },
      });
      final id = response.data['id'] as String?;
      if (id == null) throw const CardTokenizationException('No se pudo procesar la tarjeta. Intenta de nuevo.');
      return id;
    } on DioException catch (e) {
      throw CardTokenizationException(_messageFrom(e));
    }
  }

  String _messageFrom(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'No se pudo conectar con la pasarela de pago. Verifica tu conexión.';
    }
    return 'Los datos de la tarjeta no son válidos: revisa el número, la fecha y el CVC.';
  }
}
