import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/services/llms/prompts/csv_analysis_prompt.dart';
import 'package:foretale_application/core/services/llms/api/llm_api.dart';
import 'package:foretale_application/models/columns_model.dart';
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_ai_magic_button.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_list.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';

class ColumnMappingScreen extends StatefulWidget {
  final VoidCallback onConfirm;

  const ColumnMappingScreen({super.key, required this.onConfirm});

  @override
  State<ColumnMappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<ColumnMappingScreen> {
  bool isPageLoading = false;
  String loadText = 'Loading...';
  final String _currentFileName = "column_mapping_screen.dart";
  late ColumnsModel columnsModel;
  late UploadSummaryModel uploadSummaryModel;

  Map<String, String?> selectedMappings = {};

  @override
  void initState() {
    super.initState();
    columnsModel = Provider.of<ColumnsModel>(context, listen: false);
    uploadSummaryModel =
        Provider.of<UploadSummaryModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isPageLoading = true;
        loadText = "Loading column mappings...";
      });
      await _loadPage();
      setState(() {
        isPageLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isPageLoading
        ? Center(
            child: LinearLoadingIndicator(
            isLoading: isPageLoading,
            width: 200,
            height: 6,
            color: AppColors.primaryColor,
            loadingText: loadText,
          ))
        : Consumer<ColumnsModel>(
            builder: (context, consumeColumnModel, _) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // AI Magic Button
                        AiMagicIconButton(
                          onPressed: () async {
                            final confirmed = await showConfirmDialog(
                              context: context,
                              title: "AI Magic",
                              cancelText: "NO",
                              confirmText: "YES",
                              confirmTextColor: Colors.green,
                              content:
                                  "AI Magic will attempt to automatically map your columns using AI. This will replace any existing mappings, and results may not be fully accurate. Would you like to continue?",
                            );
                            if (confirmed == true) {
                              callingLLM(
                                consumeColumnModel.sourceFields,
                                consumeColumnModel.destinationFieldMap.entries
                                    .map((e) => e.key)
                                    .toList(),
                              );
                            }
                          },
                          tooltip: 'Auto Map Columns',
                          iconSize: 18.0,
                        ),
                        const SizedBox(width: 10),
                        CustomElevatedButton(
                          height: 40,
                          width: 300,
                          onPressed: () {
                            handleMappingConfirm();
                          },
                          text: 'Save Mappings',
                          textSize: 16,
                          icon: Icons.save,
                        ),
                        const SizedBox(width: 10),
                        CustomElevatedButton(
                          height: 40,
                          width: 300,
                          onPressed: () {
                            confirmAndUpload();
                          },
                          text: 'Confirm and Upload',
                          textSize: 16,
                          icon: Icons.save,
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        children: [
                          // Source Fields
                          Expanded(
                            flex: 2,
                            child: CustomContainer(
                              title:
                                  "Fields from ${uploadSummaryModel.getActiveFileUploadSelectionName}",
                              child: SingleChildScrollView(
                                child: buildSourceFieldsList(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Destination Mappings with Dropdowns
                          Expanded(
                            flex: 2,
                            child: CustomContainer(
                              title:
                                  "Field mapping for the target table ${uploadSummaryModel.getActiveTableSelectionName}",
                              child: SingleChildScrollView(
                                  child: buildCustomDropdownMappingList(
                                context,
                                labels: consumeColumnModel.destinationFieldMap,
                                options: consumeColumnModel.sourceFields,
                                selectedValues: selectedMappings,
                                onChanged: (label, value) {
                                  setState(() {
                                    if (value == null) {
                                      selectedMappings.remove(label);
                                    } else {
                                      selectedMappings[label] = value;
                                    }
                                  });
                                },
                              )),
                            ),
                          ),
                          if (selectedMappings.isNotEmpty &&
                              selectedMappings.values
                                  .any((value) => value?.isNotEmpty ?? false))
                            Expanded(
                              flex: 1,
                              child: SizedBox.expand(
                                child: SingleChildScrollView(
                                  child: buildMappingSummaryChips(
                                      selectedMappings),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget buildSourceFieldsList() {
    return Consumer<ColumnsModel>(
      builder: (context, consumeColumnModel, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: consumeColumnModel.sourceFieldInfo.map<Widget>((column) {
            final fieldName = column['name'];
            final metadata = column['metadata'] ?? {};
            final type = metadata['type'] ?? 'Unknown';
            final maxLength = metadata['maxLength'] ?? 0;
            final samples =
                (metadata['sampleValues'] as List?)?.take(5).toList() ?? [];

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fieldName,
                          style: TextStyles.subtitleText(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            CustomChip(label: type),
                            CustomChip(label: 'Length: $maxLength'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sample Values",
                          style: TextStyles.topicText(context),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: samples.map((sample) {
                            return CustomChip(label: "$sample");
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildMappingSummaryChips(Map<String, String?> selectedMappings) {
    final validMappings = selectedMappings.entries
        .where((entry) => (entry.value ?? '').trim().isNotEmpty)
        .toList();

    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: (CustomContainer(
          title: "Mapping Summary",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                direction: Axis.vertical,
                children: validMappings.map((entry) {
                  return CustomChip(
                    label: '${entry.value} → ${entry.key}',
                    backgroundColor: Colors.grey.shade100,
                  );
                }).toList(),
              ),
            ],
          ),
        )));
  }

  void handleMappingConfirm() {
    try {
      if (selectedMappings.isEmpty) {
        SnackbarMessage.showErrorMessage(
            context, "Please select at least one mapping.");
        return;
      }

      columnsModel.activeSelectedMappings = selectedMappings;

      Map<String, String?> dbCompatibleMappings = {
        for (var entry in columnsModel.technicalFieldMap.entries)
          columnsModel.technicalFieldMap[entry.key]!:
              selectedMappings[entry.key]
      };

      String jsonString = jsonEncode(dbCompatibleMappings);
      columnsModel.updateFileUpload(context, jsonString);

      SnackbarMessage.showSuccessMessage(
          context, "Mappings are saved successfully");
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "callMistral");
    }
  }

  void confirmAndUpload() {
    try {
      if (selectedMappings.isEmpty) {
        SnackbarMessage.showErrorMessage(
            context, "Please select at least one mapping.");
        return;
      }

      widget.onConfirm();

      columnsModel.activeSelectedMappings = selectedMappings;

      Map<String, String?> dbCompatibleMappings = {
        for (var entry in columnsModel.technicalFieldMap.entries)
          columnsModel.technicalFieldMap[entry.key]!:
              selectedMappings[entry.key]
      };

      String jsonString = jsonEncode(dbCompatibleMappings);
      columnsModel.updateFileUpload(context, jsonString);
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "callMistral");
    }
  }

  Future<void> callingLLM(List<String> source, List<String> destination) async {
    try {
      CsvPrompts prompts = CsvPrompts();
      String callingPrompt = prompts.matchSourceDestinationColumns
          .buildPromptForMatch(source, destination);
      final modelOuput = await LLMService()
          .callLLMGeneralPurpose(prompt: callingPrompt, maxTokens: 2000);

      final rawMappings = modelOuput["mappings"];
      if (rawMappings is Map) {
        final cleanMappings = rawMappings.entries
            .where((entry) =>
                (entry.key?.toString().trim().isNotEmpty ?? false) &&
                (entry.value?.toString().trim().isNotEmpty ?? false))
            .map((entry) => MapEntry(
                  entry.value.toString().trim(), // Destination → Source
                  entry.key.toString().trim(),
                ));

        if (!mounted) return;
        if (cleanMappings.isNotEmpty) {
          setState(() {
            selectedMappings = Map<String, String>.fromEntries(cleanMappings);
          });
        } else {
          SnackbarMessage.showErrorMessage(context, "No match found!");
        }
      }
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "callMistral");
    }
  }

  Future<void> _loadPage() async {
    try {
      if (!mounted) return;
      var columnModel = Provider.of<ColumnsModel>(context, listen: false);
      await columnsModel.fetchColumnsByTable(context);
      await columnsModel.fetchColumnsCsvDetails(context);

      Map<String, String?> uiCompatibleMappings = {
        for (var entry in columnsModel.technicalFieldMap.entries)
          if (columnModel.columnMappings[entry.value] != null)
            entry.key: columnModel.columnMappings[entry.value]!
      };

      if (!mounted) return;
      selectedMappings = uiCompatibleMappings;
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    }
  }
}
