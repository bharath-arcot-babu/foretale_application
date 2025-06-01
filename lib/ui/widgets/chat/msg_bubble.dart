import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/embeddings/process_files_by_response.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_attachment_model.dart';
import 'package:foretale_application/models/llm/clarify_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/services/s3_activites.dart';
import 'package:foretale_application/ui/widgets/chat/info_card.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final ThemeData theme;
  final int responseId;
  final String responseText;
  final String responseDate;
  final int isAiMagicResponse;
  final List<InquiryAttachment> attachments;
  final ChatDrivingModel drivingModel;
  final bool embeddingStatus;
  final String userId;

  final String _currentFileName = 'ChatBubble.dart';

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.theme,
    required this.responseText,
    required this.responseDate,
    required this.attachments,
    required this.responseId,
    required this.isAiMagicResponse,
    required this.drivingModel,
    required this.embeddingStatus,
    required this.userId,
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

  List<Widget> _buildAttachments(
      BuildContext context, List<InquiryAttachment> attachments) {
    return attachments.map((attachment) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(attachment.fileName),
              size: 18,
              color: isUser ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                attachment.fileName,
                style: TextStyles.responseTextFileInfo(context).copyWith(
                  color: isUser ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "(${attachment.fileSize} KB)",
              style: TextStyles.responseTextFileInfo(context).copyWith(
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.download, size: 14),
              color: isUser ? Colors.white : Colors.black87,
              onPressed: () async {
                try {
                  final s3Service = S3Service();
                  final filePath =
                      '${attachment.filePath}/${attachment.fileName}';
                  final fileUrl = await s3Service.getFileUrl(filePath);

                  if (fileUrl != null) {
                    // Open the file URL in the browser
                    // You'll need to add url_launcher package for this
                    // await launchUrl(Uri.parse(fileUrl));
                    await s3Service.downloadFile(filePath);
                    SnackbarMessage.showSuccessMessage(
                      context,
                      "Download is complete.",
                    );
                  } else {
                    throw Exception("Failed to get file URL");
                  }
                } catch (e, error_stack_trace) {
                  SnackbarMessage.showErrorMessage(context, e.toString(),
                      logError: true,
                      errorMessage: "Error downloading file: $e",
                      errorStackTrace: error_stack_trace.toString(),
                      errorSource: _currentFileName,
                      severityLevel: 'Critical',
                      requestPath: "_buildAttachments");
                }
              },
              tooltip: "Download ${attachment.fileName}",
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildEmbeddingStatus(BuildContext context) {
    return embeddingStatus == true
    ? CustomIconButton(
        icon: Icons.info,
        iconSize: 14,
        padding: 2,
        tooltip: "Vectorized for AI Magic",
        onPressed: () {},
      )
    : CustomIconButton(
        icon: Icons.refresh,
        iconSize: 14,
        padding: 2,
        tooltip: "Retry creating embeddings for AI magic",
        onPressed: () {
          try{
            EmbeddingService().runEmbeddingsForResponse(
              responseId,
              userId
            );
          } catch (e, error_stack_trace) {
            SnackbarMessage.showErrorMessage(context, e.toString(),
                logError: true,
                errorMessage: "Error creating embeddings: $e",
                errorStackTrace: error_stack_trace.toString(),
                errorSource: _currentFileName,
                severityLevel: 'Critical',
                requestPath: "buildEmbeddingStatus");
          }
        },
      );

  }

  Widget _buildDeleteButton(BuildContext context) {
    return CustomIconButton(
      icon: Icons.delete_outline,
      iconSize: 14,
      padding: 2,
      tooltip: "Delete response",
      onPressed: () async {
        try {
          final inquiryResponseModel =
              Provider.of<InquiryResponseModel>(context, listen: false);
          final confirmed = await showConfirmDialog(
            context: context,
            title: 'Delete Response',
            content: 'Are you sure you want to delete this response?',
            confirmText: 'Delete',
            cancelText: 'Cancel',
            confirmTextColor: Colors.green,
          );

          if (confirmed == true) {
            int deletedId =
                await inquiryResponseModel.deleteResponse(context, responseId);
            if (deletedId > 0) {
              await drivingModel.fetchResponses(context);
              SnackbarMessage.showSuccessMessage(
                context,
                "Response deleted successfully.",
              );
            } else {
              SnackbarMessage.showErrorMessage(
                context,
                "Failed to delete response.",
              );
            }
          }
        } catch (e, error_stack_trace) {
          SnackbarMessage.showErrorMessage(
            context,
            e.toString(),
            logError: true,
            errorMessage: "Error deleting response: $e",
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "deleteResponse",
          );
        }
      },
    );
  }

  Widget _buildAiMagicResponse(BuildContext context, String aiResponseText) {
    //Parse the response
      //Response is a list of maps. Map is string key and dynamic value.
      if (aiResponseText.isNotEmpty) {
        try {
          return InfoCard( 
                question: aiResponseText,
                reason: "",
                calloutText: 'AI'
              );
        } catch (parseError) {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              embeddingStatus == true
              ? _buildEmbeddingStatus(context)
              : const SizedBox.shrink(),
              const SizedBox(width: 8),
              _buildDeleteButton(context),
            ],
          ),
          isAiMagicResponse == 1 
          ? _buildAiMagicResponse(context, responseText) 
          : 
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? theme.colorScheme.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft:
                    isUser ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight:
                    isUser ? const Radius.circular(4) : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    responseText,
                    style: TextStyles.responseText(context).copyWith(
                      color: isUser
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._buildAttachments(context, attachments),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              responseDate,
              style: TextStyles.smallSupplementalInfo(context),
            ),
          ),
        ],
      );
    }
}
