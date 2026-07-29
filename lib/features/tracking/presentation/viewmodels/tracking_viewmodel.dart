import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/tracking_providers.dart';
import '../../domain/entities/tracking_entity.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../domain/usecases/mark_alert_read_usecase.dart';
import '../../domain/usecases/get_group_metrics_usecase.dart';

class TrackingState {
  final AsyncValue<List<AlertEntity>> alertsAsync;
  final GroupMetricsEntity? groupMetrics;

  const TrackingState({this.alertsAsync = const AsyncValue.data([]), this.groupMetrics});

  List<AlertEntity> get alerts => alertsAsync.valueOrNull ?? const [];
  List<AlertEntity> get unreadAlerts => alerts.where((a) => !a.isRead).toList();
  bool get isLoading => alertsAsync.isLoading;

  TrackingState copyWith({AsyncValue<List<AlertEntity>>? alertsAsync, GroupMetricsEntity? groupMetrics}) {
    return TrackingState(
      alertsAsync: alertsAsync ?? this.alertsAsync,
      groupMetrics: groupMetrics ?? this.groupMetrics,
    );
  }
}

class TrackingNotifier extends Notifier<TrackingState> {
  late GetAlertsUseCase _getAlerts;
  late MarkAlertReadUseCase _markAlertRead;
  late GetGroupMetricsUseCase _getGroupMetrics;

  @override
  TrackingState build() {
    final repo = ref.watch(trackingRepositoryProvider);
    _getAlerts = GetAlertsUseCase(repo);
    _markAlertRead = MarkAlertReadUseCase(repo);
    _getGroupMetrics = GetGroupMetricsUseCase(repo);
    return const TrackingState();
  }

  Future<void> loadAlerts({bool onlyUnread = false}) async {
    state = state.copyWith(alertsAsync: const AsyncValue.loading());
    state = state.copyWith(alertsAsync: await AsyncValue.guard(() => _getAlerts(onlyUnread: onlyUnread)));
  }

  Future<void> loadGroupMetrics(String groupId) async {
    try {
      final metrics = await _getGroupMetrics(groupId);
      state = state.copyWith(groupMetrics: metrics);
    } catch (_) {}
  }

  Future<void> markRead(String alertId) async {
    try {
      final updated = await _markAlertRead(alertId);
      final list = state.alerts.map((a) => a.id == alertId ? updated : a).toList();
      state = state.copyWith(alertsAsync: AsyncValue.data(list));
    } catch (_) {}
  }
}

final trackingViewModelProvider = NotifierProvider<TrackingNotifier, TrackingState>(TrackingNotifier.new);
