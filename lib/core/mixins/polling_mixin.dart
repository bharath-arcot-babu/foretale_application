import 'dart:async';
import 'package:flutter/material.dart';

mixin PollingMixin on ChangeNotifier {
  Timer? _pollingTimer;
  bool _isPolling = false;
  Duration _pollingInterval = const Duration(seconds: 30);

  bool get isPolling => _isPolling;
  Duration get pollingInterval => _pollingInterval;
  bool _isFetching = false;

  /// Start polling with the given fetch function
 void startPolling(BuildContext context, Future<void> Function(BuildContext) fetchFunction) {
  if (!_isPolling) {
    _isPolling = true;
    _pollingTimer = Timer.periodic(_pollingInterval, (_) async {
      if (_isFetching) return;
      _isFetching = true;
      try {
        await fetchFunction(context);
      } catch (e) {
        debugPrint('Polling error: $e');
      } finally {
        _isFetching = false;
      }
    });
    notifyListeners();
  }
}

  /// Stop the polling
  void stopPolling() {
    if (_isPolling) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
      _isPolling = false;
      notifyListeners();
    }
  }

  /// Set a new polling interval
  void setPollingInterval(Duration interval) {
    _pollingInterval = interval;
    if (_isPolling) {
      stopPolling();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
} 