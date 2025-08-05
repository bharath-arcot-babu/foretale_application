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
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Container(
        constraints: const BoxConstraints(
          minWidth: 300,
          maxWidth: 400,
          minHeight: 150,
          maxHeight: 250,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.subjectText(context),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyles.topicText(context),
              textAlign: TextAlign.left,
              softWrap: true,
              maxLines: 10,
              textWidthBasis: TextWidthBasis.parent
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            cancelText,
            style: TextStyles.elevatedButtonTextStyle(context).copyWith(
              color: AppColors.secondaryColor,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
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
  
  final finalResult = result ?? false;
  return finalResult;
}
