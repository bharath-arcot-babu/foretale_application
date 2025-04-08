import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';

Widget buildCustomDropdownMappingList(
  BuildContext context,
  {
  required List<String> labels,
  required List<String> options,
  required Map<String, String?> selectedValues,
  required void Function(String label, String? selected) onChanged,
  bool isEnabled = true,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: labels.map((label) {
      return Container(
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
        ),
        child: Row(
          children: [
            // Label with fixed width
            SizedBox(
              width: 300,
              child: 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.subtitleText(context),
                ),
                const SizedBox(height: 4),
                Text(
                  'Description of $label', // Replace with actual description logic
                  style: TextStyles.topicText(context),
                ),
              ],
            )),

            const SizedBox(width: 12),

            // Dropdown takes remaining width
            Expanded(
              child: CustomDropdownSearch(
                items: options,
                labelText: 'Map to',
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
