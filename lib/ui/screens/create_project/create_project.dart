import 'package:flutter/material.dart';
import 'package:foretale_application/ui/screens/create_project/client_contacts.dart';
import 'package:foretale_application/ui/screens/create_project/project_details.dart';
import 'package:foretale_application/ui/screens/create_project/project_settings.dart';
import 'package:foretale_application/ui/screens/create_project/team_contacts.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';


class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            Text('CREATE PROJECT', style: TextStyles.appBarTitleStyle(context),),
            const SizedBox(height: 20),
            // TabBar with custom tabs
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              indicatorWeight: 4,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              tabs: [
                buildTab(icon: Icons.info, label: 'Details'),
                buildTab(icon: Icons.settings, label: 'Settings'),
                buildTab(icon: Icons.people_outline, label: 'Client'),
                buildTab(icon: Icons.group, label: 'Team'),
              ],
            ),
            const SizedBox(height: 20),
            // Elevated container for each tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ProjectDetails(),
                  ProjectSettings(),
                  ClientContactsPage(),
                  TeamContactsPage(),
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
      Color color = Colors.blueAccent}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w100,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

}
