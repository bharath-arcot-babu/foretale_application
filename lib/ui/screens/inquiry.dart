//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/s3_activites.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_questions_inquiry.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  final String _currentFileName = "inquiry.dart";
  final TextEditingController _responseController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late InquiryQuestionModel inquiryQuestionModel;
  late UserDetailsModel userDetailsModel;
  late InquiryResponseModel inquiryResponseModel;
  late ProjectDetailsModel projectDetailsModel;
  FilePickerResult? filePickerResult;

  File? selectedFile;

  @override
  void initState() {
    super.initState();
    inquiryQuestionModel = Provider.of<InquiryQuestionModel>(context, listen: false);
    userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget padding = Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0),
        child: Row(children: [
          Expanded(
              flex: 3,
              child: CustomContainer(
                  title: "Choose a question",
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTextField(
                        controller: _searchController,
                        label: "Search...",
                        isEnabled: true,
                        onChanged: (value) {
                          inquiryQuestionModel.filterData(value.trim());
                        },
                      ),
                    ),
                    const Expanded(child: QuestionsInquiryGrid())
                  ]))),
          const SizedBox(
            width: 30,
          ),
          Expanded(flex: 2, child: Container(child: _buildChatScreen(context)))
        ]));

    return padding;
  }

  Widget _buildChatScreen(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<InquiryResponseModel>(
            builder: (context, inquiryResponseModel, child) {
              List<InquiryResponse> data = inquiryResponseModel.getResponseList;
              return ListView.builder(
                reverse: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  bool isUser = data[index].responseByMachineId == userDetailsModel.getUserMachineId;
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.blue.shade200
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10),
                          topRight: const Radius.circular(10),
                          bottomLeft:
                              isUser ? const Radius.circular(10) : Radius.zero,
                          bottomRight:
                              isUser ? Radius.zero : const Radius.circular(10),
                        ),
                      ),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data[index].responseText,
                              style: TextStyles.responseText(context)),
                          
                          if (data[index].attachments.isNotEmpty) ...[
                            const SizedBox(height: 5),                                             
                            for (var attachment in data[index].attachments)
                              Row(
                                children: [

                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        // Implement file download functionality

                                        S3Service().downloadFile('${attachment.filePath}/${attachment.fileName}');
                                        //_downloadFile(attachment.fileUrl); // Ensure fileUrl is available
                                      },
                                      child: Text(
                                        "${attachment.fileName} (${attachment.fileSize} KB)",
                                        style: TextStyles.responseTextFileInfo(context).copyWith(
                                          color: Colors.blue, // Make it look like a link // Underline for a link effect
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children:[
                              Text(data[index].responseBy,
                                  style: TextStyles.smallSupplementalInfo(
                                      context)),
                              const SizedBox(height: 3,),
                              Text(
                                  data[index].responseDate,
                                  style: TextStyles.smallSupplementalInfo(
                                      context)),
                            ])],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  void removeFile(int index) {
  if (filePickerResult != null) {
    filePickerResult!.files.removeAt(index);
    setState(() {}); // Refresh UI after removal
  }
}

  Widget _buildFileList() {
  return filePickerResult != null && filePickerResult!.files.isNotEmpty
      ? Column(
          children: filePickerResult!.files.asMap().entries.map((entry) {
            int index = entry.key;
            PlatformFile file = entry.value;
            return ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text(file.name, overflow: TextOverflow.ellipsis, style: TextStyles.responseTextFileInfo(context),),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => removeFile(index),
              ),
            );
          }).toList(),
        )
      : const SizedBox(); // Show nothing if no files are selected
}

Widget _buildInputArea() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFileList(),
        Selector<InquiryQuestionModel, int>(
          selector: (context, inquiryQuestionModel) =>
              inquiryQuestionModel.getSelectedInquiryQuestionId,
          builder: (context, id, child) {
            return CustomTextField(
              controller: _responseController,
              label: "Type your response...",
              maxLines: 6,
              isEnabled: id > 0,
              onChanged: (null),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.blue),
              onPressed: pickFile,
              tooltip: "Attach File",
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: addResponse,
              tooltip: "Send Response",
            ),
          ],
        ),
        
      ],
    ),
  );
}

  void addResponse() async {
    int insertedId = 0;
    int insertedAttachmentId = 0;

    try {
      if (_responseController.text.trim().isNotEmpty) {
        
        insertedId = await inquiryResponseModel.insertResponseByQuestion(context, _responseController.text);
        
        if (insertedId > 0) {
          inquiryResponseModel.updateResponseIdSelection(insertedId);

          if (filePickerResult != null) {
            String storagePath =
                'public/inquiry/${projectDetailsModel.getActiveProjectId}/${inquiryQuestionModel.getSelectedInquiryQuestionId}/${inquiryResponseModel.getSelectedInquiryResponseId}';

            for (var file in filePickerResult!.files) {
              await S3Service().uploadFile(file, storagePath);
              insertedAttachmentId =
                  await inquiryResponseModel.insertAttachmentByResponse(
                      context,
                      storagePath,
                      file.name,
                      file.extension ?? "",
                      int.parse((file.size / (1024)).round().toString()));
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

  Future<void> pickFile() async {
    
    FilePickerResult? newFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg', 'png', 'svg', 'pdf', 'csv', 'msg',
        'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'
      ],
      allowMultiple: true,
      withReadStream: true,
      withData: false,
    );

    if (newFiles != null) {
      
      if (filePickerResult == null) {
        filePickerResult = newFiles;
      } else {
        // Convert existing file names to a Set for quick lookup
        Set<String> existingFiles = filePickerResult!.files.map((f) => f.name).toSet();

        // Filter new files that are not already in the set
        List<PlatformFile> uniqueFiles = newFiles.files
            .where((f) => !existingFiles.contains(f.name))
            .toList();
        filePickerResult!.files.addAll(uniqueFiles);
      }
      setState(() {});
    }
  }

  Future<void> _loadResponses() async {
    await inquiryResponseModel.fetchResponsesByQuestion(context);
  }

  Future<void> _loadPage() async {
    try{
      await inquiryQuestionModel.fetchQuestionsByProject(context);

      if (inquiryQuestionModel.getSelectedInquiryQuestionId > 0) {
        await _loadResponses();
      }
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, 
            e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_loadPage");
    }
  }
}
