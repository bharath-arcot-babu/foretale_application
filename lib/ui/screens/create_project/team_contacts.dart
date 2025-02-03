import 'package:flutter/material.dart';
import 'package:foretale_application/models/team_contacts_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_team_contacts.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class TeamContactsPage extends StatefulWidget {
  const TeamContactsPage({super.key});

  @override
  State<TeamContactsPage> createState() => _TeamContactsState();
}

class _TeamContactsState extends State<TeamContactsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Controllers for Team Contact Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Form(
        key: _formKey, // Assign the form key for validation
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Contact Form
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: _nameController,
                    label: 'Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: _jobTitleController,
                    label: 'Position',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: _departmentController,
                    label: 'Function',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                     validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                CustomElevatedButton(
                  width: 30,
                  height: 30,
                  text: '+',
                  textSize: 12,
                  onPressed: () {
                    _saveTeamContact(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Team Contacts DataGrid (Display added contacts)
            const TeamContactsDataGrid(),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTeamContact(BuildContext context) async {
    var teamContactsModel = Provider.of<TeamContactsModel>(context, listen: false);

    // Validate form before proceeding
    if (_formKey.currentState?.validate() ?? false) {
      try {
        int resultId = await teamContactsModel.addUpdateContact(context, TeamContact(
          name: _nameController.text.trim(),
          position: _jobTitleController.text.trim(),
          function: _departmentController.text.trim(),
          email: _emailController.text.trim(),
          phone: '',
          isClient: 'No'
        ));
        if (resultId > 0) {
          SnackbarMessage.showSuccessMessage(context, '${_nameController.text.trim()} has been added to the project.');
        }
      } catch (e) {
        SnackbarMessage.showErrorMessage(context, e.toString());
      } finally {
        _nameController.clear();
        _jobTitleController.clear();
        _departmentController.clear();
        _emailController.clear();
      }
    } else {
      SnackbarMessage.showErrorMessage(
          context, 'Please fill in all required fields.');
    }
  }
}
