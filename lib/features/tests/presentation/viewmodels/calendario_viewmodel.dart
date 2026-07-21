import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/screening_entity.dart';
import '../../domain/usecases/get_calendario_usecase.dart';

enum CalendarioStatus { loading, loaded, error }

class CalendarioViewModel extends ChangeNotifier {
  final GetCalendarioUseCase _getCalendario;
  CalendarioViewModel({required GetCalendarioUseCase getCalendario})
      : _getCalendario = getCalendario;

  CalendarioStatus status = CalendarioStatus.loading;
  List<CalendarioEntryEntity> entradas = [];
  String? error;

  Future<void> cargar() async {
    status = CalendarioStatus.loading;
    notifyListeners();
    try {
      entradas = await _getCalendario();
      status = CalendarioStatus.loaded;
    } on ApiException catch (e) {
      error = e.statusCode == 503 || e.statusCode == 502
          ? 'El servicio no está disponible. No es tu conexión.'
          : 'No se pudo cargar el calendario.';
      status = CalendarioStatus.error;
    } catch (_) {
      error = 'No se pudo cargar el calendario.';
      status = CalendarioStatus.error;
    }
    notifyListeners();
  }
}
