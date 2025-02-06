import 'package:intl/intl.dart';

String convertToDateString(String dateTimeString) {
  try {
    // Define the format to match your SQL date format (e.g., "Wed, 05 Feb 2025 00:00:00 GMT")
    DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
    
    // Parse the string into a DateTime object
    DateTime dateTime = inputFormat.parse(dateTimeString);
    
    // Return the formatted date (yyyy-MM-dd)
    return DateFormat('yyyy-MM-dd').format(dateTime);
  } catch (e) {
    // If parsing fails, return an empty string
    return '';
  }
}
