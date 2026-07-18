import '../network/api_client.dart';
import '../../features/tests/data/datasources/screening_remote_datasource.dart';
import 'local_response_queue.dart';

/// Drains [LocalResponseQueue] by re-submitting pending responses when online.
/// Called at app start and whenever connectivity is restored (HU-FL-13).
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  bool _syncing = false;

  Future<void> syncPending(ApiClient client) async {
    if (_syncing) return;
    _syncing = true;
    try {
      final pending = await LocalResponseQueue.instance.getAll();
      if (pending.isEmpty) return;
      final ds = ScreeningRemoteDataSourceImpl(client);
      for (final item in pending) {
        try {
          await ds.submitResponses(item.sessionId, item.responses);
          await LocalResponseQueue.instance.remove(item.id);
        } catch (_) {
          // Keep in queue; will retry next sync cycle.
          break;
        }
        // Sin este diagnose, una sesión terminada sin conexión se quedaba para
        // siempre sin diagnóstico: al finalizarla, ExerciseViewModel llamó a
        // diagnose() sobre una sesión cuyas respuestas todavía no habían salido
        // del dispositivo, y ese intento se perdió. Va fuera del try de arriba
        // para no reencolar respuestas que YA se enviaron correctamente.
        try {
          await ds.diagnose(item.sessionId);
        } catch (_) {
          // Reintentable: no debe bloquear el resto de la cola.
        }
      }
    } finally {
      _syncing = false;
    }
  }
}
