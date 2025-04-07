//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_icon.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';

class UploadScreenWizard extends StatefulWidget {
  @override
  State<UploadScreenWizard> createState() => _UploadScreenWizardState();
}

class _UploadScreenWizardState extends State<UploadScreenWizard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TableInfo> tableInfos = [
    TableInfo(
      name: "Table A",
      rowCount: 100,
      dateRange: "01 Jan 2023 - 31 Jan 2023",
      uploadedFiles: ["File1.csv", "File2.csv"],
    ),
    TableInfo(
      name: "Table B",
      rowCount: 50,
      dateRange: "01 Feb 2023 - 28 Feb 2023",
      uploadedFiles: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      title: "Data upload wizard",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 4,
            labelStyle: TextStyles.tabSelectedLabelText(context),
            unselectedLabelStyle: TextStyles.tabUnselectedLabelText(context),
            tabs: [
              buildTab(icon: Icons.grid_4x4_rounded, label: 'Choose a table'),
              buildTab(icon: Icons.upload, label: 'Upload files'),
              buildTab(icon: Icons.join_full, label: 'Column mapping'),
              buildTab(icon: Icons.confirmation_num, label: 'Confirm upload'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildTabChooseTable(),
                const Center(
                  child: Text(
                    "Mapping Tab",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const Center(
                  child: Text(
                    "Confirm Upload Tab",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildTab(
      {required IconData icon,
      required String label,
      Color color = AppColors.primaryColor}) {
    return Tab(
      child: FittedBox(
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyles.subjectText(context),
          ),
        ],
      )),
    );
  }

  Widget buildTabChooseTable() {
    // Sort tables alphabetically
    final sortedTables = List<TableInfo>.from(tableInfos)..sort((a, b) => a.name.compareTo(b.name));

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: sortedTables.length,
          itemBuilder: (context, index) {
            final table = sortedTables[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
                    expandedAlignment: Alignment.topLeft,
                    title: Text(
                      table.name,
                      style:  TextStyles.titleText(context),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          CustomChip(label:"${table.rowCount}", leadingIcon: Icons.grid_3x3,),
                          const SizedBox(width: 8),
                          CustomChip(label:table.dateRange, leadingIcon: Icons.calendar_month,),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconButton(icon: Icons.cloud_upload_rounded, onPressed: () {}, tooltip: "Upload data for ${table.name}"),
                        const SizedBox(width: 8),
                        const CustomIcon(icon: Icons.keyboard_arrow_down_rounded, size: 20),
                      ],
                    ),
                    children: [
                      const Divider(height: 1),
                      if (table.uploadedFiles.isNotEmpty)
                        ...table.uploadedFiles.map((file) => ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              leading: const CustomIcon(
                                icon: Icons.insert_drive_file_rounded,
                                size: 20,
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(
                                  file,
                                  style: TextStyles.subtitleText(context),
                                ),
                                Row(children: [
                                Text(
                                  "2.5 MB",
                                style: TextStyles.smallSupplementalInfo(context),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "200 rows",
                                  style: TextStyles.smallSupplementalInfo(context),
                                )
                                ],)
                                ]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CustomIcon(icon: Icons.check_circle_rounded, color: Colors.lightGreen,),
                                  const CustomIcon(icon: Icons.cancel_rounded, color: Colors.redAccent,),
                                  const SizedBox(width: 8),
                                  CustomIconButton(icon: Icons.delete_rounded, onPressed: (){}, tooltip: "Delete file"),
                                  const SizedBox(width: 8),
                                  CustomIconButton(icon: Icons.download_rounded, onPressed: (){}, tooltip: "Download file"),
                                ],
                              ),
                            ))
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "No files uploaded yet",
                              style: TextStyles.subtitleText(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TableInfo {
  final String name;
  final int rowCount;
  final String dateRange;
  final List<String> uploadedFiles;

  TableInfo({
    required this.name,
    required this.rowCount,
    required this.dateRange,
    required this.uploadedFiles,
  });
}
