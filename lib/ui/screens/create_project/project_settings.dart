import 'package:flutter/material.dart';
import 'package:foretale_application/models/project_settings_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';

class ProjectSettingsScreen extends StatefulWidget {
  final bool isNew;
  const ProjectSettingsScreen({super.key, required this.isNew});

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> {
  final String _currentFileName = "project_settings.dart";
  final _formKey = GlobalKey<FormState>();
  // Controllers for each text field
  final TextEditingController _sqlHostController = TextEditingController();
  final TextEditingController _sqlPortController = TextEditingController();
  final TextEditingController _sqlDatabaseController = TextEditingController();
  final TextEditingController _sqlUsernameController = TextEditingController();
  final TextEditingController _sqlPasswordController = TextEditingController();
  final TextEditingController _s3UrlController = TextEditingController();
  final TextEditingController _s3UsernameController = TextEditingController();
  final TextEditingController _s3PasswordController = TextEditingController();
  late ProjectSettingsModel _projectSettingsModel;

  @override
  void initState() {
    super.initState();
    _projectSettingsModel =
        Provider.of<ProjectSettingsModel>(context, listen: false);

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
                  width: 40,
                  height: 40,
                  text: 'Save',
                  textSize: 14,
                  onPressed: () {
                    _saveProjectSettings(context);
                  }, // Call _submitForm on button press
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            // SQL Server Settings
            Text(
              'Database Configuration',
              style: TextStyles.subtitleText(context),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: _sqlHostController,
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
              controller: _sqlPortController,
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
              controller: _sqlDatabaseController,
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
              controller: _sqlUsernameController,
              label: 'Username (Leave blank for Windows Authentication)',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: _sqlPasswordController,
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
              controller: _s3UrlController,
              label: 'Amazon S3 File Storage URL',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: _s3UsernameController,
              label: 'S3 Username',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              isEnabled: true,
              controller: _s3PasswordController,
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
    if (_formKey.currentState?.validate() ?? false) {
      try {
        _projectSettingsModel.projectSettings = ProjectSettings(
            sqlHost: _sqlHostController.text.trim(),
            sqlPort: int.parse(_sqlPortController.text.trim()),
            sqlDatabase: _sqlDatabaseController.text.trim(),
            sqlUsername: _sqlUsernameController.text.trim(),
            sqlPassword: _sqlPasswordController.text.trim(),
            s3Url: _s3UrlController.text.trim(),
            s3Username: _s3UsernameController.text.trim(),
            s3Password: _s3PasswordController.text.trim());

        int projectSettingId =
            await _projectSettingsModel.saveProjectSettings(context);
        if (projectSettingId > 0) {
          SnackbarMessage.showSuccessMessage(
              context, 'Project settings saved successfully.');
        }
      } catch (e, error_stack_trace) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveProjectSettings");
      }
    }
  }

  Future<void> _fetchProjectSettings(BuildContext context) async {
    await _projectSettingsModel.fetchProjectSettingsByUserMachineId(context);

    _sqlHostController.text = _projectSettingsModel.getSqlHost;
    _sqlPortController.text = _projectSettingsModel.getSqlPort.toString();
    _sqlDatabaseController.text = _projectSettingsModel.getSqlDatabase;
    _sqlUsernameController.text = _projectSettingsModel.getSqlUsername;
    _sqlPasswordController.text = _projectSettingsModel.getSqlPassword;
    _s3UrlController.text = _projectSettingsModel.getS3Url;
    _s3UsernameController.text = _projectSettingsModel.getS3Username;
    _s3PasswordController.text = _projectSettingsModel.getS3Password;
  }

  Future<void> _loadPage() async {
    try {
      await _fetchProjectSettings(context);
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    }
  }
}
