import 'package:flutter/material.dart';
import 'package:foretale_application/ui/widgets/chat/chat_response_service.dart';
import 'package:foretale_application/ui/widgets/chat/chat_screen_websocket_service.dart';
import 'package:foretale_application/core/utils/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/chat/avatar.dart';
import 'package:foretale_application/ui/widgets/chat/input_area.dart';
import 'package:foretale_application/ui/widgets/chat/msg_bubble.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final TextEditingController responseController = TextEditingController();
  final ChatDrivingModel drivingModel;
  final bool isChatEnabled;
  final String userId;
  final bool enableWebSocket;

  ChatScreen({
    super.key,
    required this.drivingModel,
    required this.isChatEnabled,
    required this.userId,
    this.enableWebSocket = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String _currentFileName = 'ChatScreen.dart';

  final ScrollController _scrollController = ScrollController();
  late TextEditingController _responseController;
  FilePickerResult? filePickerResult;

  ChatScreenWebSocketService? _webSocketService;
  final ChatResponseService _chatResponseService = ChatResponseService();

  @override
  void initState() {
    super.initState();
    _responseController = widget.responseController;
    if (widget.enableWebSocket) {
      _initializeWebSocketService();
    }
  }

  void _initializeWebSocketService() {
    _webSocketService = ChatScreenWebSocketService(
      drivingModel: widget.drivingModel,
      context: context,
      enableWebSocket: widget.enableWebSocket,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
      onProgressUpdate: (progress) {
        // Progress updates are handled through state changes
      },
      onDataUpdate: (data) {
        // Data updates are handled through state changes
      },
    );
    
    _webSocketService!.initialize();
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset progress state when switching to a different test
    if (oldWidget.drivingModel != widget.drivingModel || 
        oldWidget.drivingModel.getSelectedId(context) != widget.drivingModel.getSelectedId(context)) {
      
      // Reset WebSocket service for the new test
      if (_webSocketService != null) {
        _webSocketService!.resetForNewTest();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _responseController.dispose();
    
    // Dispose WebSocket service
    _webSocketService?.dispose();
    
    filePickerResult = null;
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userMachineId = Provider.of<UserDetailsModel>(context).getUserMachineId;
    final inquiryResponseModel = Provider.of<InquiryResponseModel>(context);

    return inquiryResponseModel.getIsPageLoading
        ? _buildLoadingIndicator()
        : Column(
            children: [
              Expanded(
                child: Consumer<InquiryResponseModel>(
                    builder: (context, inquiryResponseModel, child) {
                      final responses = inquiryResponseModel.getResponseList;

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(15),
                        itemCount: responses.length,
                        itemBuilder: (context, index) {
                          final item = responses[index];
                          final isUser = (item.responseByMachineId == userMachineId);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AvatarWithSpacer(
                                  name: item.responseBy,
                                  responseByMachineId: item.responseByMachineId,
                                  isUser: isUser,
                                  index: index,
                                  responses: responses,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: ChatBubble(
                                    isUser: isUser,
                                    theme: Theme.of(context),
                                    responseText: item.responseText,
                                    responseDate: item.responseDate,
                                    attachments: item.attachments,
                                    responseId: item.responseId,
                                    isAiMagicResponse: item.isAiMagicResponse,
                                    drivingModel: widget.drivingModel,
                                    embeddingStatus: item.isEmbeddingCompleted,
                                    userId: widget.userId,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
              ),
              
            InputArea(
                  controller: _responseController,
                  isChatEnabled: widget.isChatEnabled && !(_webSocketService?.isInputDisabled ?? false),
                  onFilePick: _webSocketService?.isInputDisabled ?? false ? null : _pickFile,
                  onInsertMessage: _webSocketService?.isInputDisabled ?? false ? null : () => _addResponse(isRunQueryGeneration: false),
                  onSendMessage: _webSocketService?.isInputDisabled ?? false ? null : () => _addResponse(isRunQueryGeneration: true),
                  hintText: _webSocketService?.isInputDisabled ?? false 
                      ? "Processing your request..." 
                      : "Add business intent, rules, or filters for the AI model to follow...",
                  filePickerResult: filePickerResult,
                  websocketProgress: _webSocketService?.websocketProgress,
                  isWebsocketProcessing: _webSocketService?.isWebsocketProcessing ?? false,
                  websocketData: _webSocketService?.websocketData,
                  onRemoveFile: _webSocketService?.isInputDisabled ?? false ? null : (file) {
                  setState(() {
                    if (filePickerResult != null) {
                      final files = List<PlatformFile>.from(filePickerResult!.files);
                      files.removeWhere((f) => f.name == file.name);
                      filePickerResult = FilePickerResult(files);
                    }
                  });
                },
              ),
            ],
          );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: LinearLoadingIndicator(
        isLoading: true,
        width: 200,
        height: 6,
        color: AppColors.primaryColor,
        loadingText: "Loading messages...",
      ),
    );
  }

  Future<void> _addResponse({bool isRunQueryGeneration = false}) async {
    try{
      // Note: WebSocket processing state is managed by the service itself
      
      await _chatResponseService.addResponse(
        context: context,
        responseController: _responseController,
        drivingModel: widget.drivingModel,
        userId: widget.userId,
        enableWebSocket: widget.enableWebSocket,
        webSocketService: _webSocketService?.webSocketService,
        websocketDisabled: _webSocketService?.websocketDisabled ?? false,
        filePickerResult: filePickerResult,
        clearInputAndFiles: _clearInputAndFiles,
        isRunQueryGeneration: isRunQueryGeneration,
      );
    } catch (e, stackTrace) {
      SnackbarMessage.showErrorMessage(
          context, 
          "Error adding response.",
          logError: true,
          errorMessage: "Error adding response: $e",
          errorStackTrace: stackTrace.toString(),
          severityLevel: "Critical",
          requestPath: _currentFileName,
        );
    } 
  }

  void _clearInputAndFiles() {
    setState(() {
      _responseController.clear();
      filePickerResult = null;
    });
  }

  Future<void> _pickFile() async {
    filePickerResult = await pickFileForChat();
    setState(() {});
  }
}

