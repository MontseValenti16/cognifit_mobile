import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tests/domain/usecases/get_session_items_usecase.dart';
import '../../../tests/domain/usecases/submit_responses_usecase.dart';
import '../../../tests/domain/usecases/diagnose_usecase.dart';

enum ExerciseStatus { idle, loading, active, submitting, completed, error }

/// Drives a single screening session: GET items -> collect answers ->
/// POST responses -> POST diagnose. Maps to API_UI_GUIA section 4 steps 3-5.
class ExerciseViewModel extends ChangeNotifier {
  final GetSessionItemsUseCase _getItems;
  final SubmitResponsesUseCase _submitResponses;
  final DiagnoseUseCase _diagnose;

  ExerciseViewModel({
    required GetSessionItemsUseCase getItems,
    required SubmitResponsesUseCase submitResponses,
    required DiagnoseUseCase diagnose,
  })  : _getItems = getItems, _submitResponses = submitResponses, _diagnose = diagnose;

  ExerciseStatus _status = ExerciseStatus.idle;
  String? _error;
  String? _sessionId;
  List<SessionItemEntity> _items = [];
  int _currentIndex = 0;
  final List<ItemResponseSubmission> _collected = [];
  DateTime? _itemStartedAt;
  String? _selectedAnswer;
  DiagnosisEntity? _diagnosis;

  ExerciseStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ExerciseStatus.loading;
  bool get isSubmitting => _status == ExerciseStatus.submitting;
  bool get isCompleted => _status == ExerciseStatus.completed;
  SessionItemEntity? get current => _items.isEmpty || _currentIndex >= _items.length ? null : _items[_currentIndex];
  int get currentIndex => _currentIndex;
  int get totalItems => _items.length;
  double get progress => _items.isEmpty ? 0 : _currentIndex / _items.length;
  String? get selectedAnswer => _selectedAnswer;
  DiagnosisEntity? get diagnosis => _diagnosis;

  Future<void> loadSession(String sessionId) async {
    _sessionId = sessionId;
    _status = ExerciseStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await _getItems(sessionId);
      _items = result.items;
      _currentIndex = 0;
      _collected.clear();
      _itemStartedAt = DateTime.now();
      _status = ExerciseStatus.active;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = ExerciseStatus.error;
    } catch (_) {
      _error = 'No se pudieron cargar los ítems de la sesión.'; _status = ExerciseStatus.error;
    }
    notifyListeners();
  }

  /// Records the answer locally; advances automatically.
  /// [captureModality] e.g. "tactil", "stt", "teclado" — per item.input_modes
  void answer(String rawResponse, {String captureModality = 'tactil', double? sttConfidence}) {
    if (current == null) return;
    final elapsed = DateTime.now().difference(_itemStartedAt ?? DateTime.now()).inMilliseconds;
    _collected.add(ItemResponseSubmission(
      itemId: current!.itemId,
      rawResponse: rawResponse,
      responseTimeMs: elapsed,
      captureModality: captureModality,
      sttConfidence: sttConfidence,
    ));
    _selectedAnswer = rawResponse;
    notifyListeners();
  }

  void nextItem() {
    _selectedAnswer = null;
    if (_currentIndex < _items.length - 1) {
      _currentIndex++;
      _itemStartedAt = DateTime.now();
      notifyListeners();
    } else {
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    if (_sessionId == null) return;
    _status = ExerciseStatus.submitting;
    notifyListeners();
    try {
      await _submitResponses(_sessionId!, _collected);
      _diagnosis = await _diagnose(_sessionId!);
      _status = ExerciseStatus.completed;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = ExerciseStatus.error;
    } catch (_) {
      _error = 'No se pudo generar el diagnóstico.'; _status = ExerciseStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _sessionId = null; _items = []; _currentIndex = 0; _collected.clear();
    _selectedAnswer = null; _diagnosis = null; _status = ExerciseStatus.idle;
    notifyListeners();
  }
}
