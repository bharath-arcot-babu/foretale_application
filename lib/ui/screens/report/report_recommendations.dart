import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

Widget buildRecommendations() {
  final recommendations = [
    {
      "title": "Automate duplicate invoice detection",
      "description": "Implement automated workflows to detect and flag duplicate invoices before processing",
      "priority": "High",
      "icon": Icons.auto_fix_high,
      "color": Colors.red,
    },
    {
      "title": "Validate blocked vendors at PO creation",
      "description": "Add validation checks during purchase order creation to prevent blocked vendor transactions",
      "priority": "Medium",
      "icon": Icons.block,
      "color": Colors.orange,
    },
    {
      "title": "Cleanse vendor master data quarterly",
      "description": "Establish quarterly review process to clean and maintain vendor master data quality",
      "priority": "Medium",
      "icon": Icons.cleaning_services,
      "color": Colors.blue,
    },
    {
      "title": "Add dashboards for exception trends",
      "description": "Create real-time dashboards to monitor and track exception trends and patterns",
      "priority": "Low",
      "icon": Icons.dashboard,
      "color": Colors.green,
    },
  ];

  return Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRecommendationItem(
            context,
            rec["title"] as String,
            rec["description"] as String,
            rec["priority"] as String,
            rec["icon"] as IconData,
            rec["color"] as Color,
          ),
        )).toList(),
      ],
    ),
  );
}

Widget _buildRecommendationItem(
  BuildContext context,
  String title,
  String description,
  String priority,
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
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyles.titleText(context).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyles.gridText(context).copyWith(
                  fontSize: 12,
                  color: TextColors.hintTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
