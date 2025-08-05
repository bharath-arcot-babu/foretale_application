//libraries
import 'package:flutter/material.dart';
//constants
import 'package:foretale_application/core/constants/colors/app_colors.dart';
//utils
import 'package:foretale_application/core/services/cognito_activities.dart';
import 'package:foretale_application/ui/screens/create_test/create_test.dart';
import 'package:foretale_application/ui/screens/report/report_wrap.dart';
import 'package:foretale_application/ui/screens/review/review.dart';

//screens
import 'package:foretale_application/ui/screens/welcome.dart';
import 'package:foretale_application/ui/screens/inquiry/inquiry.dart';
import 'package:foretale_application/ui/screens/test_case/test_config.dart';
import 'package:foretale_application/ui/screens/data_upload/upload_screen_wizard.dart';
//themes
import 'package:foretale_application/ui/themes/scaffold_styles.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
//widgets
import 'package:foretale_application/ui/widgets/widget_app_layout_scaffold.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  String _selectedScreen = 'Home';
  String _highlightedTile = 'Home';

  final String _display1 = "Home";
  final String _display2 = "Knowledge Base";
  final String _display3 = "Data Upload";
  final String _display4 = "Test Library";
  final String _display5 = "Result & Review";
  final String _display6 = "Risk Report";
  final String _display7 = "Settings";
  final String _display8 = "Help & Support";
  final String _display9 = "Logout";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomGeneralScaffold(
      body: Row(
        children: [
          // Left Panel with the tiles
          Container(
            width: 70,
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.005),
            decoration: ScaffoldStyles.layoutLeftPanelBoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTile(_display1, Icons.dashboard),
                _buildTile(_display2, Icons.lightbulb),
                _buildTile(_display3, Icons.cloud_upload),
                _buildTile(_display4, Icons.map),
                _buildTile(_display5, Icons.analytics),
                _buildTile(_display6, Icons.note),
                const Spacer(), // Push the next tiles to the bottom
                _buildTile(_display7, Icons.settings),
                _buildTile(_display8, Icons.gavel),
                _buildTile(_display9, Icons.logout),
              ],
            ),
          ),
          // Expanded body panel that will load content asynchronously using FutureBuilder
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
              decoration: ScaffoldStyles.layoutBodyPanelBoxDecoration(),
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<void>(
                future: getUserSignInDetails(context),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}')); // Handle error
                  } else {
                    return Row(children: [
                      Expanded(
                        child: _getContent(),
                      )
                    ]);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getContent() {
    if (_selectedScreen == _display1) {
      return const WelcomePage();
    } else if (_selectedScreen == _display2) {
      return const InquiryPage();
    } else if (_selectedScreen == _display3) {
      return const UploadScreenWizard();
    } else if (_selectedScreen == _display4) {
      return const TestConfigPage();
    } else if (_selectedScreen == _display5) {
      return const ReviewPage();
    } else if (_selectedScreen == _display6) {
      return const RiskReportPage();
    }
    return const Placeholder();
  }

  Widget _buildTile(String title, IconData icon) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.005),
        child: Tooltip(
          message: title,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedScreen = title;
                _highlightedTile = title;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.002),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: MediaQuery.of(context).size.width * 0.014, // Adjust size as needed
                      color: _highlightedTile == title
                          ? LeftPaneControlColors.leftPanelHighlightColor
                          : LeftPaneControlColors.leftPanelIconColor,
                    ),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: TextStyles.leftPanelControlsText(context))
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
