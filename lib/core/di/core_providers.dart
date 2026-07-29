import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

/// Providers de infraestructura compartida (no pertenecen a ninguna
/// feature). Sustituyen a los dos singletons "de infra" que vivían en
/// ServiceLocator: TokenStorage y ApiClient. Todo lo demás (repos, casos de
/// uso, ViewModels) vive en `di/<feature>_providers.dart` dentro de cada
/// feature — ver ese patrón para el resto de la inyección de dependencias.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(tokenStorageProvider));
});
