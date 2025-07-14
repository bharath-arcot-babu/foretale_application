import 'package:flutter/material.dart';
import 'package:foretale_application/models/report_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

Widget buildStatisticsCard(BuildContext context, ExecutionStatsModel executionStatsModel) {
  return Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTestFlowDiagram(context, executionStatsModel),
      ],
    ),
  );
}

Widget _buildTestFlowDiagram(BuildContext context, ExecutionStatsModel executionStatsModel) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: BorderColors.tertiaryColor.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Level 1: Total Tests
        _buildFlowNode(
          context,
          "Total Tests",
          executionStatsModel.executionStats.totalTests.toString(),
          "All selected tests in the project",
          Icons.assessment,
          AppColors.primaryColor,
        ),
        
        // Arrow down
        _buildFlowArrow(context, AppColors.primaryColor),
        
        // Level 2: Executed vs Pending
        Row(
          children: [
            Flexible(
              child: _buildFlowNode(
                context,
                "Executed Tests",
                executionStatsModel.executionStats.executedTests.toString(),
                "Tests that have been configured and executed",
                Icons.play_circle,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: _buildFlowNode(
                context,
                "Pending Execution",
                executionStatsModel.executionStats.pendingTests.toString(),
                "Tests waiting to be configured and executed",
                Icons.schedule,
                Colors.orange,
              ),
            ),
          ],
        ),
        
        // Arrow down to executed
        _buildFlowArrow(context, Colors.blue),
        
        // Level 3: Review Status
        Row(
          children: [
            Flexible(
              child: _buildFlowNode(
                context,
                "Review Completed",
                executionStatsModel.executionStats.reviewCompleted.toString(),
                "Tests that have been reviewed",
                Icons.visibility,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: _buildFlowNode(
                context,
                "Review Pending",
                executionStatsModel.executionStats.reviewPending.toString(),
                "Tests waiting for review",
                Icons.pending,
                Colors.amber,
              ),
            ),
          ],
        ),
        
        // Arrow down to review completed
        _buildFlowArrow(context, Colors.purple),
        
        // Level 4: Observations (same width as Review Completed)
        Row(
          children: [
            Flexible(
              child: _buildFlowNode(
                context,
                "With Observations",
                executionStatsModel.executionStats.withObservations.toString(),
                "One or more issues (flags) were found",
                Icons.insights,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: _buildFlowNode(
                context,
                "Without Observations",
                executionStatsModel.executionStats.withoutObservations.toString(),
                "Passed clean based on the test criteria — no issues found",
                Icons.visibility_off,
                Colors.grey.shade600,
              ),
            ),
          ],
        ),
        
        // Arrow down to observations
        _buildFlowArrow(context, Colors.red),
        
        // Level 5: Findings Classification
        Row(
          children: [
            Flexible(
              child: _buildFlowNode(
                context,
                "Accepted Findings",
                executionStatsModel.executionStats.acceptedFindings.toString(),
                "Valid issues that require resolution; accepted by business/data stewards",
                Icons.warning,
                Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: _buildFlowNode(
                context,
                "Other Findings",
                executionStatsModel.executionStats.otherFindings.toString(),
                "1: Known exceptions — explainable and not requiring action (e.g., due to policy or system behavior).\n2:  Low-priority or noise — tracked but not acted upon",
                Icons.info,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFlowNode(
  BuildContext context,
  String title,
  String value,
  String description,
  IconData icon,
  Color color,
) {
  bool isHighlighted = color == Colors.red || color == Colors.orange || color == Colors.purple || color == Colors.red.shade700;
  
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isHighlighted ? color.withOpacity(0.08) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isHighlighted ? color.withOpacity(0.4) : Colors.grey.shade300,
        width: isHighlighted ? 2 : 1,
      ),
      boxShadow: isHighlighted ? [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ] : [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      children: [
        // Icon and Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isHighlighted ? color.withOpacity(0.15) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: isHighlighted ? color : Colors.grey.shade600,
                size: 16,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: TextStyles.subtitleText(context).copyWith(
                  fontSize: 11,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                  color: isHighlighted ? color : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        
        // Value
        Text(
          value,
          style: TextStyles.titleText(context).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isHighlighted ? color : Colors.grey.shade800,
          ),
        ),
        
        // Description
        Text(
          description,
          style: TextStyles.subtitleText(context).copyWith(
            fontSize: 9,
            color: isHighlighted ? color.withOpacity(0.7) : TextColors.hintTextColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget _buildFlowArrow(BuildContext context, Color color) {
  return Container(
    height: 20,
    width: 2,
    margin: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.4),
      borderRadius: BorderRadius.circular(1),
    ),
    child: Column(
      children: [
        Expanded(child: Container()),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    ),
  );
}
