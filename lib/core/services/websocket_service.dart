import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _progressController = StreamController<WebSocketProgress>.broadcast();

  Stream<WebSocketMessage> get messages => _messageController.stream;
  Stream<WebSocketProgress> get progress => _progressController.stream;

  bool _isConnected = false;
  bool _isProcessing = false;
  bool _isConnecting = false;
  String? _currentStep;
  Map<String, dynamic>? _currentData;
  
  // Connection retry logic
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  Timer? _retryTimer;

  // Getters for current state
  bool get isConnected => _isConnected;
  bool get isProcessing => _isProcessing;
  bool get isConnecting => _isConnecting;
  String? get currentStep => _currentStep;
  Map<String, dynamic>? get currentData => _currentData;

  WebSocketService(this.url);

  /// Connect to the WebSocket server with retry logic
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;
    
    _isConnecting = true;
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Wait for connection to be established
      await _channel!.ready;
      
      _isConnected = true;
      _isConnecting = false;
      _retryCount = 0; // Reset retry count on successful connection

      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) {
          _handleError(error);
        },
        onDone: () {
          _handleDisconnect();
        },
        cancelOnError: false, // Don't cancel on error to allow retry logic
      );
    } catch (e) {
      _isConnecting = false;
      _handleError(e);
    }
  }

  /// Send data to the WebSocket server with connection management
  Future<void> send(Map<String, dynamic> data) async {
    if (!_isConnected) {
      await connect();
    }
    
    if (!_isConnected) {
      _handleError('Failed to establish WebSocket connection');
      return;
    }
    
    try {
      final jsonPayload = jsonEncode(data);
      _channel!.sink.add(jsonPayload);
    } catch (e) {
      _handleError(e);
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final messageStr = message.toString();
      
      final parsedData = _parseWebSocketMessage(messageStr);
      
      if (parsedData != null) {
        _updateProgress(parsedData);
        _messageController.add(WebSocketMessage(
          type: parsedData['type'] == 'complete' ? MessageType.complete : 
                parsedData['type'] == 'error' ? MessageType.error : 
                MessageType.progress,
          data: parsedData,
          rawMessage: messageStr,
        ));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  /// Parse WebSocket message to extract progress information
  Map<String, dynamic>? _parseWebSocketMessage(String message) {
    // First, try to parse as JSON
    try {
      final Map<String, dynamic> data = jsonDecode(message);

      // Keep original format with type field
      if (data['type'] == 'progress' && data['step'] != null) {
        return {
          'type': 'progress',
          'step': data['step'] as String,
          'status': data['status'] as String? ?? 'processing',
          'message': data['message'] as String? ?? '',
          'data': data['data'] as Map<String, dynamic>? ?? {},
        };
      } else if (data['type'] == 'error') {
        String errorMessage = 'An error occurred';
        if (data['error'] != null) {
          errorMessage = data['error'] as String;
        } else if (data['message'] != null) {
          errorMessage = data['message'] as String;
        }
        return {
          'type': 'error',
          'step': data['step'] as String? ?? '[[ERROR]]',
          'status': 'error',
          'message': errorMessage,
          'data': data,
        };
      } else if (data['type'] == 'complete') {
        return {
          'type': 'complete',
          'step': '[[DONE]]',
          'status': 'completed',
          'message': data['message'] as String? ?? 'Processing completed successfully',
          'data': data['data'] is Map ? Map<String, dynamic>.from(data['data']) : {},
        };
      }
    } catch (e) {
      // If JSON parsing fails, handle as plain text message
      print('WebSocket: Error parsing message: $e');
      print('WebSocket: Message: $message');
    }
    return null;
  }


  /// Update progress state and notify listeners
  void _updateProgress(Map<String, dynamic> parsedData) {
    _currentStep = parsedData['step'];
    _currentData = parsedData;
    
    if (parsedData['type'] == 'complete') {
      _isProcessing = false;
    } else if (parsedData['type'] == 'error') {
      _isProcessing = false;
    } else {
      _isProcessing = true;
    }
    
    _progressController.add(WebSocketProgress(
      step: _currentStep,
      isProcessing: _isProcessing,
      data: _currentData,
    ));
  }

  /// Handle WebSocket errors with retry logic
  void _handleError(dynamic error) {
    _isConnected = false;
    _isConnecting = false;
    
    // Don't retry if the error indicates a permanent failure
    if (error.toString().contains('WebSocket connection failed') || 
        error.toString().contains('Connection refused') ||
        error.toString().contains('Failed to establish')) {
      _messageController.add(WebSocketMessage(
        type: MessageType.error,
        data: {'error': 'WebSocket connection failed: $error'},
        rawMessage: error.toString(),
      ));
      return;
    }
    
    // Attempt retry if we haven't exceeded max retries
    if (_retryCount < maxRetries) {
      _retryCount++;    
      _retryTimer?.cancel();
      _retryTimer = Timer(retryDelay, () {
        connect();
      });
    } else {
      _messageController.add(WebSocketMessage(
        type: MessageType.error,
        data: {'error': 'WebSocket connection failed after $maxRetries attempts: $error'},
        rawMessage: error.toString(),
      ));
    }
  }

  /// Handle WebSocket disconnection
  void _handleDisconnect() {
    _isConnected = false;
    _isConnecting = false;
    
    _messageController.add(WebSocketMessage(
      type: MessageType.disconnected,
      data: {'message': 'Connection closed'},
      rawMessage: '[[DISCONNECTED]]',
    ));
  }

  /// Start processing (call this when you begin a new operation)
  void startProcessing() {
    _isProcessing = true;
    _currentStep = null;
    _currentData = null;
    _progressController.add(WebSocketProgress(
      step: null,
      isProcessing: true,
      data: null,
    ));
  }

  /// Reset all state
  void reset() {
    _isProcessing = false;
    _currentStep = null;
    _currentData = null;
    _retryCount = 0;
    _retryTimer?.cancel();
    
    _progressController.add(WebSocketProgress(
      step: null,
      isProcessing: false,
      data: null,
    ));
  }

  /// Disconnect from the WebSocket server
  void disconnect() {
    _retryTimer?.cancel();
    
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.close(status.normalClosure);
      } catch (e) {
        print('WebSocket: Error during disconnect: $e');
      }
    }
    
    _isConnected = false;
    _isConnecting = false;
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _messageController.close();
    _progressController.close();
  }
}

/// Represents a WebSocket message with type and data
class WebSocketMessage {
  final MessageType type;
  final Map<String, dynamic> data;
  final String rawMessage;

  WebSocketMessage({
    required this.type,
    required this.data,
    required this.rawMessage,
  });
}

/// Represents WebSocket progress state
class WebSocketProgress {
  final String? step;
  final bool isProcessing;
  final Map<String, dynamic>? data;

  WebSocketProgress({
    this.step,
    required this.isProcessing,
    this.data,
  });
}

/// Types of WebSocket messages
enum MessageType {
  progress,
  complete,
  error,
  disconnected,
}
