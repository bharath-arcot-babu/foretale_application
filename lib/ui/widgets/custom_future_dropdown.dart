import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'custom_dropdown_search.dart';

class FutureDropdownSearch extends StatelessWidget {
  final Future<List<String>> Function() fetchData;
  final String labelText;
  final String hintText;
  final bool isEnabled;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  bool showSearchBox = false;

  FutureDropdownSearch(
      {super.key,
      required this.fetchData,
      required this.labelText,
      required this.hintText,
      required this.isEnabled,
      this.selectedItem,
      required this.onChanged,
      this.showSearchBox = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearLoadingIndicator(
            isLoading: true,
            width: 200,
            height: 6,
            color: AppColors.primaryColor,
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Center(
              child: Text("\"$labelText\"",
                  style: TextStyles.inputHintTextStyle(context)));
        } else {
          return CustomDropdownSearch(
            isEnabled: isEnabled,
            items: snapshot.data!,
            hintText: hintText,
            title: labelText,
            selectedItem: selectedItem,
            showSearchBox: showSearchBox,
            onChanged: onChanged,
          );
        }
      },
    );
  }
}
