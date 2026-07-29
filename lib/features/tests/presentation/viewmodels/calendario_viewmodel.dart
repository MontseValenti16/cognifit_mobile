import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/tests_providers.dart';
import '../../domain/entities/screening_entity.dart';
import '../../domain/usecases/get_calendario_usecase.dart';

class CalendarioNotifier extends AutoDisposeAsyncNotifier<List<CalendarioEntryEntity>> {
  @override
  Future<List<CalendarioEntryEntity>> build() {
    final getCalendario = GetCalendarioUseCase(ref.watch(screeningRepositoryProvider));
    return getCalendario();
  }
}

final calendarioViewModelProvider =
    AsyncNotifierProvider.autoDispose<CalendarioNotifier, List<CalendarioEntryEntity>>(CalendarioNotifier.new);
