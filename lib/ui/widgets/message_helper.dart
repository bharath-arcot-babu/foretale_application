import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:provider/provider.dart';

class SnackbarMessage {
  // Function to extract the message between <ERR_START> and <ERR_END>
  static String extractErrorMessage(String errorMessage) {
    int startIndex = errorMessage.indexOf('<ERR_START>');
    int endIndex = errorMessage.indexOf('<ERR_END>');

    if (startIndex != -1 && endIndex != -1) {
      return errorMessage.substring(startIndex+11, endIndex).trim();
    }
    return 'NOT_FOUND';
  }

  /// Displays a success message in a SnackBar with bottom-middle positioning and animation.
  static void showSuccessMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green, SnackBarBehavior.floating);
  }

  /// Displays an error message in a SnackBar with bottom-middle positioning and animation.
  static void showErrorMessage(
    BuildContext context, 
    String message, 
    {bool logError = false, 
    String errorMessage = "",
    String errorType = "",
    String errorStackTrace = "",
    String errorSource = "", 
    String severityLevel = "", 
    String requestPath = ""}) async
  {
    _showSnackBar(context, message, Colors.red, SnackBarBehavior.floating);

    try{
      if(logError){
        var userDetailsModel = Provider.of<UserDetailsModel>(context);
        Map<String, dynamic> params = {
          "error_message": errorMessage,
          "error_stack_trace": errorStackTrace,
          "error_source": errorSource,
          "severity_level": severityLevel,
          "user_id": userDetailsModel.userId,
          "request_path": requestPath,
        };
        
        await FlaskApiService().insertRecord("dbo.SPROC_LOG_ERROR", params);
      }
    }catch(e){
      //Do nothing
    }
  }

  /// A reusable method that can be used for success and error messages.
  static void _showSnackBar(
      BuildContext context, String message, Color backgroundColor, SnackBarBehavior behavior) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: behavior,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
    );
  }
}
