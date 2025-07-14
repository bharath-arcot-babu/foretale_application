import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_selectable_list.dart';
import 'package:provider/provider.dart';

class CategoryListWidget {
  static Widget buildCategoryList(String selectedCategory, Function(String) onCategorySelected) {
    return Consumer<TestsModel>(
      builder: (context, model, child) {
        final categories = ["All", ...model.getTestsList.map((e) => e.testCategory).toSet()];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                "Categories",
                style: TextStyles.topicText(context),
              ),
            ),
            Expanded(
                child: SelectableAnimatedList<String>(
              items: categories,
              selectedItem: selectedCategory,
              getLabel: (cat) => cat,
              getCount: (cat) => cat == 'All' ? model.getTestsList.length : model.getTestsList.where((t) => t.testCategory == cat).length,
              onItemSelected: onCategorySelected,
              selectedColor: AppColors.primaryColor,
            )),
          ],
        );
      },
    );
  }
} 