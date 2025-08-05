import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:foretale_application/core/services/embeddings/process_files_by_response.dart';
import 'package:foretale_application/core/services/s3_activites.dart';
import 'package:foretale_application/core/services/websocket_service.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';

/// Service class for handling chat response operations
class ChatResponseService {
  final String _currentFileName = 'ChatResponseService.dart';

  /// Adds a response to the chat with optional file attachments
  Future<void> addResponse({
    required BuildContext context,
    required TextEditingController responseController,
    required ChatDrivingModel drivingModel,
    required String userId,
    required bool enableWebSocket,
    required WebSocketService? webSocketService,
    required bool websocketDisabled,
    required FilePickerResult? filePickerResult,
    required VoidCallback clearInputAndFiles,
    required bool isRunQueryGeneration,
  }) async {
    if (!isRunQueryGeneration && !_validateInput(context, responseController, filePickerResult)) return;

    final inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    int insertedId = 0;
    int insertedAttachmentId = 0;

    try {

      if(responseController.text.trim().isNotEmpty){
        insertedId = await _insertResponse(context, responseController, drivingModel);
        if (insertedId <= 0) return;
      }

      await _handleSuccessfulResponse(
        context: context,
        insertedId: insertedId,
        inquiryResponseModel: inquiryResponseModel,
        drivingModel: drivingModel,
        userId: userId,
        enableWebSocket: enableWebSocket,
        websocketDisabled: websocketDisabled,
        webSocketService: webSocketService,
        responseController: responseController,
        filePickerResult: filePickerResult,
        clearInputAndFiles: clearInputAndFiles,
        isRunQueryGeneration: isRunQueryGeneration,
      );
      
    } catch (e) {
      _handleResponseError(context, e, insertedId, insertedAttachmentId);
    }
  }

  /// Validates user input before sending
  bool _validateInput(
    BuildContext context,
    TextEditingController responseController,
    FilePickerResult? filePickerResult,
  ) {
    final responseText = responseController.text.trim();
    if (responseText.isEmpty && (filePickerResult == null || filePickerResult.files.isEmpty)) {
      SnackbarMessage.showErrorMessage(context, "Enter a message or attach a file.");
      return false;
    }
    return true;
  }

  /// Starts WebSocket processing if available
  void _startWebSocketProcessing(WebSocketService? webSocketService, bool websocketDisabled) {
    if (!websocketDisabled && webSocketService != null && webSocketService.isConnected) {
      webSocketService.startProcessing();
    } else {
      print('WebSocket: Service not available, not connected, or disabled, skipping processing start');
    }
  }

  /// Inserts the response into the database
  Future<int> _insertResponse(
    BuildContext context,
    TextEditingController responseController,
    ChatDrivingModel drivingModel,
  ) async {
    final responseText = responseController.text.trim();
    return await drivingModel.insertResponse(context, responseText);
  }

  /// Handles successful response insertion
  Future<void> _handleSuccessfulResponse({
    required BuildContext context,
    required int insertedId,
    required InquiryResponseModel inquiryResponseModel,
    required ChatDrivingModel drivingModel,
    required String userId,
    required bool enableWebSocket,
    required bool websocketDisabled,
    required WebSocketService? webSocketService,
    required TextEditingController responseController,
    required FilePickerResult? filePickerResult,
    required VoidCallback clearInputAndFiles,
    required bool isRunQueryGeneration,
  }) async {
    // Update the response id selection
    inquiryResponseModel.updateResponseIdSelection(insertedId);

    // Process attachments if any
    if(insertedId > 0){
      if (filePickerResult != null && filePickerResult!.files.isNotEmpty) {
        await _processAttachments(insertedId, inquiryResponseModel, drivingModel, context, filePickerResult);
        // Invoke the lambda function to run the embedding task
        await _runEmbeddingsForAllResponses(insertedId, userId);
      }
      // Fetch updated responses
      await drivingModel.fetchResponses(context);
      // Clear input and files after successful insertion
      clearInputAndFiles();
    }

    // Send message via WebSocket only if enabled and service is available
    if (enableWebSocket && !websocketDisabled && webSocketService != null && webSocketService.isConnected && isRunQueryGeneration) {
      try {
        _startWebSocketProcessing(webSocketService, websocketDisabled);
   
        final responseText = responseController.text.trim();
        await drivingModel.sendMessage(context, responseText, webSocketService);
      } catch (e) {
        SnackbarMessage.showErrorMessage(
          context, 
          "Error sending WebSocket message.",
          logError: true,
          errorMessage: "Error sending WebSocket message: $e",
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "addResponse"
        );
      }
    }
  }

  /// Handles response errors
  void _handleResponseError(BuildContext context, dynamic error, int insertedId, int insertedAttachmentId) {
    if (insertedId == 0) {
      SnackbarMessage.showErrorMessage(
        context, 
        error.toString(),
        logError: true,
        errorMessage: "Error adding response: $error",
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "addResponse"
      );
    } else if (insertedAttachmentId == 0) {
      SnackbarMessage.showErrorMessage(
        context, 
        error.toString(),
        logError: true,
        errorMessage: "Error adding attachments: $error",
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "addResponse"
      );
    }
  }

  /// Processes file attachments
  Future<int> _processAttachments(
    int insertedId,
    InquiryResponseModel inquiryResponseModel,
    ChatDrivingModel drivingModel,
    BuildContext context,
    FilePickerResult filePickerResult,
  ) async {
    final storagePath = drivingModel.getStoragePath(context, insertedId);
    int insertedAttachmentId = 0;

    for (final file in filePickerResult.files) {
      await S3Service().uploadFile(file, storagePath);
      insertedAttachmentId = await inquiryResponseModel.insertAttachmentByResponse(
        context,
        storagePath,
        file.name,
        file.extension ?? "",
        (file.size / (1024 * 1024)).round(),
      );
    }
    return insertedAttachmentId;
  }

  /// Runs embeddings for all responses
  Future<void> _runEmbeddingsForAllResponses(int responseId, String userId) async {
    await EmbeddingService().runEmbeddingsForResponse(responseId, userId);
  }
} 