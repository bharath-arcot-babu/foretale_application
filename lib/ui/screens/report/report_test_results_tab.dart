import 'package:flutter/material.dart';
import 'package:foretale_application/ui/screens/report/report_summary.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/themes/scaffold_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class ReportTestResultsTab extends StatelessWidget {
  const ReportTestResultsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ScaffoldStyles.layoutBodyPanelBoxDecoration(),
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Summary Section
            _buildSectionCard(
              child: buildTestSummaryTable(),
              title: "Test Results Summary",
              icon: Icons.table_chart,
            ),
            const SizedBox(height: 20),
            
            // Additional Test Details Section
            _buildSectionCard(
              child: _buildTestDetails(),
              title: "Test Execution Details",
              icon: Icons.info_outline,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTestDetails() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test Execution Timeline
          _buildDetailItem(
            context,
            "Test Execution Timeline",
            "Timeline of test execution and completion",
            [
              "• P2P-DQ-001: Completed on 2025-07-01 at 14:30",
              "• P2P-DQ-002: Completed on 2025-07-01 at 15:45",
              "• P2P-DQ-003: Completed on 2025-07-01 at 16:20",
            ],
            Icons.schedule,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          
          // Data Coverage
          _buildDetailItem(
            context,
            "Data Coverage",
            "Summary of data processed during testing",
            [
              "• Total transactions analyzed: 12,378",
              "• Date range: 2025-01-01 to 2025-06-30",
              "• Vendors covered: 1,247 unique vendors",
            ],
            Icons.data_usage,
            Colors.green,
          ),
          const SizedBox(height: 16),
          
          // Test Configuration
          _buildDetailItem(
            context,
            "Test Configuration",
            "Parameters and settings used for testing",
            [
              "• Duplicate threshold: 100% match on vendor, amount, date",
              "• 3-way match tolerance: ±2% variance allowed",
              "• Blocked vendor list: 156 vendors",
            ],
            Icons.settings,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String title,
    String description,
    List<String> points,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.titleText(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyles.subtitleText(context).copyWith(
                        fontSize: 12,
                        color: TextColors.hintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              point,
              style: TextStyles.gridText(context).copyWith(
                fontSize: 12,
              ),
            ),
          )),
        ],
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