import 'package:flutter/material.dart';
import 'package:foretale_application/models/columns_model.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_list.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class ColumnMappingScreen extends StatefulWidget {
  const ColumnMappingScreen({Key? key}) : super(key: key);

  @override
  State<ColumnMappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<ColumnMappingScreen> {
  final String _currentFileName = "column_mapping_screen.dart";
  late ColumnsModel columnsModel;

  final Map<String, String?> selectedMappings = {};

  @override
  void initState() {
    super.initState();
    columnsModel = Provider.of<ColumnsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  void handleMappingConfirm() {
    // Do something with selectedMappings
    print('Confirmed Mappings: $selectedMappings');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mappings confirmed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColumnsModel>(builder: (context, consumeColumnModel, _) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            // This makes scrollable area take available space
            Expanded(
              child: SingleChildScrollView(
                child: buildCustomDropdownMappingList(
                  context,
                  labels: consumeColumnModel.destinationFields,
                  options: consumeColumnModel.sourceFields,
                  selectedValues: selectedMappings,
                  onChanged: (label, value) {
                    setState(() {
                      selectedMappings[label] = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: handleMappingConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text(
                  'Confirm Mapping',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }


  Future<void> _loadPage() async {
    try {
      await columnsModel.fetchColumnsByTable(context);
      await columnsModel.fetchColumnsCsvDetails(context);
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
