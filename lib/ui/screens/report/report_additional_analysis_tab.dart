import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/themes/scaffold_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class ReportAdditionalAnalysisTab extends StatelessWidget {
  const ReportAdditionalAnalysisTab({super.key});

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
            // Additional Analysis Section
            _buildSectionCard(
              child: _buildAdditionalFindings(),
              title: "Additional Analysis",
              icon: Icons.analytics,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalFindings() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trend Analysis
          _buildAnalysisItem(
            context,
            "Trend Analysis",
            "Analysis of exception patterns over time",
            [
              "• Duplicate invoices increased by 15% in Q2",
              "• 3-way match failures peaked in June",
              "• Blocked vendor attempts decreased by 8%",
            ],
            Icons.trending_up,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          
          // Root Cause Analysis
          _buildAnalysisItem(
            context,
            "Root Cause Analysis",
            "Identified underlying causes of exceptions",
            [
              "• Vendor master data inconsistencies",
              "• Incomplete PO documentation",
              "• Manual override procedures",
            ],
            Icons.search,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          
          // Impact Assessment
          _buildAnalysisItem(
            context,
            "Impact Assessment",
            "Financial and operational impact of findings",
            [
              "• Potential duplicate payments: \$45,000",
              "• Processing delays: 3-5 business days",
              "• Compliance risks: Medium",
            ],
            Icons.assessment,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(
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