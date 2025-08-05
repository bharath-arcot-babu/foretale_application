import 'dart:convert';

/// Utility class for parsing test configuration data
class TestConfigParser {
  
  /// Parses test configuration JSON and extracts the formatted SQL query
  /// Handles both normal config structure and error-containing config structure
  static String parseFormattedSql(String configJson) {
    if (configJson.trim().isEmpty) return "";

    try {
      dynamic decoded = jsonDecode(configJson);

      // If the first decode gives you a string, decode again
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }

      if (decoded is Map<String, dynamic>) {
        // Check root level
        if (decoded.containsKey("formatted_sql")) {
          return decoded["formatted_sql"] ?? "";
        }

        // Check nested
        for (var value in decoded.values) {
          if (value is Map<String, dynamic> && value.containsKey("formatted_sql")) {
            return value["formatted_sql"] ?? "";
          }
        }
      }

      return "";
    } catch (e) {
      print("Error parsing config JSON: $e");
      return "";
    }
  }



  /// Creates a new config JSON with formatted SQL
  static String createConfigJson(String formattedSql) {
    final config = {
      "formatted_sql": formattedSql.trim().isEmpty ? "-- No SQL query available --" : formattedSql,
    };
    return jsonEncode(config);
  }

  
  /// Validates if the given JSON string is a valid test config
  static bool isValidConfig(String configJson) {
    if (configJson.isEmpty) {
      return false;
    }
    
    try {
      final configMap = jsonDecode(configJson);
      return configMap is Map<String, dynamic> && 
             configMap.containsKey("formatted_sql");
    } catch (e) {
      return false;
    }
  }
} 