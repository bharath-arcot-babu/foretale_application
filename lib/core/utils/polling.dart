import 'dart:async';

/// A utility class for handling polling operations
class PollingService {
  Timer? _timer;
  bool _isPolling = false;
  int _attempts = 0;


  Future<void> startPolling({
    required Future<void> Function() pollFunction,
    int interval = 5000,
    int maxAttempts = 10,

  }) async {
    if (_isPolling) return;
    
    _isPolling = true;
    _attempts = 0;

    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) async {
      try {
        _attempts++;
        
        await pollFunction();
        
        if (_attempts >= maxAttempts) {
          stopPolling();
        }
        
      } catch (error) {
        stopPolling();
      }
    });
  }

  /// Stops the polling operation
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _isPolling = false;
  }

  /// Checks if polling is currently active
  bool get isPolling => _isPolling;

  /// Gets the current number of attempts
  int get attempts => _attempts;
}
