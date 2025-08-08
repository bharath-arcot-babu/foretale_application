import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/utils/empty_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/chat/chat_screen.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/ui/widgets/custom_toggle.dart';
import 'package:foretale_application/ui/screens/analysis/data_statistics_panel.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatefulWidget {
  final Test test;
  final String pageTitle;
  const ResultScreen({super.key, required this.test, required this.pageTitle});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isPageLoading = false;
  String loadText = 'Loading results...';
  final String _currentFileName = "result.dart";

  bool showFlaggedTransactions = false;
  bool isUpdatingCheckboxes = false;
  bool isLoadingResponses = false;

  late InquiryResponseModel inquiryResponseModel;
  late ResultModel resultModel;
  late TestsModel testsModel;
  late UserDetailsModel userDetailsModel;

  @override
  void initState() {
    super.initState();
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    resultModel = Provider.of<ResultModel>(context, listen: false);
    testsModel = Provider.of<TestsModel>(context, listen: false);
    userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      setState(() {
        isPageLoading = true;
        loadText = "Loading...";
      });

      await _loadPage();

      if (mounted) {
        setState(() {
          isPageLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isPageLoading 
    ? 
    Center(
      child: LinearLoadingIndicator(
        isLoading: isPageLoading,
        loadingText: loadText,
        color: AppColors.primaryColor
      ),
    ) : 
    Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.test.testName,
                textAlign: TextAlign.center,
                style: TextStyles.titleText(context).copyWith(
                  color: AppColors.secondaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.test.testDescription,
                textAlign: TextAlign.center,
                style: TextStyles.subtitleText(context).copyWith(
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if(widget.pageTitle == 'Review'){
                testsModel.updateTestIdSelection(0);
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.cancel_outlined, color: AppColors.primaryColor),
            iconSize: 20,
          ),
        ],
        backgroundColor: AppColors.primaryColor.withOpacity(0.05),
        foregroundColor: AppColors.primaryColor,
      ),
      body: Consumer<ResultModel>(
        builder: (context, resultModel, child) {
          if (resultModel.genericGridColumns.isEmpty || resultModel.tableData.isEmpty) {
            return const EmptyState(
              title: "No Results Found",
              subtitle: "Please ensure the test has been run and configured correctly.",
              icon: Icons.table_view_outlined,
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Tab Bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primaryColor,
                    indicatorWeight: 4,
                    labelStyle: TextStyles.tabSelectedLabelText(context),
                    unselectedLabelStyle: TextStyles.tabUnselectedLabelText(context),
                    tabs: [
                      buildTab(
                        icon: Icons.analytics_outlined,
                        label: 'Snapshot',
                      ),
                      buildTab(
                        icon: Icons.table_view_outlined,
                        label: 'Flagged Transactions',
                      ),
                    ],
                  ),
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // Statistics Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: DataStatisticsPanel(
                          columns: resultModel
                                  .tableColumnsList
                                  .where((column) => !column.isFeedbackColumn)
                                  .toList(),
                          data: resultModel.tableData,
                        ),
                      ),
                      // Data Grid Tab
                      _buildDataGridSection(),
                    ],
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
    if (!mounted) return;
    try {
      await resultModel.updateDataGrid(context, widget.test);
    } catch (e, error_stack_trace) {
      if (mounted) {
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

  Widget _buildDataGridSection() {
    return Consumer<ResultModel>(
      builder: (context, resultModel, child) {
        final columns = resultModel.genericGridColumns;
        List<Map<String, dynamic>> data = resultModel.filteredTableData;

        return Row(
          children: [
            Expanded(
              flex: 8,
              child: _buildFlaggedTransactionsLeftSection(context, resultModel, data, columns),
            ),
            const SizedBox(width: 5),
            if(resultModel.getSelectedId(context) > 0)
            Expanded(
              flex: 3,
              child: _buildFlaggedTransactionsRightSection(context, resultModel, data, columns),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFlaggedTransactionsRightSection(BuildContext context, ResultModel resultModel, List<Map<String, dynamic>> data, List<CustomGridColumn> columns) {
    return Selector<ResultModel, int>(
      selector: (context, model) => model.getSelectedId(context),
      builder: (context, selectedId, __) {
        return ModernContainer(
          padding: const EdgeInsets.all(16),
          child: ChatScreen(
            key: ValueKey('result_chat_$selectedId'),
            drivingModel: resultModel,
            isChatEnabled: selectedId > 0,
            userId: userDetailsModel.getUserMachineId ?? "",
          ),
        );
      },
    );
  }

  Widget _buildFlaggedTransactionsLeftSection(BuildContext context, ResultModel resultModel, List<Map<String, dynamic>> data, List<CustomGridColumn> columns) {
    return ModernContainer(
        padding: const EdgeInsets.all(5),
        borderRadius: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomToggle(
                  value: showFlaggedTransactions,
                  width: 40,
                  height: 20,
                  onChanged: (value) {
                    setState(() {
                      showFlaggedTransactions = value;
                    });
                    resultModel.updateSelectedTransactions(value);
                  },
                )
              ]
            ),
            const SizedBox(height: 12),
            Expanded(
              child: CustomGrid(
                columns: columns,
                data: data,
                firstColumnName: 'is_selected',
                enablePagination: true,
                gridOnRowTap: (rowData, rowIndex) {
                  updateSelectedResultId(rowData['feedback_id']);
                },
              ),
            )
          ],
        ),
      );
  }

  Future<void> updateSelectedResultId(int selectedId) async{
    await inquiryResponseModel.setIsPageLoading(true);

    if(resultModel.getSelectedId(context) == selectedId) {
      resultModel.updateSelectedFeedback(0);
    } else {
      resultModel.updateSelectedFeedback(selectedId);
    }
    
    await inquiryResponseModel.fetchResponsesByReference(context, selectedId, 'feedback');

    await inquiryResponseModel.setIsPageLoading(false);
  }
}
