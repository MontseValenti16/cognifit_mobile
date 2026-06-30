import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitorea el estado de red de forma continua (HU-FL-13).
/// Expone [isOnline] y un stream de cambios para que widgets/services reaccionen.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  /// Emite true cuando hay red, false cuando se pierde.
  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    onStatusChange.listen((online) => _isOnline = online);
  }
}
