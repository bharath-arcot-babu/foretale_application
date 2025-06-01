import 'package:flutter/material.dart';
import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/config_lambda_api.dart';
import 'package:foretale_application/core/services/embeddings/process_files_by_response.dart';
import 'package:foretale_application/core/services/lambda_activities.dart';
import 'package:foretale_application/core/utils/file_picker.dart';
import 'package:foretale_application/core/utils/polling.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
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
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _responseController = widget.responseController;
    userModel = Provider.of<UserDetailsModel>(context, listen: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                child: ModernContainer(
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
                          final isUser =
                              (item.responseByMachineId == userMachineId);

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
              ),
              InputArea(
                controller: _responseController,
                isChatEnabled: widget.isChatEnabled,
                onFilePick: _pickFile,
                onSendMessage: _addResponse,
                hintText: "Add business intent, rules, or filters for the AI model to follow...",
                filePickerResult: filePickerResult,
                onRemoveFile: (file) {
                  setState(() {
                    if (filePickerResult != null) {
                      final files =
                          List<PlatformFile>.from(filePickerResult!.files);
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
        SnackbarMessage.showErrorMessage(
            context, "Enter a message or attach a file.",
            showUserMessage: true);
        return;
      }

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
          print("Embeddings run for response $insertedId");
        }

        setState(() {
          _responseController.clear();
          filePickerResult = null;
        });

        await widget.drivingModel.fetchResponses(context);
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
    }
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

