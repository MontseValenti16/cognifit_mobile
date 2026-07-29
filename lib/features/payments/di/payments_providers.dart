import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/conekta_tokenization_datasource.dart';
import '../data/datasources/payment_remote_datasource.dart';
import '../data/repositories/payment_repository_impl.dart';
import '../domain/repositories/payment_repository.dart';

/// DI de la feature payments. `paymentViewModelProvider` se declara junto a
/// `PaymentNotifier`/`PaymentState` en `presentation/viewmodels/payment_viewmodel.dart`.
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(PaymentRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});

/// Su propio Dio hacia api.conekta.io, nunca hacia nuestro backend — ver
/// conekta_tokenization_datasource.dart.
final cardTokenizerRepositoryProvider = Provider<CardTokenizerRepository>((ref) {
  return CardTokenizerRepositoryImpl(ConektaTokenizationDataSource());
});
