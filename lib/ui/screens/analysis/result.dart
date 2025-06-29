import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/utils/empty_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_generic_grid.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
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

  @override
  void initState() {
    super.initState();
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
      await resultModel.fetchResultMetadata(context, widget.test);
      await resultModel.fetchResultData(context, widget.test);
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
        title: Row(
          children: [
            const Icon(Icons.table_view_outlined, color: Colors.white, size: 24),
            Text(
              widget.test.testName,
              style: TextStyles.titleText(context).copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Row(
          children: [
            // Top section
            Expanded(
              child: ModernContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildLeftSection(),
                    ),
                  ],
                ),
              ),
            ),
            //const SizedBox(height: 16),
            // Bottom section
            /*Expanded(
              flex: 1,
              child: ModernContainer(
                padding: EdgeInsets.zero,
                child: _buildRightSection(),
              ),
            ),*/
          ],
        ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          _showMenuOptions(context);
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.menu),
      ),
    );
  }

  Widget _buildLeftSection() {
    return Consumer<ResultModel>(
      builder: (context, resultModel, child) {
        final columns = resultModel.genericGridColumns;
        final sampleData = resultModel.tableData;

        // Add null safety checks
        if (columns.isEmpty || sampleData.isEmpty) {
          return const EmptyState(
            title: "No Results Found",
            subtitle: "Please ensure the test has been run and configured correctly.",
            icon: Icons.table_view_outlined,
          );
        }

        try {
          final dataSource = GenericDataSource<Map<String, dynamic>>(
            data: sampleData,
            columnDefinitions: columns,
            context: context,
            itemToMap: (item) => item,
          );

          return Container(
            color: AppColors.primaryColor.withOpacity(0.05), // Different color to distinguish
            child: GenericDataGrid(
              columns: columns,
              dataSource: dataSource,
              showSearchBar: true,
            ),
          );
        } catch (e) {
          print("Error creating data source: $e");
          // Fallback: Show data as a simple list
          return ListView.builder(
            itemCount: sampleData.length,
            itemBuilder: (context, index) {
              final item = sampleData[index];
              return ListTile(
                title: Text('Row ${index + 1}'),
                subtitle: Text(item.toString()),
              );
            },
          );
        }
      },
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
