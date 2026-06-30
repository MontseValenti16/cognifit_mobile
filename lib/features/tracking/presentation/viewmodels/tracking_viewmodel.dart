import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/tracking_entity.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../domain/usecases/mark_alert_read_usecase.dart';
import '../../domain/usecases/get_group_metrics_usecase.dart';

enum TrackingStatus { idle, loading, loaded, error }

class TrackingViewModel extends ChangeNotifier {
  final GetAlertsUseCase _getAlerts;
  final MarkAlertReadUseCase _markAlertRead;
  final GetGroupMetricsUseCase _getGroupMetrics;

  TrackingViewModel({
    required GetAlertsUseCase getAlerts,
    required MarkAlertReadUseCase markAlertRead,
    required GetGroupMetricsUseCase getGroupMetrics,
  })  : _getAlerts = getAlerts, _markAlertRead = markAlertRead, _getGroupMetrics = getGroupMetrics;

  TrackingStatus _status = TrackingStatus.idle;
  List<AlertEntity> _alerts = [];
  GroupMetricsEntity? _groupMetrics;
  String? _error;

  TrackingStatus get status => _status;
  List<AlertEntity> get alerts => _alerts;
  List<AlertEntity> get unreadAlerts => _alerts.where((a) => !a.isRead).toList();
  GroupMetricsEntity? get groupMetrics => _groupMetrics;
  String? get error => _error;
  bool get isLoading => _status == TrackingStatus.loading;

  Future<void> loadAlerts({bool onlyUnread = false}) async {
    _status = TrackingStatus.loading; notifyListeners();
    try {
      _alerts = await _getAlerts(onlyUnread: onlyUnread);
      _status = TrackingStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = TrackingStatus.error;
    } catch (_) {
      _error = 'No se pudieron cargar las alertas.'; _status = TrackingStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadGroupMetrics(String groupId) async {
    try {
      _groupMetrics = await _getGroupMetrics(groupId);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage; notifyListeners();
    } catch (_) {}
  }

  Future<void> markRead(String alertId) async {
    try {
      final updated = await _markAlertRead(alertId);
      _alerts = _alerts.map((a) => a.id == alertId ? updated : a).toList();
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage; notifyListeners();
    }
  }
}
