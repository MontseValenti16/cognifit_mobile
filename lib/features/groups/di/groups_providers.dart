import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/group_remote_datasource.dart';
import '../data/repositories/group_repository_impl.dart';
import '../domain/repositories/group_repository.dart';

/// DI de la feature groups. No tiene ViewModel propio (se administra desde
/// students/tests/dashboard), pero sí su propio repositorio — lo consumen
/// varias features, así que vive aquí como el resto de la app modular.
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(GroupRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
