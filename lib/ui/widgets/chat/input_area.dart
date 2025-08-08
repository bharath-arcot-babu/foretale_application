import 'package:flutter/material.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:foretale_application/ui/widgets/chat/websocket_progress_indicator.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';


class InputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool isChatEnabled;
  final VoidCallback? onFilePick;
  final VoidCallback? onInsertMessage;
  final VoidCallback? onSendMessage;
  final String hintText;

  final FilePickerResult? filePickerResult;
  final Function(PlatformFile)? onRemoveFile;
  final String? websocketProgress; // New parameter for websocket progress
  final bool isWebsocketProcessing; // New parameter for processing state
  final Map<String, dynamic>? websocketData; // New parameter for detailed progress data
  final bool isRunQueryGeneration;

  const InputArea({
    super.key,
    required this.controller,
    required this.isChatEnabled,
    required this.onFilePick,
    required this.onInsertMessage,
    required this.onSendMessage,
    required this.hintText,

    this.filePickerResult,
    this.onRemoveFile,
    this.websocketProgress, // New parameter
    this.isWebsocketProcessing = false, // New parameter
    this.websocketData, // New parameter
    this.isRunQueryGeneration = false,
  });

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildFilePreview() {
    if (filePickerResult == null || filePickerResult!.files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filePickerResult!.files.map((file) {
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFileIcon(file.name),
                    size: 18,
                    color: TextColors.primaryTextColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      file.name,
                      style: TextStyles.responseTextFileInfo(context).copyWith(
                        color: TextColors.primaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${(file.size / 1024).round()} KB)",
                    style: TextStyles.responseTextFileInfo(context).copyWith(
                      color: TextColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: TextColors.primaryTextColor,
                    onPressed: () => onRemoveFile?.call(file),
                    tooltip: "Remove file",
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWebsocketProgress(BuildContext context) {
    if (!isWebsocketProcessing && websocketProgress == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: WebSocketProgressIndicator(
        currentStep: websocketProgress,
        isProcessing: isWebsocketProcessing,
        progressData: websocketData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilePreview(),
          if(!isRunQueryGeneration)
            _buildWebsocketProgress(context), // Add websocket progress here
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.attach_file_rounded,
                  color: isChatEnabled
                      ? AppColors.primaryColor
                      : ButtonColors.disabledButtonColor,
                ),
                onPressed: isChatEnabled ? onFilePick : null,
                tooltip: "Attach File",
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: isChatEnabled,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyles.inputHintTextStyle(context),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: TextStyles.inputMainTextStyle(context),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: isChatEnabled
                    ? AppColors.primaryColor
                    : ButtonColors.disabledButtonColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: isChatEnabled ? onInsertMessage : null,
                  onDoubleTap: isChatEnabled ? onSendMessage : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
