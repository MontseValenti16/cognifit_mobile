import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/tests/domain/entities/screening_entity.dart';

class PendingSubmission {
  final int id;
  final String sessionId;
  final List<ItemResponseSubmission> responses;

  const PendingSubmission({required this.id, required this.sessionId, required this.responses});
}

/// SQLite queue for session responses collected while offline (HU-FL-13).
/// Entries are drained by [SyncService] once connectivity is restored.
class LocalResponseQueue {
  LocalResponseQueue._();
  static final LocalResponseQueue instance = LocalResponseQueue._();

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase(
      '${dir.path}/cognifit_offline.db',
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE pending_responses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT NOT NULL,
          responses_json TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      '''),
    );
    return _db!;
  }

  Future<void> enqueue(String sessionId, List<ItemResponseSubmission> responses) async {
    final db = await _open();
    await db.insert('pending_responses', {
      'session_id': sessionId,
      'responses_json': jsonEncode(responses.map(_submissionToJson).toList()),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<PendingSubmission>> getAll() async {
    final db = await _open();
    final rows = await db.query('pending_responses', orderBy: 'created_at ASC');
    return rows.map((r) {
      final raw = jsonDecode(r['responses_json'] as String) as List;
      return PendingSubmission(
        id: r['id'] as int,
        sessionId: r['session_id'] as String,
        responses: raw.map((j) => _submissionFromJson(j as Map<String, dynamic>)).toList(),
      );
    }).toList();
  }

  Future<void> remove(int id) async {
    final db = await _open();
    await db.delete('pending_responses', where: 'id = ?', whereArgs: [id]);
  }

  // ── JSON helpers ─────────────────────────────────────────────────────────────

  static Map<String, dynamic> _submissionToJson(ItemResponseSubmission s) => {
    'item_id': s.itemId,
    'raw_response': s.rawResponse,
    'response_time_ms': s.responseTimeMs,
    'capture_modality': s.captureModality,
    if (s.sttConfidence != null) 'stt_confidence': s.sttConfidence,
  };

  static ItemResponseSubmission _submissionFromJson(Map<String, dynamic> j) =>
      ItemResponseSubmission(
        itemId: j['item_id'] as String,
        rawResponse: j['raw_response'] as String,
        responseTimeMs: j['response_time_ms'] as int,
        captureModality: j['capture_modality'] as String,
        sttConfidence: (j['stt_confidence'] as num?)?.toDouble(),
      );
}
