import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';

Widget buildCustomDropdownMappingList(
  BuildContext context, {
  required Map<String, String> labels,
  required List<String> options,
  required Map<String, String?> selectedValues,
  required void Function(String label, String? selected) onChanged,
  bool isEnabled = true,
}) {
  final sortedEntries = labels.entries.toList()
    ..sort((a, b) {
      final aMapped = selectedValues[a.key]?.isNotEmpty ?? false;
      final bMapped = selectedValues[b.key]?.isNotEmpty ?? false;

      if (aMapped && !bMapped) return -1;
      if (!aMapped && bMapped) return 1;

      // Both are mapped or unmapped, sort by key alphabetically
      return a.key.toLowerCase().compareTo(b.key.toLowerCase());
    });

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: sortedEntries.map((entry) {
      final label = entry.key;
      final description = entry.value;
      final isSelected = (selectedValues[label]?.isNotEmpty ?? false);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.green.shade400 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyles.subtitleText(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyles.topicText(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdownSearch(
                items: options,
                title: 'Map to',
                hintText: 'Select field',
                selectedItem: selectedValues[label],
                isEnabled: isEnabled,
                showSearchBox: true,
                onChanged: (value) => onChanged(label, value),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
