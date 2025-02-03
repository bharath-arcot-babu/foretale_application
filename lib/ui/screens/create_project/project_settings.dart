import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/project_settings_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_topic_header.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class ProjectSettings extends StatefulWidget {
  const ProjectSettings({super.key});

  @override
  State<ProjectSettings> createState() => _ProjectSettingsState();
}

class _ProjectSettingsState extends State<ProjectSettings> {
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
            const CustomTopicHeader(label: 'Database Settings'),
            const SizedBox(height: 8),
            CustomTextField(
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
              controller: sqlUsernameController,
              label: 'Username (Leave blank for Windows Authentication)',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: sqlPasswordController,
              label: 'Password (Leave blank for Windows Authentication)',
              obscureText: true,
            ),
            const SizedBox(height: 8),

            // Amazon S3 Settings
            const CustomTopicHeader(label: 'Amazon S3 Settings'),
            const SizedBox(height: 8),
            CustomTextField(
              controller: s3UrlController,
              label: 'Amazon S3 File Storage URL',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: s3UsernameController,
              label: 'S3 Username',
            ),
            const SizedBox(height: 8),
            CustomTextField(
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
    var projectSettingsModel = Provider.of<ProjectSettingsModel>(context, listen: false);

    if (_formKey.currentState?.validate() ?? false) {
      try{
          projectSettingsModel.sqlHost = sqlHostController.text.trim();
          projectSettingsModel.sqlPort = int.parse(sqlPortController.text.trim());
          projectSettingsModel.sqlDatabase = sqlDatabaseController.text.trim();
          projectSettingsModel.sqlUsername = sqlUsernameController.text.trim();
          projectSettingsModel.sqlPassword = sqlPasswordController.text.trim();
          projectSettingsModel.s3Url = s3UrlController.text.trim();
          projectSettingsModel.s3Username = s3UsernameController.text.trim();
          projectSettingsModel.s3Password = s3PasswordController.text.trim();
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
}

