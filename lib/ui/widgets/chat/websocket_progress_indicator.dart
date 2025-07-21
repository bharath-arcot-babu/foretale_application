import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'dart:convert';

class WebSocketProgressIndicator extends StatelessWidget {
  final String? currentStep;
  final bool isProcessing;
  final String? errorMessage;
  final Map<String, dynamic>? progressData;

  const WebSocketProgressIndicator({
    super.key,
    this.currentStep,
    this.isProcessing = false,
    this.errorMessage,
    this.progressData,
  });

  /// Parse JSON websocket message to extract step information
  static String? parseWebSocketMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      
      if (data['type'] == 'progress' && data['step'] != null) {
        return data['step'] as String;
      } else if (data['type'] == 'error' && data['message'] != null) {
        return 'Error: ${data['message']}';
      } else if (data['type'] == 'complete') {
        return '[[DONE]]';
      }
    } catch (e) {
      // If JSON parsing fails, try legacy format
      if (message.startsWith("[[PROGRESS]]")) {
        return message.substring(12);
      } else if (message.startsWith("[[ERROR]]")) {
        return "Error: ${message.substring(9)}";
      } else if (message.startsWith("[[DONE]]")) {
        return "[[DONE]]";
      }
    }
    return null;
  }

  /// Parse JSON websocket message to extract detailed progress information
  static Map<String, dynamic>? parseDetailedWebSocketMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      
      if (data['type'] == 'progress' && data['step'] != null) {
        return {
          'step': data['step'] as String,
          'status': data['status'] as String? ?? 'processing',
          'message': data['message'] as String? ?? '',
          'data': data['data'] as Map<String, dynamic>? ?? {},
        };
      } else if (data['type'] == 'error') {
        String errorMessage = 'An error occurred';
        if (data['error'] != null) {
          errorMessage = data['error'] as String;
        } else if (data['message'] != null) {
          errorMessage = data['message'] as String;
        }
        return {
          'step': '[[ERROR]]',
          'status': 'error',
          'message': errorMessage,
          'data': data,
        };
      } else if (data['type'] == 'complete') {
        return {
          'step': '[[DONE]]',
          'status': 'completed',
          'message': data['message'] as String? ?? 'Processing completed successfully',
          'data': data['final_state'] is Map ? Map<String, dynamic>.from(data['final_state']) : {},
        };
      }
    } catch (e) {
      // If JSON parsing fails, try legacy format
      if (message.startsWith("[[PROGRESS]]")) {
        return {
          'step': message.substring(12),
          'status': 'processing',
          'message': '',
          'data': {},
        };
      } else if (message.startsWith("[[ERROR]]")) {
        return {
          'step': 'error',
          'status': 'error',
          'message': message.substring(9),
          'data': {'error': message.substring(9)},
        };
      } else if (message.startsWith("[[DONE]]")) {
        return {
          'step': '[[DONE]]',
          'status': 'completed',
          'message': 'Processing completed successfully',
          'data': {},
        };
      }
    }
    return null;
  }

  static final Map<String, Map<String, dynamic>> _stepConfigs = {
    'test_case_summarizer': {
      'title': 'Summarizing Test Case',
      'icon': Icons.description,
      'description': 'Analyzing test requirements',
    },
    'ambiguity_resolver': {
      'title': 'Resolving Ambiguities',
      'icon': Icons.help_outline,
      'description': 'Clarifying unclear requirements',
    },
    'all_tables_extractor': {
      'title': 'Extracting Tables',
      'icon': Icons.table_chart,
      'description': 'Identifying relevant tables',
    },
    'table_resolver': {
      'title': 'Resolving Tables',
      'icon': Icons.table_view,
      'description': 'Validating table references',
    },
    'target_columns_extractor': {
      'title': 'Extracting Columns',
      'icon': Icons.view_column_outlined,
      'description': 'Identifying relevant columns',
    },
    'column_resolver': {
      'title': 'Resolving Columns',
      'icon': Icons.view_column,
      'description': 'Validating column references',
    },
    'joins_resolver': {
      'title': 'Resolving Joins',
      'icon': Icons.link,
      'description': 'Determining table relationships',
    },
    'sql_query_generator': {
      'title': 'Generating SQL',
      'icon': Icons.code,
      'description': 'Creating SQL query',
    },
    'column_modifier': {
      'title': 'Modifying Columns',
      'icon': Icons.edit,
      'description': 'Adjusting column selections',
    },
    'sql_query_formatter': {
      'title': 'Formatting Query',
      'icon': Icons.format_align_left,
      'description': 'Finalizing query format',
    },
  };

  static const List<String> _stepOrder = [
    'test_case_summarizer',
    'ambiguity_resolver',
    'all_tables_extractor',
    'table_resolver',
    'target_columns_extractor',
    'column_resolver',
    'joins_resolver',
    'sql_query_generator',
    'column_modifier',
    'sql_query_formatter',
  ];

  int _getCurrentStepIndex() {
    if (currentStep == null) return -1;
    return _stepOrder.indexOf(currentStep!);
  }

  bool _isStepCompleted(String step) {
    final currentIndex = _getCurrentStepIndex();
    final stepIndex = _stepOrder.indexOf(step);
    return stepIndex < currentIndex;
  }

  bool _isStepActive(String step) {
    return currentStep == step;
  }

  Widget _buildStepIcon(String step, bool isCompleted, bool isActive) {
    final config = _stepConfigs[step]!;
    final icon = config['icon'] as IconData;
    
    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 16,
          color: Colors.white,
        ),
      );
    } else if (isActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildStepItem(BuildContext context, String step, bool isCompleted, bool isActive, bool isLast) {
    final config = _stepConfigs[step]!;
    final title = config['title'] as String;
    final description = config['description'] as String;
    
    // Get detailed message if available
    String? detailedMessage;
    if (isActive && progressData != null && progressData!['message'] != null) {
      detailedMessage = progressData!['message'] as String;
    }

    return Row(
      children: [
        _buildStepIcon(step, isCompleted, isActive),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyles.smallSupplementalInfo(context).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.blue : Colors.grey,
                ),
              ),
              if (isActive && detailedMessage != null && detailedMessage.isNotEmpty)
                Text(
                  detailedMessage,
                  style: TextStyles.tinySupplementalInfo(context).copyWith(
                    color: Colors.blue.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else if (isActive)
                Text(
                  description,
                  style: TextStyles.tinySupplementalInfo(context).copyWith(
                    color: Colors.blue.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            width: 1,
            height: 20,
            color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    if (currentStep == null) return const SizedBox.shrink();
    
    final currentIndex = _getCurrentStepIndex();
    final totalSteps = _stepOrder.length;
    final progress = currentIndex >= 0 ? (currentIndex + 1) / totalSteps : 0.0;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    String displayMessage = errorMessage ?? 'An error occurred during processing';
    
    // If we have detailed error data, try to extract more information
    if (progressData != null && progressData!['data'] != null) {
      final data = progressData!['data'] as Map<String, dynamic>;
      if (data['error'] != null) {
        displayMessage = data['error'] as String;
      } else if (data['message'] != null) {
        displayMessage = data['message'] as String;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Processing Error',
                  style: TextStyles.smallSupplementalInfo(context).copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            displayMessage,
            style: TextStyles.tinySupplementalInfo(context).copyWith(
              color: Colors.red.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Processing completed successfully',
              style: TextStyles.smallSupplementalInfo(context).copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isProcessing && currentStep == null && errorMessage == null) {
      return const SizedBox.shrink();
    }

    // Show error state
    if (errorMessage != null) {
      return _buildErrorState(context);
    }

    // Show completed state
    if (currentStep == '[[DONE]]') {
      return _buildCompletedState(context);
    }

    // Show processing state
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress bar
          Row(
            children: [
              const Icon(
                Icons.sync,
                size: 16,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Processing AI Request',
                  style: TextStyles.smallSupplementalInfo(context).copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(),
          const SizedBox(height: 12),
          
          // Steps
          ...(_stepOrder.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = _isStepCompleted(step);
            final isActive = _isStepActive(step);
            final isLast = index == _stepOrder.length - 1;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildStepItem(context, step, isCompleted, isActive, isLast),
            );
          }).toList()),
        ],
      ),
    );
  }
} 