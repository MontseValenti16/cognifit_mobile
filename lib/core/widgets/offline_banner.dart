import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin animated banner shown at the top of screens when there is no network.
/// Subscribes to connectivity changes itself — just drop it into any Column.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted && offline != _isOffline) setState(() => _isOffline = offline);
    });
    Connectivity().checkConnectivity().then((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted && offline != _isOffline) setState(() => _isOffline = offline);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: const Color(0xFFB00020),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text('Sin conexión — las respuestas se guardan localmente',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
