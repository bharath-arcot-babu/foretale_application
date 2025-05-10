import 'package:flutter/material.dart';
import 'package:foretale_application/models/inquiry_attachment_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/services/s3_activites.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final ThemeData theme;
  final String responseText;
  final String responseDate;
  final List<InquiryAttachment> attachments;
  final double maxWidth;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.theme,
    required this.responseText,
    required this.responseDate,
    required this.attachments,
    this.maxWidth = 0.75, // Default max width is 75% of the screen width
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
                  final fileUrl =
                      await s3Service.getFileUrl(attachment.filePath);

                  if (fileUrl != null) {
                    // Open the file URL in the browser
                    // You'll need to add url_launcher package for this
                    // await launchUrl(Uri.parse(fileUrl));
                    SnackbarMessage.showSuccessMessage(
                      context,
                      "File URL: $fileUrl",
                    );
                  } else {
                    throw Exception("Failed to get file URL");
                  }
                } catch (e) {
                  print("Error getting file URL: ${e.toString()}");
                  SnackbarMessage.showErrorMessage(
                    context,
                    "Error accessing file: ${e.toString()}",
                  );
                }
              },
              tooltip: "Download ${attachment.fileName}",
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * maxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                responseText,
                style: TextStyles.responseText(context).copyWith(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
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
