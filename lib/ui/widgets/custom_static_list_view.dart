import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class StaticListCard extends StatelessWidget {
  final Map<String, String?> mappings;
  final IconData icon;

  const StaticListCard({
    super.key,
    required this.mappings,
    this.icon = Icons.swap_horiz,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: mappings.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 56,
          endIndent: 16,
          color: theme.dividerColor.withOpacity(0.2),
        ),
        itemBuilder: (context, index) {
          final source = mappings.keys.elementAt(index);
          final destination = mappings[source] ?? 'Not Mapped';

          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: Icon(
                icon,
                size: 16,
                color: AppColors.primaryColor,
              ),
            ),
            title: Text(
              source,
              style: TextStyles.topicText(context),
            ),
            subtitle: Text(
              destination,
              style: TextStyles.smallSupplementalInfo(context).copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            dense: true,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
