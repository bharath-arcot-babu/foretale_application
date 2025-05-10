import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_icon.dart';

class CustomGridMenu extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String> onItemSelected;
  final bool isEnabled;
  final String labelText;

  const CustomGridMenu({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.isEnabled,
    required this.labelText,
  });

  IconData _getIconForType(String type) {
    // Map project types to appropriate icons
    switch (type.toLowerCase()) {
      case 'procure-to-pay (p2p)':
        return Icons.science;
      case 'hire-to-retire (h2r)':
        return Icons.code;
      case 'submit-to-reimburse (s2r)':
        return Icons.analytics;
      case 'draft-to-execute (d2e)':
        return Icons.bug_report;
      case 'stock-to-manage (s2m)':
        return Icons.design_services;
      case 'documentation':
        return Icons.description;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: constraints.maxWidth / 2.5,
                childAspectRatio: 4.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedItem;
                return InkWell(
                  onTap: isEnabled ? () => onItemSelected(item) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : BorderColors.secondaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIcon(
                            icon: _getIconForType(item),
                            size: 18,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black54,
                          ),
                          const SizedBox(width: 1),
                          Expanded(
                            child: Text(
                              item,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyles.subtitleText(context).copyWith(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
