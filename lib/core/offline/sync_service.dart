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
      }
    } finally {
      _syncing = false;
    }
  }
}
