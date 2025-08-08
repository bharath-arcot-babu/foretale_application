import 'package:flutter/material.dart';
import 'package:foretale_application/models/category_list_model.dart';
import 'package:foretale_application/models/modules_list_model.dart';
import 'package:foretale_application/models/create_test_model.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_future.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/core/constants/values.dart';

class TestConfigurationSection extends StatefulWidget {
  const TestConfigurationSection({
    super.key,
  });

  @override
  State<TestConfigurationSection> createState() => _TestConfigurationSectionState();
}

class _TestConfigurationSectionState extends State<TestConfigurationSection> {
  // Sample data for dropdowns
  final List<String> runTypes = runTypesList;
  final List<String> criticalityLevels = criticalityLevelsList;
  final List<String> categories = [];
  final List<String> modules = [];
  final List<String> runPrograms = runProgramsList;

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTestModel>(
      builder: (context, createTestModel, child) {
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
                        selectedItem: createTestModel.getRunType,
                        onChanged: createTestModel.setRunType,
                      ),
                      const SizedBox(height: 20),
                      CustomDropdownSearch(
                        items: runPrograms,
                        title: "Run Program",
                        hintText: 'Choose Run Program',
                        isEnabled: true,
                        selectedItem: createTestModel.getRunProgram,
                        onChanged: createTestModel.setRunProgram,
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
                        selectedItem: createTestModel.getCategory,
                        onChanged: createTestModel.setCategory,
                      ),
                      const SizedBox(height: 20),
                      FutureDropdownSearch(
                        fetchData: () async {
                          ModuleList moduleList = ModuleList();
                          await moduleList.fetchAllActiveModules(context, createTestModel.getTopic);
                          return moduleList.moduleList.map((module) => module.name).toList();
                        },
                        showSearchBox: true,
                        labelText: "Module",
                        hintText: 'Choose Module',
                        isEnabled: true,
                        selectedItem: createTestModel.getModule,
                        onChanged: createTestModel.setModule,
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
              selectedItem: createTestModel.getCriticality,
              onChanged: createTestModel.setCriticality,
            ),
          ],
        );
      },
    );
  }
} 