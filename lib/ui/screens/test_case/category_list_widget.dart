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
            // Modern header
            _buildHeader(context),
            // Category list
            Expanded(
              child: _buildCategoryList(categories, selectedCategory, onCategorySelected, model),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.category_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              "Categories",
              style: TextStyles.topicText(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCategoryList(
    List<String> categories,
    String selectedCategory,
    Function(String) onCategorySelected,
    TestsModel model,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SelectableAnimatedList<String>(
          items: categories,
          selectedItem: selectedCategory,
          getLabel: (cat) => cat,
          getCount: (cat) => cat == 'All' 
              ? model.getTestsList.length 
              : model.getTestsList.where((t) => t.testCategory == cat).length,
          onItemSelected: onCategorySelected,
          selectedColor: AppColors.primaryColor,
        ),
      ),
    );
  }
} 