//core
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/ui/widgets/test_config_popup.dart';
//models
import 'package:foretale_application/models/tests_model.dart';
//themes
import 'package:foretale_application/ui/themes/text_styles.dart';
//widgets
import 'package:foretale_application/ui/widgets/message_helper.dart';

class TestsListView extends StatefulWidget {
  const TestsListView({super.key});

  @override
  _TestsListViewState createState() => _TestsListViewState();
}

class _TestsListViewState extends State<TestsListView> {
  late final TestsModel testsModel;
  String selectedCategory = "All"; // Default filter selection

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Fixed Sidebar for Categories
        Container(
          width: 200,
          color: Colors.grey[200],
          child: _buildCategoryList(),
        ),

        // Main ListView for Tests
        Expanded(
          child: Consumer<TestsModel>(
            builder: (context, model, child) {
              final testsList = selectedCategory == "All"
                  ? model.getTestsList
                  : model.getTestsList
                      .where((test) => test.testCategory == selectedCategory)
                      .toList();

              return ListView.builder(
                itemCount: testsList.length,
                itemBuilder: (context, index) {
                  final test = testsList[index];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(
                          test.isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          try {
                            int resultId = test.isSelected
                                ? await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                    title: const Text('Warning'),
                                    content: const Text('Are you sure you want to remove this test? This action will reset the test configurations.'),
                                    actions: [
                                      TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Remove'),
                                      ),
                                    ],
                                    );
                                  },
                                  ).then((confirmed) => confirmed == true 
                                    ? testsModel.removeTest(context, test)
                                    : Future.value(-1))
                                : await testsModel.selectTest(context, test);

                            if (resultId > 0) {
                              setState(() {});
                            }
                          } catch (e) {
                            SnackbarMessage.showErrorMessage(
                                context, e.toString());
                          }
                        },
                      ),
                      title: Text(test.testName,
                          style: TextStyles.gridHeaderText(context)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Category: ${test.testCategory}"),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.only(top: 5),
                            child:Text(
                                test.testDescription,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.gridText(context),
                              ),
                          ), // Expandable description
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.settings,
                            color: Colors.blue, size: 20), // Smaller icon
                        onPressed: () => showConfigPopup(context, test, testsModel),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Fixed Category Sidebar
  Widget _buildCategoryList() {
    return Consumer<TestsModel>(
      builder: (context, model, child) {
        final categories = [
          "All",
          ...model.getTestsList.map((e) => e.testCategory).toSet()
        ];

        return ListView(
          padding: const EdgeInsets.all(8),
          children: categories.map((category) {
            bool isSelected = selectedCategory == category;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: TextStyles.gridText(context).copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue[900] : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
