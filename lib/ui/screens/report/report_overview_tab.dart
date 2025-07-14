import 'package:flutter/material.dart';
import 'package:foretale_application/models/report_model.dart';
import 'package:foretale_application/ui/screens/report/report_header.dart';
import 'package:foretale_application/ui/screens/report/report_stats.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/themes/scaffold_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';

class ReportOverviewTab extends StatefulWidget {
  const ReportOverviewTab({super.key});

  @override
  State<ReportOverviewTab> createState() => _ReportOverviewTabState();
}

class _ReportOverviewTabState extends State<ReportOverviewTab> {
  final ExecutionStatsModel executionStatsModel = ExecutionStatsModel();
  bool isPageLoading = false;
  String loadText = "Loading report...";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isPageLoading = true;
        loadText = "Loading report...";
      });
      await executionStatsModel.getExecutionStats(context);
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
          ),
        ):
    Container(
      decoration: ScaffoldStyles.layoutBodyPanelBoxDecoration(),
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildSectionCard(
              child: buildReportHeader(context),
              title: "Report Overview",
              icon: Icons.assessment,
            ),
            const SizedBox(height: 20),
            
            // Statistics Section
            _buildSectionCard(
              child: buildStatisticsCard(context, executionStatsModel),
              title: "Execution Statistics",
              icon: Icons.analytics,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    required String title,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: BorderColors.tertiaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: BorderColors.tertiaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (context) => Text(
                      title,
                      style: TextStyles.titleText(context).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Container(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
} 