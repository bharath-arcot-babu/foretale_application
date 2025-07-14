import 'package:flutter/material.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:provider/provider.dart';

Widget buildReportHeader(BuildContext context) {
  var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Project Title
      Builder(
        builder: (context) => Text(
          "Project - ${projectDetailsModel.getName}",
          style: TextStyles.titleText(context).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      const SizedBox(height: 16),
      // Project Details Grid
      Row(
        children: [
          Expanded(
            child: _buildDetailItem(
              context,
              "Industry",
              projectDetailsModel.getIndustry,
              Icons.business,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDetailItem(
              context,
              "System",
              projectDetailsModel.getSystemName,
              Icons.computer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDetailItem(
              context,
              "Project Start Date",
              projectDetailsModel.getProjectStartDate,
              Icons.calendar_today,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildDetailItem(
              context,
              "Process",
              projectDetailsModel.getProjectType,
              Icons.work,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDetailItem(
              context,
              "Project Scope",
              "${projectDetailsModel.getProjectScopeStartDate} - ${projectDetailsModel.getProjectScopeEndDate}",
              Icons.calendar_today,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDetailItem(
              context,
              "Days into project",
              "${projectDetailsModel.getDaysIntoProject} days",
              Icons.calendar_month,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: BorderColors.tertiaryColor.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) => Text(
                  label,
                  style: TextStyles.subtitleText(context).copyWith(
                    fontSize: 10,
                    color: TextColors.hintTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Builder(
                builder: (context) => Text(
                  value,
                  style: TextStyles.enclosureText(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
