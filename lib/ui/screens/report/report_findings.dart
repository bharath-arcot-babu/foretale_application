import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

Widget buildDetailedFindings() {
  return Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Finding Item
        _buildFindingItem(
          context,
          "P2P-DQ-002",
          "Duplicate Invoices",
          "Detect multiple invoices with same vendor, amount, and date.",
          "48 duplicates found.",
          "High",
          "Manual validation and review duplicate logic.",
          Colors.red,
        ),
        const SizedBox(height: 16),
        
        // Additional finding items can be added here
        _buildFindingItem(
          context,
          "P2P-DQ-003",
          "3-Way Match",
          "Verify PO, receipt, and invoice match before payment.",
          "5 exceptions found.",
          "Medium",
          "Review matching criteria and update business rules.",
          Colors.orange,
        ),
      ],
    ),
  );
}

Widget _buildFindingItem(
  BuildContext context,
  String testId,
  String testName,
  String description,
  String result,
  String severity,
  String nextSteps,
  Color severityColor,
) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: severityColor.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.bug_report,
                  color: severityColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          testId,
                          style: TextStyles.gridText(context).copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: severityColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: severityColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            severity,
                            style: TextStyle(
                              color: severityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      testName,
                      style: TextStyles.titleText(context).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(context, "Description", description),
              const SizedBox(height: 12),
              _buildDetailRow(context, "Result", result),
              const SizedBox(height: 12),
              _buildDetailRow(context, "Next Steps", nextSteps),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(BuildContext context, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 80,
        child: Text(
          label,
          style: TextStyles.subtitleText(context).copyWith(
            fontSize: 11,
            color: TextColors.hintTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          style: TextStyles.gridText(context).copyWith(
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}
