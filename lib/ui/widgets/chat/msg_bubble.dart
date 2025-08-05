import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/embeddings/process_files_by_response.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_attachment_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/services/s3_activites.dart';
import 'package:foretale_application/ui/widgets/chat/info_card.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

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
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.white.withOpacity(0.15)
              : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? Colors.white.withOpacity(0.2)
                : BorderColors.tertiaryColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(attachment.fileName),
                size: 16,
                color: isUser ? Colors.white : TextColors.primaryTextColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    style: TextStyles.responseTextFileInfo(context).copyWith(
                      color: isUser ? Colors.white : TextColors.primaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${attachment.fileSize} KB",
                    style: TextStyles.tinySupplementalInfo(context).copyWith(
                      color: isUser 
                          ? Colors.white.withOpacity(0.7)
                          : TextColors.hintTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.download, size: 16),
                color: isUser ? Colors.white : TextColors.primaryTextColor,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                onPressed: () async {
                  try {
                    final s3Service = S3Service();
                    final filePath =
                        '${attachment.filePath}/${attachment.fileName}';
                    final fileUrl = await s3Service.getFileUrl(filePath);

                    if (fileUrl != null) {
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
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildEmbeddingStatus(BuildContext context) {
    return embeddingStatus == true
        ? Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: CustomIconButton(
              icon: Icons.check_circle,
              iconSize: 14,
              padding: 6,
              tooltip: "Vectorized for AI Magic",
              onPressed: () {},
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: CustomIconButton(
              icon: Icons.refresh,
              iconSize: 14,
              padding: 6,
              tooltip: "Retry creating embeddings for AI magic",
              onPressed: () {
                try {
                  EmbeddingService().runEmbeddingsForResponse(
                    responseId,
                    userId,
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
            ),
          );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ErrorColors.errorBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ErrorColors.errorTextColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: CustomIconButton(
        icon: Icons.delete_outline,
        iconSize: 14,
        padding: 6,
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
      ),
    );
  }

  Widget _buildAiMagicResponse(BuildContext context, String aiResponseText) {
    if (aiResponseText.isNotEmpty) {
      try {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: InfoCard(
            question: aiResponseText,
            reason: "",
            calloutText: 'AI',
            questionFontSize: 12,
            calloutTextFontSize: 10,
          ),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Action buttons row
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                _buildEmbeddingStatus(context),
                const SizedBox(width: 8),
              ],
              _buildDeleteButton(context),
            ],
          ),
          const SizedBox(height: 8),
          
          // Main message bubble
          isAiMagicResponse == 1
              ? _buildAiMagicResponse(context, responseText)
              : Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor.withOpacity(0.9),
                            ],
                          )
                        : null,
                    color: isUser ? null : AppColors.surfaceColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(6),
                      bottomRight: isUser
                          ? const Radius.circular(6)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                    border: isUser
                        ? null
                        : Border.all(
                            color: BorderColors.tertiaryColor,
                            width: 1,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Message text
                      Text(
                        responseText,
                        style: TextStyles.responseText(context).copyWith(
                          color: isUser
                              ? Colors.white
                              : TextColors.primaryTextColor,
                          height: 1.4,
                        ),
                      ),
                      
                      // Attachments
                      if (attachments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ..._buildAttachments(context, attachments),
                      ],
                    ],
                  ),
                ),
          
          // Timestamp
          Container(
            margin: const EdgeInsets.only(top: 6, left: 8, right: 8),
            child: Text(
              responseDate,
              style: TextStyles.smallSupplementalInfo(context).copyWith(
                color: TextColors.hintTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
