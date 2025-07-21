import 'dart:convert';

/// Utility class for parsing test configuration data
class TestConfigParser {
  
  /// Parses test configuration JSON and extracts the formatted SQL query
  /// Handles both normal config structure and error-containing config structure
  static String parseFormattedSql(String configJson) {
    String cleanedJson = configJson.replaceAll('{\n', '{').replaceAll('\n}', '}');
    if (configJson.isEmpty) {
      return "";
    }

    try {
     
      final configMap = jsonDecode(cleanedJson);
      return configMap["formatted_sql"] ?? "";
      
    } catch (e) {
      return "";
    }
  }

  /// Creates a new config JSON with formatted SQL
  static String createConfigJson(String formattedSql) {
    final config = {
      "formatted_sql": formattedSql,
    };
    return jsonEncode(config);
  }
} 