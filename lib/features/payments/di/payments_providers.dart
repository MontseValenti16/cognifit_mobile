import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/conekta_tokenization_datasource.dart';
import '../data/datasources/payment_remote_datasource.dart';
import '../data/repositories/payment_repository_impl.dart';
import '../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(PaymentRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});

final cardTokenizerRepositoryProvider = Provider<CardTokenizerRepository>((ref) {
  return CardTokenizerRepositoryImpl(ConektaTokenizationDataSource());
});
