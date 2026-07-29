import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/student_remote_datasource.dart';
import '../data/repositories/student_repository_impl.dart';
import '../domain/repositories/student_repository.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(StudentRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
