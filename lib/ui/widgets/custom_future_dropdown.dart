import 'package:flutter/material.dart';
import 'custom_dropdown_search.dart';

class FutureDropdownSearch extends StatelessWidget {
  final Future<List<String>> Function() fetchData;
  final String labelText;
  final String hintText;
  final bool isEnabled;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  bool showSearchBox = false;

  FutureDropdownSearch({
    super.key,
    required this.fetchData,
    required this.labelText,
    required this.hintText,
    required this.isEnabled,
    this.selectedItem,
    required this.onChanged,
    this.showSearchBox = false
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Try again.'));
        } else {
          return CustomDropdownSearch(
            isEnabled: isEnabled,
            items: snapshot.data!,
            hintText: hintText,
            labelText: labelText,
            selectedItem: selectedItem,
            showSearchBox: showSearchBox,
            onChanged: onChanged,
          );
        }
      },
    );
  }
}
