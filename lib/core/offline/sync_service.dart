import '../network/api_client.dart';
import '../../features/tests/data/datasources/screening_remote_datasource.dart';
import 'local_response_queue.dart';

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
          break;
        }
        try {
          await ds.diagnose(item.sessionId);
        } catch (_) {
        }
      }
    } finally {
      _syncing = false;
    }
  }
}
