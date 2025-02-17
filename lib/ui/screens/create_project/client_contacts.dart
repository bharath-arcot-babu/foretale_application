import 'package:flutter/material.dart';
import 'package:foretale_application/models/client_contacts_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_client_contacts.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class ClientContactsPage extends StatefulWidget {
  const ClientContactsPage({super.key});

  @override
  State<ClientContactsPage> createState() => _ClientContactsState();
}

class _ClientContactsState extends State<ClientContactsPage> {
  final String _currentFileName = "client_contacts.dart";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Controllers for Client Contact Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late ClientContactsModel _clientContacts = Provider.of<ClientContactsModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _clientContacts = Provider.of<ClientContactsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    isEnabled: true,
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
                    isEnabled: true,
                    controller: _jobTitleController,
                    label: 'Position',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    isEnabled: true,
                    controller: _departmentController,
                    label: 'Function',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    isEnabled: true,
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
                Expanded(
                    flex: 1,
                    child: CustomElevatedButton(
                      width: double.infinity,
                      height: 40,
                      text: '+',
                      textSize: 12,
                      onPressed: () {
                        _saveClientContact(context);
                      },
                    )),
              ],
            ),
            const SizedBox(height: 50),
            // Client Contacts DataGrid (Display added contacts)
            const ClientContactsDataGrid(),
          ],
        ),
      ),
    );
  }

  Future<void> _saveClientContact(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        int resultId = await _clientContacts.addUpdateContact(
            context,
            ClientContact(
                name: _nameController.text.trim(),
                position: _jobTitleController.text.trim(),
                function: _departmentController.text.trim(),
                email: _emailController.text.trim(),
                phone: '',
                isClient: 'Yes'));

        if (resultId > 0) {
          SnackbarMessage.showSuccessMessage(context,'"${_nameController.text.trim()}" has been added to the project.');
        }

      } catch (e, error_stack_trace) {
        SnackbarMessage.showErrorMessage(context, 
            e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveClientContact");

      } finally {

        _nameController.clear();
        _jobTitleController.clear();
        _departmentController.clear();
        _emailController.clear();

      }
    }
  }

  Future<void> _fetchClientContacts(BuildContext context) async {
    await _clientContacts.fetchClientsByProjectId(context);
  }

  Future<void> _loadPage() async {
    try {
      await _fetchClientContacts(context);
    } catch (e, error_stack_trace) {
        SnackbarMessage.showErrorMessage(context, 'Something went wrong!',
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_loadPage");
      } 
  }
}
