import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

void showConfigPopup(
    BuildContext context, dynamic test, TestsModel testsModel) {
  if (test.config == null || test.config.isEmpty) {
    SnackbarMessage.showErrorMessage(context, "Invalid test configuration");
    return;
  }

  Map<String, dynamic> config;
  try {
    config = jsonDecode(test.config);
  } catch (e) {
    SnackbarMessage.showErrorMessage(context, "Invalid JSON format");
    return;
  }

  if (config["input_parameters"] == null ||
      config["input_parameters"] is! Map) {
    SnackbarMessage.showErrorMessage(context, "Missing input parameters");
    return;
  }

  Map<String, dynamic> inputParameters = config["input_parameters"];
  Map<String, TextEditingController> controllers = {};

  inputParameters.forEach((key, param) {
    if (param is Map && param.containsKey("value")) {
      controllers[key] = TextEditingController(text: param["value"].toString());
    }
  });

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Configuration for '${test.testName}'"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: inputParameters.entries.map((entry) {
              String key = entry.key;
              Map<String, dynamic> param = entry.value;

              if (!param.containsKey("text") ||
                  !param.containsKey("type") ||
                  !param.containsKey("value")) {
                return const SizedBox.shrink();
              }

              String label = param["text"];
              String type = param["type"];
              String description =
                  param["description"] ?? "No description available";
              TextEditingController controller =
                  controllers[key] ?? TextEditingController();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: type == "bool"
                          ? DropdownButtonFormField<bool>(
                              value: param["value"] == true,
                              items: const [
                                DropdownMenuItem(
                                    value: true, child: Text("True")),
                                DropdownMenuItem(
                                    value: false, child: Text("False")),
                              ],
                              onChanged: (newValue) {
                                controllers[key]!.text = newValue.toString();
                              },
                              decoration: InputDecoration(
                                labelText: label,
                                border: const OutlineInputBorder(),
                              ),
                            )
                          : TextField(
                              controller: controller,
                              keyboardType: _getKeyboardType(type),
                              inputFormatters: _getInputFormatters(type),
                              decoration: InputDecoration(
                                labelText: label,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: description,
                      child: const Icon(Icons.info_outline, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> updatedConfig = {
                "input_parameters": {
                  for (var entry in inputParameters.entries)
                    entry.key: {
                      "text": entry.value["text"],
                      "type": entry.value["type"],
                      "value": _parseValue(controllers[entry.key]?.text ?? "",
                          entry.value["type"]),
                      "description": entry.value["description"] ?? "",
                    }
                }
              };

              //update the new config for the test
              test.config = jsonEncode(updatedConfig);
              await testsModel.updateProjectTestConfig(context, test);

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

// Restrict user input based on type
List<TextInputFormatter> _getInputFormatters(String type) {
  switch (type) {
    case "int":
      return [FilteringTextInputFormatter.digitsOnly];
    case "double":
      return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*\$'))];
    default:
      return [];
  }
}

// Helper function to determine input type
TextInputType _getKeyboardType(String type) {
  switch (type) {
    case "int":
      return TextInputType.number;
    case "double":
      return const TextInputType.numberWithOptions(decimal: true);
    case "bool":
      return TextInputType.text;
    default:
      return TextInputType.text;
  }
}

// Helper function to parse value based on type
dynamic _parseValue(String input, String type) {
  switch (type) {
    case "int":
      return int.tryParse(input) ?? 0;
    case "double":
      return double.tryParse(input) ?? 0.0;
    case "bool":
      return input.toLowerCase() == "true";
    default:
      return input;
  }
}
