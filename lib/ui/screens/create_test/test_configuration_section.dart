import 'package:flutter/material.dart';
import 'package:foretale_application/models/category_list_model.dart';
import 'package:foretale_application/models/modules_list_model.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/custom_future_dropdown.dart';

class TestConfigurationSection extends StatefulWidget {
  final String? selectedRunType;
  final String? selectedCriticality;
  final String? selectedCategory;
  final String? selectedModule;
  final String? selectedRunProgram;
  final Function(String?) onRunTypeChanged;
  final Function(String?) onCriticalityChanged;
  final Function(String?) onCategoryChanged;
  final Function(String?) onModuleChanged;
  final Function(String?) onRunProgramChanged;
  final String? topic;

  const TestConfigurationSection({
    super.key,
    required this.selectedRunType,
    required this.selectedCriticality,
    required this.selectedCategory,
    required this.selectedModule,
    required this.selectedRunProgram,
    required this.onRunTypeChanged,
    required this.onCriticalityChanged,
    required this.onCategoryChanged,
    required this.onModuleChanged,
    required this.onRunProgramChanged,
    required this.topic,
  });

  @override
  State<TestConfigurationSection> createState() => _TestConfigurationSectionState();
}

class _TestConfigurationSectionState extends State<TestConfigurationSection> {
  // Sample data for dropdowns
  final List<String> runTypes = ['ML', 'SQL', 'API'];
  final List<String> criticalityLevels = ['Low', 'Medium', 'High'];
  final List<String> categories = [];
  final List<String> modules = [];
  final List<String> runPrograms = ['Semantic-Search', 'LLM', 'SQL', 'API', 'ML-Decision-Tree', 'ML-Random-Forest', 'ML-Gradient-Boosting', 'ML-XGBoost', 'ML-LightGBM', 'ML-CatBoost', 'ML-Neural-Network', 'ML-Support-Vector-Machine', 'ML-K-Nearest-Neighbors', 'ML-Naive-Bayes', 'ML-Decision-Tree', 'ML-Random-Forest', 'ML-Gradient-Boosting', 'ML-XGBoost', 'ML-LightGBM', 'ML-CatBoost', 'ML-Neural-Network', 'ML-Support-Vector-Machine', 'ML-K-Nearest-Neighbors', 'ML-Naive-Bayes'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (Run Type and Run Program)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDropdownSearch(
                    items: runTypes,
                    title: "Run Type",
                    hintText: 'Choose Run Type',
                    isEnabled: true,
                    selectedItem: widget.selectedRunType,
                    onChanged: widget.onRunTypeChanged,
                  ),
                  const SizedBox(height: 20),
                  CustomDropdownSearch(
                    items: runPrograms,
                    title: "Run Program",
                    hintText: 'Choose Run Program',
                    isEnabled: true,
                    selectedItem: widget.selectedRunProgram,
                    onChanged: widget.onRunProgramChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right Column (Category and Module)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureDropdownSearch(
                    fetchData: () async {
                      CategoryList categoryList = CategoryList();
                      await categoryList.fetchAllActiveCategories(context);
                      return categoryList.categoryList.map((category) => category.name).toList();
                    },
                    labelText: "Category",
                    hintText: 'Choose Category',
                    isEnabled: true,
                    selectedItem: widget.selectedCategory,
                    onChanged: widget.onCategoryChanged,
                  ),
                  const SizedBox(height: 20),
                  FutureDropdownSearch(
                    fetchData: () async {
                      ModuleList moduleList = ModuleList();
                      await moduleList.fetchAllActiveModules(context, widget.topic ?? '');
                      return moduleList.moduleList.map((module) => module.name).toList();
                    },
                    showSearchBox: true,
                    labelText: "Module",
                    hintText: 'Choose Module',
                    isEnabled: true,
                    selectedItem: widget.selectedModule,
                    onChanged: widget.onModuleChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FutureDropdownSearch(
          fetchData: () async => criticalityLevels,
          labelText: "Criticality",
          hintText: 'Choose Criticality',
          isEnabled: true,
          selectedItem: widget.selectedCriticality,
          onChanged: widget.onCriticalityChanged,
        ),
      ],
    );
  }
} 