import 'package:flutter/material.dart';
import 'package:foretale_application/models/project_settings_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_topic_header.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class ProjectSettingsScreen extends StatefulWidget {
  final bool isNew;
  const ProjectSettingsScreen({
    super.key, 
    required this.isNew
    });

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> {
  // Controllers for each text field
  final TextEditingController sqlHostController = TextEditingController();
  final TextEditingController sqlPortController = TextEditingController();
  final TextEditingController sqlDatabaseController = TextEditingController();
  final TextEditingController sqlUsernameController = TextEditingController();
  final TextEditingController sqlPasswordController = TextEditingController();
  final TextEditingController s3UrlController = TextEditingController();
  final TextEditingController s3UsernameController = TextEditingController();
  final TextEditingController s3PasswordController = TextEditingController();

  // GlobalKey for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isNew) {
        _loadPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Form(
        key: _formKey, // Attach the form key here
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                  width: 50,
                  height: 50,
                  text: 'Save',
                  textSize: 15,
                  onPressed: (){_saveProjectSettings(context);}, // Call _submitForm on button press
                ),
              ],
            ),
            const SizedBox(height: 15,),
            // SQL Server Settings
            Text(
              'Database Configuration',
              style: TextStyles.subtitleText(context),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: sqlHostController,
              label: 'SQL Server Host',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Server name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: sqlPortController,
              label: 'Port',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Port is required';
                }
                // Check if the value is a valid integer
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number for Port';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: sqlDatabaseController,
              label: 'Database',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Database name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: sqlUsernameController,
              label: 'Username (Leave blank for Windows Authentication)',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: sqlPasswordController,
              label: 'Password (Leave blank for Windows Authentication)',
              obscureText: true,
            ),
            const SizedBox(height: 8),

            // Amazon S3 Settings
            Text(
              'AWS S3 Configuration',
              style: TextStyles.subtitleText(context),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: s3UrlController,
              label: 'Amazon S3 File Storage URL',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: s3UsernameController,
              label: 'S3 Username',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: s3PasswordController,
              label: 'S3 Password',
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle form submission
  Future<void> _saveProjectSettings(BuildContext context) async {
    ProjectSettingsModel projectSettingsModel = Provider.of<ProjectSettingsModel>(context, listen: false);

    if (_formKey.currentState?.validate() ?? false) {
      try{
          projectSettingsModel.projectSettings = ProjectSettings(
            sqlHost: sqlHostController.text.trim(),
            sqlPort: int.parse(sqlPortController.text.trim()),
            sqlDatabase: sqlDatabaseController.text.trim(),
            sqlUsername: sqlUsernameController.text.trim(),
            sqlPassword: sqlPasswordController.text.trim(),
            s3Url : s3UrlController.text.trim(),
            s3Username: s3UsernameController.text.trim(),
            s3Password: s3PasswordController.text.trim()
          );

          int projectSettingId = await projectSettingsModel.saveProjectSettings(context);
          if(projectSettingId>0){
            SnackbarMessage.showSuccessMessage(context, 'Project details saved successfully.');
          }
      } 
      catch(e){
          SnackbarMessage.showErrorMessage(context, e.toString());
      }
    } else {
      SnackbarMessage.showErrorMessage(context, 'Please fill in all required fields.');
    }
  }

  Future<void> _fetchProjectSettings(BuildContext context) async {
    ProjectSettingsModel projSettings = Provider.of<ProjectSettingsModel>(context, listen: false);
    await projSettings.fetchProjectSettingsByUserMachineId(context);
    
    sqlHostController.text = projSettings.getSqlHost;
    sqlPortController.text = projSettings.getSqlPort.toString();
    sqlDatabaseController.text = projSettings.getSqlDatabase;
    sqlUsernameController.text = projSettings.getSqlUsername;
    sqlPasswordController.text = projSettings.getSqlPassword;
    s3UrlController.text = projSettings.getS3Url;
    s3UsernameController.text = projSettings.getS3Username;
    s3PasswordController.text = projSettings.getS3Password;
  }

  Future<void> _loadPage() async {
    try {
      await _fetchProjectSettings(context);
    } catch (e) {
      SnackbarMessage.showErrorMessage(context,
          'Something went wrong! Please contact support for assistance.');
    }
  }
}

