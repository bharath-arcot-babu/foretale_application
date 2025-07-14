//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/screens/create_project/client_contacts.dart';
import 'package:foretale_application/ui/screens/create_project/project_details.dart';
import 'package:foretale_application/ui/screens/create_project/project_settings.dart';
import 'package:foretale_application/ui/screens/create_project/team_contacts.dart';
import 'package:foretale_application/ui/screens/create_project/project_questions.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class CreateProject extends StatefulWidget {
  final bool isNew;

  const CreateProject({super.key, required this.isNew});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isNew ? 'CREATE PROJECT' : 'PROJECT MANAGEMENT',
              style: TextStyles.subjectText(context),
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 4,
              labelStyle: TextStyles.tabSelectedLabelText(context),
              unselectedLabelStyle: TextStyles.tabUnselectedLabelText(context),
              tabs: [
                buildTab(icon: Icons.info, label: 'Details'),
                buildTab(icon: Icons.settings, label: 'Settings'),
                buildTab(icon: Icons.people_outline, label: 'Client'),
                buildTab(icon: Icons.group, label: 'Team'),
                buildTab(icon: Icons.question_answer, label: 'Questions'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ProjectDetailsScreen(
                    isNew: widget.isNew,
                  ),
                  ProjectSettingsScreen(
                    isNew: widget.isNew,
                  ),
                  const ClientContactsPage(),
                  const TeamContactsPage(),
                  const QuestionsScreen(isNew: true)
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
}
