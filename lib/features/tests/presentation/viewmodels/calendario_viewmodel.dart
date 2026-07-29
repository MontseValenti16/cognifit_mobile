import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/tests_providers.dart';
import '../../domain/entities/screening_entity.dart';
import '../../domain/usecases/get_calendario_usecase.dart';

/// Caso de uso puro de FutureProvider/AsyncNotifier: todo el estado de esta
/// pantalla ES el resultado de una única llamada async, así que en vez de
/// envolver un ViewModel en un AsyncValue como en el resto de las features,
/// el AsyncValue<List<...>> ES el estado — `build()` corre la carga sola,
/// sin un `cargar()` inicial disparado a mano desde initState.
class CalendarioNotifier extends AutoDisposeAsyncNotifier<List<CalendarioEntryEntity>> {
  @override
  Future<List<CalendarioEntryEntity>> build() {
    final getCalendario = GetCalendarioUseCase(ref.watch(screeningRepositoryProvider));
    return getCalendario();
  }
}

final calendarioViewModelProvider =
    AsyncNotifierProvider.autoDispose<CalendarioNotifier, List<CalendarioEntryEntity>>(CalendarioNotifier.new);
