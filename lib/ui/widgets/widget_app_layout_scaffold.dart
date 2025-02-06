//libraries
import 'package:flutter/material.dart';
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:provider/provider.dart';
//constants
import 'package:foretale_application/core/constants/colors/app_colors.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
//themes
import 'package:foretale_application/ui/themes/text_styles.dart';

//global scaffold
class CustomGeneralScaffold extends StatefulWidget {
  final Widget body;

  const CustomGeneralScaffold({super.key, required this.body});

  @override
  State<CustomGeneralScaffold> createState() => _CustomGeneralScaffoldState();
}

class _CustomGeneralScaffoldState extends State<CustomGeneralScaffold> {
  //update the user model to update the logged in details
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.05,
        backgroundColor: AppBarColors.appBarBackgroundColor,
        iconTheme: const IconThemeData(
          color: AppColors.backgroundColor,
        ),
        title: Row(
          children: [
            Text("foreTale", style: TextStyles.appBarLogo(context)),
            const Spacer(),
          ],
        ),
        actions: [
          Selector<ProjectDetailsModel, String>(
            selector: (context, projectName) => projectName.getName,
            builder: (context, name, child) {
              return TextButton(
                onPressed: () {
                  showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const CreateProject(isNew: false,),
                            actionsAlignment: MainAxisAlignment.end,
                            actions: [
                               TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Close", style:  TextStyles.footerLinkTextSmall(context),),
                              ),
                              
                            ],
                          ),
                        );
                },
                child: Text(name.isNotEmpty?'Project: $name':'', style: TextStyles.appBarTitleStyle(context)),
              );
            },
          ),
          const SizedBox(
            width: 20,
          ),
          iconBuilder(const Icon(Icons.person)),
        ],
      ),
      body: widget.body,
    );
  }

  Widget iconBuilder(Icon icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IconButton(
        icon: icon,
        color: AppBarColors.appBarIconColor,
        highlightColor: AppBarColors.appBarHighlightIconColor,
        onPressed: () {
          // Action for the icon
        },
      ),
    );
  }
}
