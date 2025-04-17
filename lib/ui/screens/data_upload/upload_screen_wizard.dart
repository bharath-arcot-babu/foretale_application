//core
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/csv_file_analysis.dart';
import 'package:foretale_application/ui/screens/data_upload/column_mapping_screen.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:path/path.dart' as path;
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/services/s3_activites.dart';
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_icon.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';

class UploadScreenWizard extends StatefulWidget {
  @override
  State<UploadScreenWizard> createState() => _UploadScreenWizardState();
}

class _UploadScreenWizardState extends State<UploadScreenWizard> with SingleTickerProviderStateMixin {
  final String _currentFileName = "upload_screen_wizard.dart";

  late TabController _tabController;
  late ProjectDetailsModel projectDetailsModel;
  late UploadSummaryModel uploadSummaryModel;
  FilePickerResult? filePickerResult;
  S3Service s3Service = S3Service();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    uploadSummaryModel = Provider.of<UploadSummaryModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      title: "Data upload wizard",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 4,
            labelStyle: TextStyles.tabSelectedLabelText(context),
            unselectedLabelStyle: TextStyles.tabUnselectedLabelText(context),
            tabs: [
              buildTab(icon: Icons.grid_4x4_rounded, label: 'Choose a table'),
              buildTab(icon: Icons.upload, label: 'Column Mapping'),
              buildTab(icon: Icons.confirmation_num, label: 'Confirm Upload'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildTabChooseTable(),
                const ColumnMappingScreen(),
                const Center(
                  child: Text(
                    "Confirm Upload",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildTab(
      {required IconData icon,
      required String label,
      Color color = AppColors.primaryColor}) {
    return Tab(
      child: FittedBox(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyles.subjectText(context),
          ),
        ],
      )),
    );
  }

  Widget buildTabChooseTable() {
    return Consumer<UploadSummaryModel>(
      builder: (context, uploadSummaryModel, _) {
        final uploadSummaryList = uploadSummaryModel.getUploadSummaryList;

        if (uploadSummaryList.isEmpty) {
          return Center(
            child: Text(
              "No tables available",
              style: TextStyles.topicText(context),
            ),
          );
        }

        final sortedTables = [...uploadSummaryList]..sort((a, b) => a.tableName.compareTo(b.tableName));

        return Column(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: sortedTables.length,
                itemBuilder: (context, index) {
                  final table = sortedTables[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                          childrenPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          collapsedBackgroundColor:
                              Theme.of(context).colorScheme.surface,
                          expandedAlignment: Alignment.topLeft,
                          title: Text(
                            table.simpleText,
                            style: TextStyles.titleText(context),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                CustomChip(
                                  label: "${table.rowCount}",
                                  leadingIcon: Icons.grid_3x3,
                                ),
                                const SizedBox(width: 8),
                                CustomChip(
                                  label: table.componentName,
                                  leadingIcon: Icons.calendar_month,
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconButton(
                                  icon: Icons.cloud_upload_rounded,
                                  onPressed: () async {
                                    await pickFile(table.tableId);
                                  },
                                  tooltip:
                                      "Upload data for ${table.simpleText}"),
                              const SizedBox(width: 8),
                              const CustomIcon(
                                  icon: Icons.keyboard_arrow_down_rounded,
                                  size: 20),
                            ],
                          ),
                          children: [
                            const Divider(height: 1),
                            if (table.uploads.isNotEmpty)
                              ...table.uploads.map((file) => ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 4),
                                    leading: const CustomIcon(
                                      icon: Icons.insert_drive_file_rounded,
                                      size: 20,
                                    ),
                                    title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file.fileName,
                                            style: TextStyles.subtitleText(
                                                context),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "${file.rowCount.toString()} Rows",
                                                style: TextStyles.smallSupplementalInfo(context),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "${(file.fileSizeInBytes / (1024)).toStringAsFixed(2)} KB",
                                                style: TextStyles.smallSupplementalInfo(context),
                                              )
                                            ],
                                          )
                                        ]),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                            // Column Mapping Status
                                        CustomIconButton(
                                          icon: file.uploadStatus == 1
                                              ? Icons.task_alt_rounded
                                              : Icons.rule_folder_rounded,
                                          iconColor: file.uploadStatus == 1 
                                              ? Colors.blueAccent 
                                              : Colors.orange,
                                          onPressed: () {
                                            moveToMapping(table.tableId, file.fileUploadId, table.simpleText, file.fileName);
                                          },
                                          tooltip: file.uploadStatus == 1
                                              ? "Column mapping complete"
                                              : "Column mapping pending",
                                        ),
                                        const SizedBox(width: 8),

                                        // Data Quality Status
                                        CustomIconButton(
                                          icon: file.uploadStatus == 1
                                              ? Icons.warning_amber_rounded
                                              : Icons.verified_rounded,
                                          iconColor: file.uploadStatus == 1 
                                              ? Colors.amber 
                                              : Colors.green,
                                          onPressed: () {},
                                          tooltip: file.uploadStatus == 1
                                              ? "Data quality issues found"
                                              : "Data quality passed",
                                        ),
                                        const SizedBox(width: 8),
                                        CustomIconButton(
                                          icon: file.uploadStatus == 1
                                              ? Icons.warning_amber_rounded
                                              : Icons.verified_rounded,
                                          iconColor: file.uploadStatus == 1 
                                              ? Colors.lightGreen 
                                              : Colors.redAccent,
                                          onPressed: () {},
                                          tooltip: file.errorMessage,
                                        ),
                                        const SizedBox(width: 8),
                                        CustomIconButton(
                                            icon: Icons.delete_rounded,
                                            onPressed: () async {
                                              await deleteFile(
                                                  file.filePath,
                                                  file.fileName,
                                                  file.fileUploadId);
                                            },
                                            tooltip: "Delete file"),
                                        const SizedBox(width: 8),
                                        CustomIconButton(
                                            icon: Icons.download_rounded,
                                            onPressed: () async {
                                              await downloadFile(
                                                  file.filePath, file.fileName);
                                            },
                                            tooltip: "Download file"),
                                      ],
                                    ),
                                  ))
                            else
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    "No files uploaded yet",
                                    style: TextStyles.subtitleText(context),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ]);
      },
    );
  }

  void moveToMapping(int tableId, int fileUploadId, String tableName, String fileName) {
    try{
      uploadSummaryModel.activeTableSelectionId = tableId;
      uploadSummaryModel.activeFileUploadId = fileUploadId;
      uploadSummaryModel.activeTableSelectionName = tableName;
      uploadSummaryModel.activeFileUploadSelectionName = fileName;

      _tabController.index = 1;
      _tabController.animateTo(1);

    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, 
            e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "deleteFile");
    }
  }


  Future<void> deleteFile(String filePath, String fileName, int fileUploadId) async{
    try{
      if (!await showConfirmDialog(
          context: context,
          title: "Confirm Delete",
          content: "Are you sure you want to delete this file?")) {
        return;
      }
      
      await s3Service.deleteFile(path.join(filePath, fileName));
      await uploadSummaryModel.deleteFileUpload(context, fileUploadId);
      await uploadSummaryModel.fetchFileUploadsByProject(context);
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, 
            e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "deleteFile");
    }
  }

  Future<void> downloadFile(String filePath, String fileName) async{
    try{
      await s3Service.downloadFile(path.join(filePath, fileName));
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, 
            e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "downloadFile");
    }
  }

  Future<void> pickFile(int tableId) async {
    String storagePath = 'public/data/${projectDetailsModel.getActiveProjectId}/${projectDetailsModel.getProjectTypeId}/$tableId';

    try{
        filePickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
          allowMultiple: true,
          readSequential: true,
          withData: true,
        );

        if (filePickerResult != null) {
          for (var file in filePickerResult!.files) {

            final csvDetails = await CsvUtils.readTopRowsFromCsv(file);

            await s3Service.uploadFile(file, storagePath);

            await uploadSummaryModel.insertFileUpload(
              context,
              storagePath,
              file.name,
              file.extension ?? "",
              file.size,
              0,
              0,
              tableId,
              jsonEncode(csvDetails),
            );
        }

        await uploadSummaryModel.fetchFileUploadsByProject(context);

        filePickerResult = null;
      }
    } catch (e, error_stack_trace) {

      SnackbarMessage.showErrorMessage(context, 
            e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "pickFile");
    }
  }

  Future<void> _loadPage() async {
    try{
      await uploadSummaryModel.fetchFileUploadsByProject(context);
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
