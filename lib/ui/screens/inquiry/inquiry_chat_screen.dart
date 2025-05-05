import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/s3_activites.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/core/utils/util_date.dart';
import 'package:file_picker/file_picker.dart';

class InquiryChatScreen extends StatefulWidget {
  final TextEditingController responseController = TextEditingController();
  final String callingFrom;

  InquiryChatScreen({
    super.key,
    required this.callingFrom
  });

  @override
  State<InquiryChatScreen> createState() => _InquiryChatScreenState();
}

class _InquiryChatScreenState extends State<InquiryChatScreen> {
  final ScrollController _scrollController = ScrollController();
  FilePickerResult? filePickerResult;
  late TextEditingController _responseController;

  @override
  void initState() {
    super.initState();
    _responseController = widget.responseController;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userMachineId = Provider.of<UserDetailsModel>(context).getUserMachineId;

    return Column(
      children: [
        Expanded(
          child: ModernContainer(
            child: Consumer<InquiryResponseModel>(
              builder: (context, inquiryResponseModel, child) {
                List<InquiryResponse> data = inquiryResponseModel.getResponseList;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(15),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final isUser = item.responseByMachineId == userMachineId;
                    final bool showAvatar = index == data.length - 1 || data[index + 1].responseByMachineId != item.responseByMachineId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser && showAvatar)
                            _buildAvatar(item.responseBy),
                          if (!isUser && !showAvatar) 
                            const SizedBox(width: 36),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? theme.colorScheme.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: isUser
                                          ? const Radius.circular(18)
                                          : const Radius.circular(4),
                                      bottomRight: isUser
                                          ? const Radius.circular(4)
                                          : const Radius.circular(18),
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
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.75,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.responseText,
                                        style: TextStyles.responseText(context),
                                      ),
                                      if (item.attachments.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        ..._buildAttachments(item.attachments),
                                      ],
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4, left: 4, right: 4),
                                  child: Text(
                                    item.responseDate,
                                    style: TextStyles.smallSupplementalInfo(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isUser && showAvatar)
                            _buildAvatar(item.responseBy, isUser: true),
                          if (isUser && !showAvatar) const SizedBox(width: 36),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        _buildInputArea(context),
      ],
    );
  }


  Future<void> _addResponse() async {
    int insertedId = 0;
    int insertedAttachmentId = 0;

    final inquiryResponseModel =
        Provider.of<InquiryResponseModel>(context, listen: false);
    final projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);
    final inquiryQuestionModel =
        Provider.of<InquiryQuestionModel>(context, listen: false);

    try {
      if (_responseController.text.isNotEmpty) {

        if(widget.callingFrom == "inquiry") {
            insertedId = await inquiryResponseModel.insertResponseByQuestion(
            context,
            _responseController.text,
          );
        } else if (widget.callingFrom == "test_config") {
            insertedId = await inquiryResponseModel.insertResponseByTest(
            context,
            _responseController.text,
          );
        }

        

        if (insertedId > 0) {
          inquiryResponseModel.updateResponseIdSelection(insertedId);

          if (filePickerResult != null) {
            String storagePath = 'public/inquiry/${projectDetailsModel.getActiveProjectId}/${inquiryQuestionModel.getSelectedInquiryQuestionId}/${inquiryResponseModel.getSelectedInquiryResponseId}';

            for (var file in filePickerResult!.files) {
              await S3Service().uploadFile(file, storagePath);

              insertedAttachmentId =
                  await inquiryResponseModel.insertAttachmentByResponse(
                context,
                storagePath,
                file.name,
                file.extension ?? "",
                int.parse((file.size / 2048).round().toString()),
              );
            }
          }

          setState(() {
            _responseController.clear();
            filePickerResult = null;
          });
        }
        await inquiryResponseModel.fetchResponsesByQuestion(context);
      }
    } catch (e) {
      if (insertedId == 0) {
        SnackbarMessage.showErrorMessage(
            context, "Unable to save the response.");
        return;
      }

      if (insertedAttachmentId == 0) {
        SnackbarMessage.showErrorMessage(context, "Error adding attachments.");
        return;
      }
    }
  }

  Future<void> _pickFile() async {
    filePickerResult = await FilePicker.platform.pickFiles(allowMultiple: true);
    setState(() {});
  }

  Widget _buildAvatar(String name, {bool isUser = false}) {
    final String initials = name.isNotEmpty
        ? name
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join()
        : '?';

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser ? Colors.blue.shade700 : Colors.orange.shade700,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  List<Widget> _buildAttachments(List<dynamic> attachments) {
    return attachments.map((attachment) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(attachment.fileName),
              size: 18,
              color: Colors.blue.shade700,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                attachment.fileName,
                style: TextStyles.responseTextFileInfo(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "(${attachment.fileSize} MB)",
              style: TextStyles.smallSupplementalInfo(context),
            ),
          ],
        ),
      );
    }).toList();
  }

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

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Selector<InquiryQuestionModel, int> (
        selector: (context, model) => model.getSelectedInquiryQuestionId,
        builder: (context, selectedId, _) {
          final isEnabled = selectedId > 0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.attach_file_rounded,
                  color: isEnabled
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                ),
                onPressed: isEnabled ? _pickFile : null,
                tooltip: "Attach File",
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _responseController,
                  enabled: isEnabled,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color:
                    isEnabled ? theme.colorScheme.primary : theme.disabledColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: isEnabled ? _addResponse : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
