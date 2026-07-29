import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

/// DI de la feature auth. `authViewModelProvider` (declarado en
/// `auth_viewmodel.dart`, junto a `AuthNotifier`/`AuthState`) NO es
/// autoDispose: es la sesión — debe sobrevivir mientras dure la app.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    AuthRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    ref.watch(tokenStorageProvider),
  );
});
