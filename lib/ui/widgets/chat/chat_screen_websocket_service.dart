import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/websocket_service.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';

class ChatScreenWebSocketService {
  final ChatDrivingModel drivingModel;
  final BuildContext context;
  final bool enableWebSocket;
  
  WebSocketService? _webSocketService;
  bool _websocketDisabled = false;
  bool _isWebsocketProcessing = false;
  bool _isInputDisabled = false;
  String? _websocketProgress;
  Map<String, dynamic>? _websocketData;

  // Callbacks
  final VoidCallback? onStateChanged;
  final Function(String)? onProgressUpdate;
  final Function(Map<String, dynamic>)? onDataUpdate;

  ChatScreenWebSocketService({
    required this.drivingModel,
    required this.context,
    required this.enableWebSocket,
    this.onStateChanged,
    this.onProgressUpdate,
    this.onDataUpdate,
  });

  // Getters
  WebSocketService? get webSocketService => _webSocketService;
  bool get websocketDisabled => _websocketDisabled;
  bool get isWebsocketProcessing => _isWebsocketProcessing;
  bool get isInputDisabled => _isInputDisabled;
  String? get websocketProgress => _websocketProgress;
  Map<String, dynamic>? get websocketData => _websocketData;

  void initialize() {
    if (!enableWebSocket || _websocketDisabled) {
      return;
    }
    
    try {
      final webSocketUrl = drivingModel.getWebSocketUrl(context);
      if (webSocketUrl.isEmpty) {
        return;
      }
      
      _webSocketService = WebSocketService(webSocketUrl);
      _setupWebSocketListeners();
      _webSocketService!.connect().catchError((error) {
        _websocketDisabled = true;
        _webSocketService = null;
        _notifyStateChanged();
      });

    } catch (e) {
      _websocketDisabled = true;
      _webSocketService = null;
      _notifyStateChanged();
    }
  }

  void _setupWebSocketListeners() {
    if (_webSocketService == null) return;
    
    // Listen to progress updates
    _webSocketService!.progress.listen(
      (progress) {
        _websocketProgress = progress.step;
        _isWebsocketProcessing = progress.isProcessing;
        _websocketData = progress.data;
        _isInputDisabled = progress.isProcessing;
        
        onProgressUpdate?.call(progress.step ?? '');
        onDataUpdate?.call(progress.data ?? {});
        _notifyStateChanged();
      },
      onError: (error, stackTrace) {
        SnackbarMessage.showErrorMessage(
          context,
          "WebSocket Error: $error",
          logError: true,
          errorMessage: "WebSocket Error: $error",
          errorStackTrace: stackTrace.toString(),
          errorSource: "WebSocket Error",
          severityLevel: "Critical",
          requestPath: "ChatScreenWebSocketService",
        );

        _isWebsocketProcessing = false;
        _isInputDisabled = false;
        _notifyStateChanged();
      },
    );
    
    // Listen to message events
    _webSocketService!.messages.listen(
      (message) {
        if (message.type == MessageType.complete) {
          _handleWebSocketCompletion(message.data);
        } else if (message.type == MessageType.error) {
          _handleWebSocketError(message.data);
        } else if (message.type == MessageType.disconnected) {
          _handleWebSocketDisconnection();
        } else {
          _handleWebSocketProgress(message.data);
        }
      },
      onError: (error, stackTrace) {
        SnackbarMessage.showErrorMessage(
          context,
          "WebSocket Error: $error",
          logError: true,
          errorMessage: "WebSocket Error: $error",
          errorStackTrace: stackTrace.toString(),
          errorSource: "WebSocket Error",
          requestPath: "ChatScreenWebSocketService",
          severityLevel: "Critical",
        );
      },
    );
  }

  void _handleWebSocketProgress(Map<String, dynamic> progressData) {
    // Validate progress data
    if (progressData.isEmpty) {
      return;
    }
  }

  void _handleWebSocketCompletion(Map<String, dynamic> parsedData) async {
    try {
      await drivingModel.updateConfig(context, parsedData, finalUpdate: false);
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context,
        "Error handling WebSocket completion: $e",
        logError: true,
        errorMessage: "Error handling WebSocket completion: $e",
        errorStackTrace: e.toString(),
        errorSource: "WebSocket Error",
        requestPath: "ChatScreenWebSocketService",
        severityLevel: "Critical",
      );
    } finally {
      // Always reset processing state, regardless of success or failure
      _isWebsocketProcessing = false;
      _isInputDisabled = false;
      _websocketProgress = null;
      _notifyStateChanged();
    }
  }

  void _handleWebSocketError(Map<String, dynamic> errorData) {
    final String errorMessage = _extractErrorMessage(errorData);
    
    if (errorMessage.isNotEmpty) {
      _handleConnectionError(errorMessage);
      // Show other errors to the user
      SnackbarMessage.showErrorMessage(
        context,
        "WebSocket Error: $errorMessage",
        logError: true,
        errorMessage: "WebSocket Error: $errorMessage",
        errorStackTrace: errorData.toString(),
        errorSource: "WebSocket Error",
        requestPath: "ChatScreenWebSocketService",
        severityLevel: "Critical",
      );
    }

    // Always reset processing state
    _resetProcessingState();
  }

  String _extractErrorMessage(Map<String, dynamic> errorData) {
    return errorData['error']?.toString() ??
           errorData['message']?.toString() ??
           errorData['data']?['error']?.toString() ??
           '';
  }

  void _handleConnectionError(String errorMessage) {
    // Permanently disable WebSocket for connection failures
    _websocketDisabled = true;
    _webSocketService = null;
    _notifyStateChanged();
    // Don't show error to user for connection failures - they're handled silently
  }

  void _resetProcessingState() {
    _isWebsocketProcessing = false;
    _isInputDisabled = false;
    _notifyStateChanged();
  }

  void _handleWebSocketDisconnection() {
    // Handle disconnection gracefully
    _isWebsocketProcessing = false;
    _isInputDisabled = false;
    _notifyStateChanged();
  }

  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  void resetForNewTest() {
    // Reset local state
    _websocketProgress = null;
    _isWebsocketProcessing = false;
    _websocketData = null;
    _isInputDisabled = false;
    
    // Handle WebSocket reconnection only if enabled
    if (enableWebSocket && _webSocketService != null) {
      try {
        _webSocketService!.reset();
        _webSocketService!.disconnect();
        
        // Reinitialize WebSocket service for the new test
        initialize();
      } catch (e) {
        // Continue without WebSocket functionality
        _webSocketService = null;
        _notifyStateChanged();
      }
    }
  }

  void dispose() {
    // Gracefully disconnect WebSocket if it exists
    if (_webSocketService != null) {
      try {
        _webSocketService!.dispose();
      } catch (e) {
        // Continue with disposal even if WebSocket cleanup fails
      }
    }
  }
} 