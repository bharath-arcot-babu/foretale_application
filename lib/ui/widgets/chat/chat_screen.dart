import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/embeddings/process_files_by_response.dart';
import 'package:foretale_application/core/services/websocket_service.dart';
import 'package:foretale_application/core/utils/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/services/s3_activites.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/chat/avatar.dart';
import 'package:foretale_application/ui/widgets/chat/input_area.dart';
import 'package:foretale_application/ui/widgets/chat/msg_bubble.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/ui/widgets/chat/websocket_progress_indicator.dart';

class ChatScreen extends StatefulWidget {
  final TextEditingController responseController = TextEditingController();
  final ChatDrivingModel drivingModel;
  final bool isChatEnabled;

  ChatScreen({
    super.key,
    required this.drivingModel,
    required this.isChatEnabled,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String _currentFileName = 'ChatScreen.dart';
  final ScrollController _scrollController = ScrollController();
  FilePickerResult? filePickerResult;
  late TextEditingController _responseController;
  late UserDetailsModel userModel;
  late WebSocketService webSocketService;
  
  // Instance-specific progress state
  String? _websocketProgress;
  bool _isWebsocketProcessing = false;
  Map<String, dynamic>? _websocketData;
  bool _isInputDisabled = false;
  
  // Getters and setters for the progress state
  String? get websocketProgress => _websocketProgress;
  set websocketProgress(String? value) => _websocketProgress = value;
  
  bool get isWebsocketProcessing => _isWebsocketProcessing;
  set isWebsocketProcessing(bool value) => _isWebsocketProcessing = value;
  
  Map<String, dynamic>? get websocketData => _websocketData;
  set websocketData(Map<String, dynamic>? value) => _websocketData = value;
  
  bool get isInputDisabled => _isInputDisabled;
  set isInputDisabled(bool value) => _isInputDisabled = value;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeUserModel();
    _initializeWebSocketService();
  }

  void _initializeControllers() {
    _responseController = widget.responseController;
  }

  void _initializeUserModel() {
    userModel = Provider.of<UserDetailsModel>(context, listen: false);
  }

  void _initializeWebSocketService() {
    final webSocketUrl = widget.drivingModel.getWebSocketUrl(context);
    webSocketService = WebSocketService(webSocketUrl);
    webSocketService.connect();
    _setupWebSocketMessageListener();
  }

  void _setupWebSocketMessageListener() {
    webSocketService.messages.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        print('WebSocket error: $error');
        // Don't reset progress on WebSocket errors, let it continue
      },
      onDone: () {
        print('WebSocket connection closed');
        // Don't reset progress when WebSocket closes, let it continue
      },
    );
  }

  void _handleWebSocketMessage(String message) {
    // Parse websocket message using the detailed JSON parser
    final parsedData = WebSocketProgressIndicator.parseDetailedWebSocketMessage(message);
    
    if (parsedData != null) {
      _processWebSocketData(parsedData);
    }
  }

  void _processWebSocketData(Map<String, dynamic> parsedData) {  
    setState(() {
      websocketProgress = parsedData['step'];
      websocketData = parsedData;
      
      if (parsedData['step'] == '[[DONE]]') {
        _handleWebSocketCompletion(parsedData);
      } else if (parsedData['step'] == '[[ERROR]]') {
        _handleWebSocketError();
      } else {
        _handleWebSocketProgress();
      }
    });
  }

  void _handleWebSocketCompletion(Map<String, dynamic> parsedData) async {
    // Extract data from the final state with null safety
    final finalState = parsedData['data'] is Map ? Map<String, dynamic>.from(parsedData['data']) : {};
    
    // Convert complex objects to JSON strings for storage
    final summary = finalState['summary']?.toString() ?? '';
    final keyTables = finalState['key_tables'] is List 
        ? finalState['key_tables'].toString() 
        : finalState['key_tables']?.toString() ?? '';
    final keyColumns = finalState['key_columns'] is List 
        ? finalState['key_columns'].toString() 
        : finalState['key_columns']?.toString() ?? '';
    final keyCriteria = finalState['key_criteria'] is List 
        ? finalState['key_criteria'].toString() 
        : finalState['key_criteria']?.toString() ?? '';
    final ambiguities = finalState['ambiguities'] is List 
        ? finalState['ambiguities'].toString() 
        : finalState['ambiguities']?.toString() ?? '';
    final resolvedJoins = finalState['resolved_joins'] is List 
        ? finalState['resolved_joins'].toString() 
        : finalState['resolved_joins']?.toString() ?? '';
    final formattedSqlQuery = finalState['formatted_sql_query'] is Map 
        ? finalState['formatted_sql_query']['formatted_sql']?.toString() ?? ''
        : finalState['formatted_sql_query']?.toString() ?? '';
    
    // Convert the entire final state to JSON for full state storage
    final fullState = jsonEncode(finalState);
    final initialState = jsonEncode(parsedData);
    
    await widget.drivingModel.updateConfig(
      context, 
      summary,
      keyTables,
      keyColumns,
      keyCriteria,
      resolvedJoins,
      ambiguities,
      fullState,
      initialState,
      formattedSqlQuery,
      'Completed', 
      'Success');
      
    // ONLY clear progress state when WebSocket sends [[DONE]]
    setState(() {
      isWebsocketProcessing = false;
      isInputDisabled = false; // Re-enable input when complete
      websocketProgress = null; // Clear progress ONLY on completion
      websocketData = null; // Clear data ONLY on completion
    });
  }

  void _handleWebSocketError() {
    setState(() {
      isWebsocketProcessing = false;
      isInputDisabled = false; // Re-enable input on error
      websocketProgress = null; // Clear progress
      websocketData = null; // Clear data
    });
  }

  void _handleWebSocketProgress() {
    setState(() {
      isWebsocketProcessing = true;
    });
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset progress state when switching to a different test
    if (oldWidget.drivingModel != widget.drivingModel || 
        oldWidget.drivingModel.getSelectedId(context) != widget.drivingModel.getSelectedId(context)) {
      
      setState(() {
        _websocketProgress = null;
        _isWebsocketProcessing = false;
        _websocketData = null;
        _isInputDisabled = false;
      });
      
      // Also disconnect and reconnect WebSocket for the new test
      webSocketService.disconnect();
      _initializeWebSocketService();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _responseController.dispose();
    
    // Gracefully disconnect WebSocket
    try {
      webSocketService.disconnect();
    } catch (e) {
    }
    
    filePickerResult = null;
    
    // Clear progress state
    _websocketProgress = null;
    _isWebsocketProcessing = false;
    _websocketData = null;
    _isInputDisabled = false;
    
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
                                    userId: userModel.getUserMachineId?? "",
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
                isChatEnabled: widget.isChatEnabled && !isInputDisabled, // Disable when processing
                onFilePick: isInputDisabled ? null : _pickFile, // Disable file pick when processing
                onSendMessage: isInputDisabled ? null : _addResponse, // Disable send when processing
                hintText: isInputDisabled 
                    ? "Processing your request..." 
                    : "Add business intent, rules, or filters for the AI model to follow...",
                filePickerResult: filePickerResult,
                websocketProgress: websocketProgress, // Pass websocket progress
                isWebsocketProcessing: isWebsocketProcessing, // Pass processing state
                websocketData: websocketData, // Pass detailed progress data
                onRemoveFile: isInputDisabled ? null : (file) {
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


  Future<void> _addResponse() async {
    final inquiryResponseModel =  Provider.of<InquiryResponseModel>(context, listen: false);
    int insertedId = 0;
    int insertedAttachmentId = 0;

    try {
      final responseText = _responseController.text.trim();

      if (responseText.isEmpty && (filePickerResult == null || filePickerResult!.files.isEmpty)) {
        SnackbarMessage.showErrorMessage(context, "Enter a message or attach a file.");
        return;
      }

      // Immediately disable input and show progress
      setState(() {
        isInputDisabled = true;
        isWebsocketProcessing = true;
        websocketProgress = 'test_case_summarizer'; // Start with first step
      });

      insertedId = await widget.drivingModel.insertResponse(context, responseText);

      if (insertedId > 0) {
        //Update the response id selection
        inquiryResponseModel.updateResponseIdSelection(insertedId);

        if (filePickerResult != null && filePickerResult!.files.isNotEmpty) {
          final storagePath = widget.drivingModel.getStoragePath(context, insertedId);
          for (final file in filePickerResult!.files) {
            await S3Service().uploadFile(file, storagePath);
            insertedAttachmentId = await inquiryResponseModel.insertAttachmentByResponse(
              context,
              storagePath,
              file.name,
              file.extension ?? "",
              (file.size / (1024 * 1024)).round(),
            );
          }
          //invoke the lambda function to run the embedding task
          await _runEmbeddingsForAllResponses(insertedId, userModel.getUserMachineId?? "");
        }

        await widget.drivingModel.fetchResponses(context);

        // Clear input and files after successful insertion, but keep progress visible
        setState(() {
          _responseController.clear();
          filePickerResult = null;
          // DO NOT reset progress state here - let WebSocket handle completion
          // Progress should persist until [[DONE]] is received
        });

        await widget.drivingModel.sendMessage(context, responseText, webSocketService);
        
      }
    } catch (e, error_stack_trace) {

      if (insertedId == 0) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: "Error adding response: $e",
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_addResponse");
      } else if (insertedAttachmentId == 0) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: "Error adding attachments: $e",
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_addResponse");
      }
      
      // Reset state on error
      setState(() {
        isInputDisabled = false;
        isWebsocketProcessing = false;
        websocketProgress = null;
      });
    }
    // Note: We don't reset the state in finally block anymore since WebSocket will handle completion
  }

  Future<void> _runEmbeddingsForAllResponses(int responseId, String userId) async {
    try{
      //Invoke the lambda function to run the embedding task
      await EmbeddingService().runEmbeddingsForResponse(
        responseId, 
        userId);
    } catch (e, error_stack_trace) {
      rethrow;
    }
  }

  Future<void> _pickFile() async {
    filePickerResult = await pickFileForChat();

    setState(() {});
  }
}

