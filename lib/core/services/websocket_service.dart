import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// A reusable WebSocket service for managing connection, sending, and receiving messages.
class WebSocketService {
  final String url;
  late WebSocketChannel _channel;
  final _streamController = StreamController<String>.broadcast();

  Stream<String> get messages => _streamController.stream;

  bool _isConnected = false;

  WebSocketService(this.url);

  /// Connect to the WebSocket server
  void connect() {
    if (_isConnected) return;
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;

    _channel.stream.listen(
      (message) {
        _streamController.add(message);
      },
      onError: (error) {
        _streamController.addError(error);
        disconnect();
      },
      onDone: () {
        _isConnected = false;
        _streamController.add("[[DISCONNECTED]]");
      },
    );
  }

  /// Send data to the WebSocket server
  void send(Map<String, dynamic> data) {
    if (!_isConnected) {
      connect();
    }
    final jsonPayload = jsonEncode(data);
    _channel.sink.add(jsonPayload);
  }

  /// Disconnect from the WebSocket server
  void disconnect() {
    if (_isConnected) {
      _channel.sink.close(status.normalClosure);
      _isConnected = false;
    }
  }

  /// Clean up
  void dispose() {
    disconnect();
    _streamController.close();
  }
}
