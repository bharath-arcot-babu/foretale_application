# WebSocket Progress Indicator Usage

## Overview
The `WebSocketProgressIndicator` component provides a visual progress tracker for websocket-based AI processing steps. It shows each step with appropriate icons and status indicators.

## Supported Steps
The component supports the following processing steps in order:

1. **test_case_summarizer** - Summarizing Test Case
2. **ambiguity_resolver** - Resolving Ambiguities  
3. **all_tables_extractor** - Extracting Tables
4. **table_resolver** - Resolving Tables
5. **target_columns_extractor** - Extracting Columns
6. **column_resolver** - Resolving Columns
7. **joins_resolver** - Resolving Joins
8. **sql_query_generator** - Generating SQL
9. **column_modifier** - Modifying Columns
10. **sql_query_formatter** - Formatting Query

## Usage in Chat Screen

### 1. Import the component
```dart
import 'package:foretale_application/ui/widgets/chat/websocket_progress_indicator.dart';
```

### 2. Add state variables
```dart
String? websocketProgress;
bool isWebsocketProcessing = false;
```

### 3. Handle websocket messages
```dart
webSocketService.messages.listen((message) {
  // Parse websocket message using the detailed JSON parser
  final parsedData = WebSocketProgressIndicator.parseDetailedWebSocketMessage(message);
  
  if (parsedData != null) {
    setState(() {
      websocketProgress = parsedData['step'];
      websocketData = parsedData;
      
      if (parsedData['step'] == '[[DONE]]') {
        isWebsocketProcessing = false;
      } else if (parsedData['status'] == 'error') {
        isWebsocketProcessing = false;
      } else {
        isWebsocketProcessing = true;
      }
    });
  }
});
```

### 4. Pass to InputArea
```dart
InputArea(
  // ... other props
  websocketProgress: websocketProgress,
  isWebsocketProcessing: isWebsocketProcessing,
  websocketData: websocketData,
)
```

## WebSocket Message Format

Your websocket service should send messages in JSON format with rich data:

### Progress Updates (Enhanced)
```json
{
  "type": "progress",
  "step": "test_case_summarizer",
  "status": "completed",
  "message": "Completed Test Case Summarizer",
  "data": {
    "summary": "This test case aims to identify purchase orders...",
    "resolved_tables": [],
    "resolved_columns": [],
    "key_criteria": ["total_amount <= 0"],
    "ambiguities": ["exact column name for purchase order amount"]
  }
}
```

### Completion (Enhanced)
```json
{
  "type": "complete",
  "message": "Test case processing completed successfully",
  "final_state": {
    "test_case": "Check for invalid purchase order amount",
    "summary": "This test case aims to identify purchase orders...",
    "formatted_sql_query": "SELECT po.purchase_order_number..."
  }
}
```

### Errors
```json
{"type": "error", "error": "No SQL query generated. State: {...}", "message": "Test case processing failed"}
```

The error format supports both `error` and `message` fields for backward compatibility.

### Legacy Format Support
The component also supports the legacy format for backward compatibility:
```
[[PROGRESS]]test_case_summarizer
[[DONE]]
[[ERROR]]Failed to process request
```

## Visual States

### Processing State
- Shows current step with blue icon
- Displays progress bar
- Lists all steps with appropriate status
- Completed steps show green checkmark
- Pending steps show grey icon
- **Enhanced**: Shows detailed messages from websocket data
- **Enhanced**: Displays step-specific information and status

### Error State
- Red background with error icon
- Shows error message
- Maintains visual consistency

### Completed State
- Green background with checkmark
- Shows "Processing completed successfully"
- Clean, positive feedback

## Integration with InputArea

The component is automatically integrated into the `InputArea` widget and will appear:
- Below file previews
- Above the input text field
- Only when processing is active
- With appropriate spacing and styling

## Customization

The component uses the app's design system:
- `TextStyles.smallSupplementalInfo()` for step titles
- `TextStyles.tinySupplementalInfo()` for descriptions
- Consistent color scheme (blue for active, green for completed, grey for pending)
- Responsive sizing based on screen width 