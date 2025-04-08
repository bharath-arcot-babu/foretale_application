import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String cancelText = 'Cancel',
  String confirmText = 'Delete',
  Color confirmTextColor = AppColors.primaryColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: TextStyles.subjectText(context),
      ),
      content: Text(
        content,
        style: TextStyles.topicText(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyles.elevatedButtonTextStyle(context).copyWith(
              color: AppColors.secondaryColor,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: TextStyles.elevatedButtonTextStyle(context).copyWith(
              color: confirmTextColor,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
