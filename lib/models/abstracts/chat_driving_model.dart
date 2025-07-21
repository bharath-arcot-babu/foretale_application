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

  Future<void> sendMessage(BuildContext context, String message, WebSocketService webSocketService);

  String getDrivingModelName(BuildContext context);

  String getWebSocketUrl(BuildContext context);

  Future<int> updateConfig(
    BuildContext context, 
    String aiSummary, 
    String keyTables, 
    String keyColumns, 
    String keyCriteria,
    String keyJoins,
    String keyAmbiguities,
    String fullState,
    String initialState,
    String config,
    String configExecStatus,
    String configExecMessage);
}
