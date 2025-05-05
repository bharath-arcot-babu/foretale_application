//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
//screen
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_resource_card.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    _loadPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: CustomContainer(
              title: "Choose an existing project",
              child: Consumer<ProjectDetailsModel>(
                  builder: (context, model, child) {
                List<ProjectDetails> projects = model.projectListByUser;
                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    ProjectDetails project = projects[index];
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
                          _onProjectSelection(context, project);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: TextStyles.titleText(context),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                project.organization,
                                style: TextStyles.subtitleText(context),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    project.projectType,
                                    style: TextStyles.topicText(context),
                                  ),
                                  Text(
                                    "Started on: ${project.createdDate.toString()}",
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
              }))),
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
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.backgroundColor,
                            content: const CreateProject(
                              isNew: true,
                            ),
                            actionsAlignment: MainAxisAlignment.end,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Close",
                                  style:
                                      TextStyles.footerLinkTextSmall(context),
                                ),
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

  void _onProjectSelection(BuildContext context, ProjectDetails projectDetails) {
    try {
      Provider.of<ProjectDetailsModel>(context, listen: false).updateProjectDetails(context, projectDetails);
    } catch (e) {
      SnackbarMessage.showErrorMessage(context, "Invalid project selection.");
    }
  }

  Future<void> _loadPage() async {
    return await Provider.of<ProjectDetailsModel>(context, listen: false).fetchProjectsByUserMachineId(context);
  }
}


