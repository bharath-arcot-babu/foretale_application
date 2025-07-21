import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:foretale_application/ui/widgets/chat/websocket_progress_indicator.dart';


class InputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool isChatEnabled;
  final VoidCallback? onFilePick;
  final VoidCallback? onSendMessage;
  final String hintText;
  final IconData attachmentIcon;
  final IconData sendIcon;
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final double iconSize;
  final FilePickerResult? filePickerResult;
  final Function(PlatformFile)? onRemoveFile;
  final String? websocketProgress; // New parameter for websocket progress
  final bool isWebsocketProcessing; // New parameter for processing state
  final Map<String, dynamic>? websocketData; // New parameter for detailed progress data

  const InputArea({
    super.key,
    required this.controller,
    required this.isChatEnabled,
    required this.onFilePick,
    required this.onSendMessage,
    this.hintText = "Type your message...",
    this.attachmentIcon = Icons.attach_file_rounded,
    this.sendIcon = Icons.send_rounded,
    this.borderRadius = 24.0,
    this.paddingHorizontal = 16.0,
    this.paddingVertical = 12.0,
    this.iconSize = 20.0,
    this.filePickerResult,
    this.onRemoveFile,
    this.websocketProgress, // New parameter
    this.isWebsocketProcessing = false, // New parameter
    this.websocketData, // New parameter
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
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFileIcon(file.name),
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      file.name,
                      style: TextStyles.responseTextFileInfo(context).copyWith(
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${(file.size / 1024).round()} KB)",
                    style: TextStyles.responseTextFileInfo(context).copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: Colors.black87,
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
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal, vertical: paddingVertical),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
          _buildWebsocketProgress(context), // Add websocket progress here
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  attachmentIcon,
                  color: isChatEnabled
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
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
                    hintText: hintText,
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
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: isChatEnabled ? onSendMessage : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(sendIcon, color: Colors.white, size: iconSize),
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
