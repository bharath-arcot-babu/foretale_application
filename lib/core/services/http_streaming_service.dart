import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpTransportService {
  final String url;
  
  HttpTransportService(this.url);
  
  /// Sends data to the HTTP streaming endpoint and returns a stream of raw response lines
  Stream<String> sendRequest(Map<String, dynamic> data) async* {
    final request = http.Request('POST', Uri.parse(url))
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = jsonEncode(data);

    final streamedResponse = await request.send();
    
    await for (var line in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
        yield line;
    }
  }
}

/// Handles parsing and processing of streaming messages
class MessageProcessor {
  final StreamController<StreamingMessage> _messageController;
  final StreamController<StreamingProgress> _progressController;
  
  MessageProcessor(this._messageController, this._progressController);
  
  /// Processes a raw JSON string and emits appropriate events
  void processMessage(String jsonStr) {
    try {
      print('JSON String: $jsonStr');
      final parsedData = jsonDecode(jsonStr);
      _handleParsedMessage(parsedData);
    } catch (e) {
      _emitError('Failed to parse JSON: ${e.toString()}');
    }
  }
  
  /// Handles parsed message data
  void _handleParsedMessage(Map<String, dynamic> parsedData) {
      final type = parsedData['type'] as String? ?? 'error';
      final step = parsedData['step'] as String?;
      final message = parsedData['message'] as String?;
      final currentField = parsedData['data']?['current_field'] as String?;
      final streamingText = parsedData['data']?['message'] as String?;

      final messageType = MessageType.values.byName(type);

      _updateProgress(type, step, message);
      _emitMessage(messageType, step, currentField, streamingText ?? message);
  }
  
  /// Updates progress state
  void _updateProgress(String type, String? step, String? message) {
    final isProcessing = (type != 'complete' && type != 'error');
    
    _progressController.add(StreamingProgress(
      step: step,
      isProcessing: isProcessing,
      status: message,
    ));
  }
  
  /// Emits a streaming message
  void _emitMessage(MessageType type, String? step, String? currentField, String? message) {
    _messageController.add(StreamingMessage(
      type: type,
      step: step,
      currentField: currentField,
      message: message,
    ));
  }
  
  /// Emits an error message
  void _emitError(String error) {
    _messageController.add(StreamingMessage(
      type: MessageType.error,
      step: null,
      currentField: null,
      message: error,
    ));
  }
}

/// Main service that orchestrates HTTP transport and message processing
class HttpStreamingService {
  final HttpTransportService _transportService;
  final MessageProcessor _messageProcessor;
  final _messageController = StreamController<StreamingMessage>.broadcast();
  final _progressController = StreamController<StreamingProgress>.broadcast();

  Stream<StreamingMessage> get messages => _messageController.stream;
  Stream<StreamingProgress> get progress => _progressController.stream;

  bool _isConnected = false;
  bool _isProcessing = false;
  
  // Getters for current state
  bool get isConnected => _isConnected;
  bool get isProcessing => _isProcessing;

  HttpStreamingService(String url): 
      _transportService = HttpTransportService(url),
      _messageProcessor = MessageProcessor(
        StreamController<StreamingMessage>.broadcast(),
        StreamController<StreamingProgress>.broadcast()
      ) {
    // Connect message processor to main controllers
    _messageProcessor._messageController.stream.listen((message) => _messageController.add(message));
    _messageProcessor._progressController.stream.listen((progress) => _progressController.add(progress));
  }

  /// Send data to the HTTP streaming endpoint
  Future<void> send(Map<String, dynamic> data) async {
    try {
      _isConnected = true;
      
      await for (var jsonStr in _transportService.sendRequest(data)) {
        _messageProcessor.processMessage(jsonStr);
      }
    } catch (e) {
      _handleError(e.toString());
    } finally {
      // Update connection state when processing is complete
      _isConnected = false;
    }
  }

  /// Handle streaming errors
  void _handleError(String error) {
    _isConnected = false;
    _isProcessing = false;
    
    _messageController.add(StreamingMessage(
      type: MessageType.error,
      step: null,
      currentField: null,
      message: error,
    ));
  }

  /// Start processing (call this when you begin a new operation)
  void startProcessing() {
    _isProcessing = true;
    _progressController.add(StreamingProgress(
      step: null,
      isProcessing: true,
      status: null,
    ));
  }

  /// Reset all state
  void reset() {
    _isProcessing = false;
    _progressController.add(StreamingProgress(
      step: null,
      isProcessing: false,
      status: null,
    ));
  }

  /// Clean up resources
  void dispose() {
    _messageController.close();
    _progressController.close();
  }
}

/// Represents a streaming message with type and data
class StreamingMessage {
  final MessageType type;
  final String? step;
  final String? currentField;
  final String? message;

  StreamingMessage({
    required this.type,
    this.step,
    this.currentField,
    this.message,
  });
}

/// Represents streaming progress state
class StreamingProgress {
  final String? step;
  final bool isProcessing;
  final String? status;

  StreamingProgress({
    this.step,
    required this.isProcessing,
    this.status,
  });
}

/// Types of streaming messages
enum MessageType {
  progress,
  complete,
  error,
} 