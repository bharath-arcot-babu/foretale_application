import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/screens/datagrids/data_assessment/sfdg_dq_blank_fields.dart';
import 'package:foretale_application/ui/screens/datagrids/data_assessment/sfdg_dq_date_fields.dart';
import 'package:foretale_application/ui/screens/datagrids/data_assessment/sfdg_dq_numeric_fields.dart';
import 'package:foretale_application/ui/screens/datagrids/data_assessment/sfdg_dq_text_fields.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/data_assessment_model.dart';


class DataQualityAssessmentPage extends StatefulWidget {
  const DataQualityAssessmentPage({super.key});

  @override
  State<DataQualityAssessmentPage> createState() => _DataQualityAssessmentPageState();
}

class _DataQualityAssessmentPageState extends State<DataQualityAssessmentPage> with TickerProviderStateMixin {
  late DataQualityProfileModel dataQualityProfileModel;
  TabController? _tabController;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    dataQualityProfileModel = Provider.of<DataQualityProfileModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPage());
  }

  Future<void> _loadPage() async {
    await dataQualityProfileModel.fetchDataQualityRepByTable(context);
    setState(() {
      final profiles = dataQualityProfileModel.getDataQualityProfileList;
      categories = profiles.map((p) => p.columnCategory).toSet().toList();
      _tabController = TabController(length: categories.length, vsync: this);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataQualityProfileModel>(
        builder: (context, model, _) {
          final profiles = model.getDataQualityProfileList;
          if (profiles.isEmpty || _tabController == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final grouped = <String, List<DataQualityProfile>>{};
          for (var p in profiles) {
            grouped.putIfAbsent(p.columnCategory, () => []).add(p);
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child:Row(
            children: [
              Container(
                width: 180,
                color: Colors.grey.shade100,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _tabController!.index == index;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: Colors.white,
                      tileColor: Colors.transparent,
                      hoverColor: Colors.grey.shade300,
                      title: Text(
                        categories[index],
                        style: TextStyles.titleText(context).copyWith(
                          color: isSelected ? AppColors.primaryColor : Colors.black,
                        ),
                      ),
                      onTap: () {
                        _tabController!.animateTo(index);
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: categories.map((category) {
                    final list = grouped[category]!;
                    switch (category.toLowerCase()) {
                      case 'text fields':
                        return TextFieldsDataGrid(profiles: list);
                      case 'numeric fields':
                        return NumericFieldsDataGrid(profiles: list);
                      case 'blank fields':
                        return NullFieldsDataGrid(profiles: list);
                      case 'date fields':
                        return DateFieldsDataGrid(profiles: list);
                      default:
                        return Center(child: Text('No Data Grid defined for "$category"'));
                    }
                  }).toList(),
                ),
              )
            ],
          ));
        },
      );
  }
}
