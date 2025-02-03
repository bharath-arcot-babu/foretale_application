//core
import 'package:flutter/material.dart';
//model
import 'package:foretale_application/models/projects_list_model.dart';
//screen
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Future<List<Projects>> _fetchProjects() async {
    // Here you invoke the fetchProjectsByUserMachineId method
    return await ProjectsList().fetchProjectsByUserMachineId(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: FutureBuilder<List<Projects>>(
              future: _fetchProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No projects found.'));
                } else {
                  List<Projects> projects = snapshot.data!;
                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      Projects project = projects[index];
                      return Card(
                        elevation: 4.0, // Adds subtle shadow for depth
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0), // Margin for separation
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigate to project details page or show more info
                            print('Tapped on project ${project.projectName}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                                16.0), // Inner padding for better content spacing
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Project Name
                                Text(
                                  project.projectName,
                                  style: TextStyles.titleText(context),
                                ),
                                const SizedBox(
                                    height:
                                        8.0), // Space between name and subtitle

                                // Organization Name
                                Text(
                                  project.organizationName,
                                  style: TextStyles.subtitleText(context),
                                ),
                                const SizedBox(
                                    height:
                                        8.0), // Space between organization and project type

                                // Project Type and Start Date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      project.projectType,
                                      style: TextStyles.topicText(context),
                                    ),
                                    Text(
                                      "Started on: ${project.projectStartDate}",
                                      style: TextStyles.topicText(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.08), // Space between left and right column
          // Right Column: Create New Project and Resources
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Create New Project Section
                Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: CustomElevatedButton(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: 60,
                      text: "Start a new project",
                      textSize: 16,
                      onPressed: () {
                        // Handle Create New Project action
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const CreateProject(),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                // Resources Section
                Text(
                  "Learn More About This Tool:",
                  style: TextStyles.titleText(context)
                      .copyWith(letterSpacing: 4.0),
                ),
                const SizedBox(height: 10),
                const ResourceCard(
                  title: "Flutter Documentation",
                  url: "https://flutter.dev/docs",
                ),
                const ResourceCard(
                  title: "Flutter YouTube Channel",
                  url: "https://www.youtube.com/c/FlutterDev",
                ),
                const ResourceCard(
                  title: "Flutter Community",
                  url: "https://flutter.dev/community",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Project {
  final String name;
  final DateTime startDate;
  final String status;

  Project({required this.name, required this.startDate, required this.status});
}

class ResourceCard extends StatelessWidget {
  final String title;
  final String url;

  const ResourceCard({required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.link, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                // Launch the URL
                print("Opening $url");
                // You can use url_launcher package to open the URL here
              },
              child: const Text("Open", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
