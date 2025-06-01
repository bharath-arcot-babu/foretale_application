import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/services/lambda_activities.dart';
import 'package:foretale_application/config_lambda_api.dart';
import 'package:foretale_application/models/columns_model.dart';
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_info_card.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/ui/widgets/custom_static_list_view.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';

class UploadConfirmationPage extends StatefulWidget {
  const UploadConfirmationPage({super.key});

  @override
  State<UploadConfirmationPage> createState() => _UploadConfirmationPageState();
}

class _UploadConfirmationPageState extends State<UploadConfirmationPage> {
  bool isPageLoading = false;
  String loadText = 'Loading...';
  final String _currentFileName = "upload_confirmation.dart";
  late ColumnsModel columnsModel;
  late UploadSummaryModel uploadSummaryModel;
  late UserDetailsModel userDetailsModel;

  Map<String, String?> selectedMappings = {};
  String fileName = '';

  @override
  void initState() {
    super.initState();
    columnsModel = Provider.of<ColumnsModel>(context, listen: false);
    uploadSummaryModel =
        Provider.of<UploadSummaryModel>(context, listen: false);
    userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

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
        : SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoCard(
                        icon: Icons.description_outlined,
                        label: 'File to upload',
                        value: fileName,
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Text('Column Mappings',
                              style: TextStyles.topicText(context)),
                          const SizedBox(width: 8),
                          Text('(${selectedMappings.length})',
                              style: TextStyles.topicText(context)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 👇 Scrollable list with fixed height
                      Expanded(
                        child: StaticListCard(
                          mappings: selectedMappings,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 👇 Privacy disclaimer
                      Text(
                        'After confirmation, your file will be securely uploaded and processed based on the column mappings you’ve provided. We take data privacy seriously — your data will be handled responsibly and used only for the purpose of transforming and storing it within your designated system. We do not use your data for training AI models, analytics, or any third-party services. Your information remains private, protected, and fully under your control throughout the process.',
                        style: TextStyles.footerDisclaimerSmall(context),
                      ),

                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: CustomElevatedButton(
                          width: 80,
                          height: 56,
                          text: 'Confirm Upload',
                          textSize: 14,
                          onPressed: _startUpload,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  Future<void> _loadPage() async {
    selectedMappings = Map.from(columnsModel.activeSelectedMappings);
    fileName = uploadSummaryModel.activeFileUploadSelectionName;
  }

  void _startUpload() {
    try {
      setState(() {
        isPageLoading = true;
        loadText = 'Initiating upload process...';
      });

      Map<String, dynamic> payload = {
        'user_id': userDetailsModel.getUserMachineId,
        'file_upload_id': uploadSummaryModel.activeFileUploadId,
      };

      LambdaHelper(apiGatewayUrl: LambdaApiConfig.dataUploadInvoker)
          .invokeLambda(
        payload: payload,
      );

      setState(() => isPageLoading = false);

      SnackbarMessage.showSuccessMessage(
        context,
        "Data upload initiated successfully.",
      );
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_startUpload");
    }
  }
}
