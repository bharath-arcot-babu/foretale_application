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
        toolbarHeight: 48, // Reduced height for minimalistic look
        backgroundColor: AppBarColors.appBarBackgroundColor,
        elevation: 0, // Remove shadow for cleaner look
        iconTheme: const IconThemeData(
          color: AppColors.backgroundColor,
          size: 20, // Smaller icon size
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
            width: 12, // Reduced spacing
          ),
          iconBuilder(const Icon(Icons.person)),
        ],
      ),
      body: widget.body,
    );
  }

  Widget iconBuilder(Icon icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6), // Reduced padding
      child: IconButton(
        icon: icon,
        color: AppBarColors.appBarIconColor,
        highlightColor: AppBarColors.appBarHighlightIconColor,
        padding: EdgeInsets.zero, // Remove internal padding
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ), // Smaller button size
        onPressed: () {
          // Action for the icon
        },
      ),
    );
  }
}
