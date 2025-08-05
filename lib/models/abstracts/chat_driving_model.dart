import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/websocket_service.dart';

abstract class ChatDrivingModel {
  int get selectedId;

  Future<void> fetchResponses(BuildContext context);

  Future<int> insertResponse(BuildContext context, String responseText);

  String buildStoragePath({
    required String projectId,
    required String responseId,
  });

  String getStoragePath(BuildContext context, int responseId);

  int getSelectedId(BuildContext context);

  String getDrivingModelName(BuildContext context);

  String getWebSocketUrl(BuildContext context);

  Future<void> sendMessage(BuildContext context, String message, WebSocketService? webSocketService) async {
    // Default implementation - do nothing when WebSocket is not available
    if (webSocketService == null) {
      return;
    }
    // Subclasses should override this method to provide actual implementation
  }

  Future<int> updateConfig(BuildContext context, Map<dynamic, dynamic> fullState, {bool finalUpdate = false});
}
