import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/utils/empty_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/chat/chat_screen.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/ui/widgets/custom_toggle.dart';
import 'package:foretale_application/ui/widgets/data_statistics_panel.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatefulWidget {
  final Test test;
  const ResultScreen({super.key, required this.test});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _fabKey = GlobalKey();
  bool isPageLoading = false;
  String loadText = 'Loading results...';
  final String _currentFileName = "result.dart";
  final GlobalKey<GenericDataGridState> gridKey = GlobalKey<GenericDataGridState>();
  bool showFlaggedTransactions = false;
  bool isUpdatingCheckboxes = false;
  late InquiryResponseModel inquiryResponseModel;
  bool isLoadingResponses = false;

  @override
  void initState() {
    super.initState();
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isPageLoading = true;
        loadText = "Loading...";
      });
      await _loadPage();
      setState(() {
        isPageLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPage() async {
    if (!mounted) return;
    try {
      final resultModel = Provider.of<ResultModel>(context, listen: false);
      await resultModel.updateDataGrid(context, widget.test);
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
              Navigator.pop(context);
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
                          columns: resultModel.genericGridColumns,
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
            Expanded(
              flex: 3,
              child: _buildFlaggedTransactionsRightSection(context, resultModel, data, columns),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFlaggedTransactionsRightSection(BuildContext context, ResultModel resultModel, List<Map<String, dynamic>> data, List<GenericGridColumn> columns) {
    return 
    ModernContainer(
      padding: const EdgeInsets.all(16),
      child: Selector<ResultModel, int>(
        selector: (context, model) => model.getSelectedId(context),
        builder: (context, selectedId, __) {
          return ChatScreen(
            drivingModel: resultModel,
            isChatEnabled: selectedId > 0,
          );
        },
      ),
    );
  }

  Widget _buildFlaggedTransactionsLeftSection(BuildContext context, ResultModel resultModel, List<Map<String, dynamic>> data, List<GenericGridColumn> columns) {
    return Stack(
          children: [
            ModernContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 12,
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
                  GenericDataGrid(
                  key: gridKey,
                  columns: columns,
                  data: data,
                  showSearchBar: true,
                  checkboxInitializationColumn: 'is_selected',
                  onRowTap: (rowData, rowIndex) async {
                    final feedbackId = rowData['feedback_id'];
                    final isSelected = rowData['is_selected'];

                    await inquiryResponseModel.setIsPageLoading(true);
                    if (feedbackId != null && isSelected == true) {
                      resultModel.updateSelectedFeedback(feedbackId as int);
                      inquiryResponseModel.fetchResponsesByReference(context, feedbackId, 'feedback');

                    } else if (feedbackId != null && isSelected == false) {
                      resultModel.updateSelectedFeedback(0);
                      inquiryResponseModel.fetchResponsesByReference(context, 0, 'feedback');
                    }
                    await inquiryResponseModel.setIsPageLoading(false);
                  },
                  onSelectionChanged: (Set<int> selectedIndices) async {
                    try {
                      setState(() {
                        isUpdatingCheckboxes = true;
                      });
                      
                      final newSelectedData = gridKey.currentState?.getSelectedData() ?? [];
                      final existingSelectedData = data.where((item) => item['is_selected'] == true).toList();
                      int index = -1;

                      for(var existingItem in existingSelectedData){
                          index = newSelectedData.indexWhere((item) => (item['hash_key'] == existingItem['hash_key']));
                          if(index == -1 && existingItem['is_selected'] == true){
                            await resultModel.deleteFlaggedTransaction(context, widget.test, [existingItem]);
                          }
                      }

                      if (selectedIndices.isNotEmpty) {
                        await resultModel.insertFlaggedTransaction(context, widget.test, newSelectedData);
                      }
                      await resultModel.updateDataGrid(context, widget.test);
                      gridKey.currentState?.updateData(resultModel.filteredTableData);
                    } catch (e, error_stack_trace) {
                      SnackbarMessage.showErrorMessage(context, e.toString(),
                        logError: true,
                        errorMessage: e.toString(),
                        errorStackTrace: error_stack_trace.toString(),
                        errorSource: _currentFileName,
                        severityLevel: 'Critical',
                        requestPath: "_buildDataGridSection");
                    } finally {
                      if (mounted) {
                        setState(() {
                          isUpdatingCheckboxes = false;
                        });
                      }
                    }
                  },
                ),
              ],
              ),
            ),
            // Loading overlay
            if (isUpdatingCheckboxes)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Updating...',
                        style: TextStyles.subtitleText(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
  }

  Widget _buildRightSection() {
    
   return Center(
      child: Text(
        'Bottom Section',
        style: TextStyles.topicText(context),
      ),
    );
  }

  void _showMenuOptions(BuildContext context) {
    final RenderBox? button = _fabKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;
    
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    
    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy - 200, // Position above the button
      overlay.size.width - buttonPosition.dx - button.size.width,
      buttonPosition.dy + button.size.height,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: _buildMenuOption(
            context,
            'Export Results',
            Icons.download,
            () {
              Navigator.pop(context);
              // Add export functionality here
            },
          ),
        ),
        PopupMenuItem(
          child: _buildMenuOption(
            context,
            'Print Report',
            Icons.print,
            () {
              Navigator.pop(context);
              // Add print functionality here
            },
          ),
        ),
        PopupMenuItem(
          child: _buildMenuOption(
            context,
            'Share Results',
            Icons.share,
            () {
              Navigator.pop(context);
              // Add share functionality here
            },
          ),
        ),
        PopupMenuItem(
          child: _buildMenuOption(
            context,
            'Settings',
            Icons.settings,
            () {
              Navigator.pop(context);
              // Add settings functionality here
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: TextStyles.gridText(context)),
      onTap: onTap,
    );
  }
}
