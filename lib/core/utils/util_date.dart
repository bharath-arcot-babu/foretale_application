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

/// Validates if a date string is in the correct yyyy-mm-dd format and is a valid date
bool isValidDateFormat(String date) {
  try {
    // Check if the date matches yyyy-mm-dd format
    RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) {
      return false;
    }
    
    // Parse the date to ensure it's a valid date
    DateTime.parse(date);
    return true;
  } catch (e) {
    return false;
  }
}

/// Checks if a date is in the past (before today)
bool isDateInPast(String date) {
  try {
    DateTime inputDate = DateTime.parse(date);
    DateTime today = DateTime.now();
    // Compare only the date part (year, month, day)
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    DateTime inputDateOnly = DateTime(inputDate.year, inputDate.month, inputDate.day);
    
    return inputDateOnly.isBefore(todayDate);
  } catch (e) {
    return false;
  }
}

/// Validates that end date is after start date
bool isEndDateAfterStartDate(String startDate, String endDate) {
  try {
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);
    
    // Compare only the date part (year, month, day)
    DateTime startDateOnly = DateTime(start.year, start.month, start.day);
    DateTime endDateOnly = DateTime(end.year, end.month, end.day);
    
    return endDateOnly.isAfter(startDateOnly);
  } catch (e) {
    return false;
  }
}

/// Formats a date string to a more readable format
String formatDateForDisplay(String date) {
  try {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('MMM dd, yyyy').format(dateTime);
  } catch (e) {
    return date; // Return original string if parsing fails
  }
}

/// Gets today's date in yyyy-mm-dd format
String getTodayDate() {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

/// Validates if a date is today
bool isDateToday(String date) {
  try {
    DateTime inputDate = DateTime.parse(date);
    DateTime today = DateTime.now();
    // Compare only the date part (year, month, day)
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    DateTime inputDateOnly = DateTime(inputDate.year, inputDate.month, inputDate.day);
    
    return inputDateOnly.isAtSameMomentAs(todayDate);
  } catch (e) {
    return false;
  }
}

