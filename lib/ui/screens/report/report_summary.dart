import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

Widget buildTestSummaryTable() {
  final rows = [
    {
      "id": "P2P-DQ-001",
      "name": "Blocked Vendors",
      "result": "Passed",
      "exceptions": "0",
      "status": "Completed"
    },
    {
      "id": "P2P-DQ-002",
      "name": "Duplicate Invoices",
      "result": "Failed",
      "exceptions": "48",
      "status": "Investigating"
    },
    {
      "id": "P2P-DQ-003",
      "name": "3-Way Match",
      "result": "Partial",
      "exceptions": "5",
      "status": "Needs Review"
    },
  ];

  return Builder(
    builder: (context) => Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  "Test ID",
                  style: TextStyles.gridHeaderText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "Test Name",
                  style: TextStyles.gridHeaderText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  "Result",
                  style: TextStyles.gridHeaderText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  "Exceptions",
                  style: TextStyles.gridHeaderText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  "Status",
                  style: TextStyles.gridHeaderText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // Table Rows
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isLast = index == rows.length - 1;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: index.isEven ? AppColors.backgroundColor : AppColors.surfaceColor,
              border: Border(
                bottom: isLast ? BorderSide.none : BorderSide(
                  color: BorderColors.tertiaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    row['id']!,
                    style: TextStyles.gridText(context).copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    row['name']!,
                    style: TextStyles.gridText(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: _buildResultChip(row['result']!),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    row['exceptions']!,
                    style: TextStyles.gridText(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: _buildStatusChip(row['status']!),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  );
}

Widget _buildResultChip(String result) {
  Color backgroundColor;
  Color textColor;
  
  switch (result.toLowerCase()) {
    case 'passed':
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade700;
      break;
    case 'failed':
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.shade700;
      break;
    case 'partial':
      backgroundColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange.shade700;
      break;
    default:
      backgroundColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey.shade700;
  }
  
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: textColor.withOpacity(0.3)),
    ),
    child: Text(
      result,
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget _buildStatusChip(String status) {
  Color backgroundColor;
  Color textColor;
  
  switch (status.toLowerCase()) {
    case 'completed':
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade700;
      break;
    case 'investigating':
      backgroundColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue.shade700;
      break;
    case 'needs review':
      backgroundColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange.shade700;
      break;
    default:
      backgroundColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey.shade700;
  }
  
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: textColor.withOpacity(0.3)),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
