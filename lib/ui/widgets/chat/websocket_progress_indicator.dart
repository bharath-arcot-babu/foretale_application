import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';

class WebSocketProgressIndicator extends StatelessWidget {
  final String? currentStep;
  final bool isProcessing;
  final Map<String, dynamic>? progressData;

  const WebSocketProgressIndicator({
    super.key,
    this.currentStep,
    this.isProcessing = false,
    this.progressData,
  });

  static const Map<String, Map<String, dynamic>> _stepConfigs = {
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

  int get _currentStepIndex => 
      currentStep == null ? -1 : _stepOrder.indexOf(currentStep!);

  double get _progress => 
      _currentStepIndex >= 0 ? (_currentStepIndex + 1) / _stepOrder.length : 0.0;

  bool _isStepCompleted(String step) {
    final stepIndex = _stepOrder.indexOf(step);
    return stepIndex < _currentStepIndex;
  }

  Widget _buildStepIcon(String step, bool isCompleted, bool isActive) {
    final config = _stepConfigs[step]!;
    final icon = config['icon'] as IconData;
    
    Color backgroundColor;
    Color iconColor;
    IconData displayIcon;
    
    if (isCompleted) {
      backgroundColor = Colors.green;
      iconColor = Colors.white;
      displayIcon = Icons.check;
    } else if (isActive) {
      backgroundColor = Colors.blue;
      iconColor = Colors.white;
      displayIcon = icon;
    } else {
      backgroundColor = Colors.grey.withOpacity(0.3);
      iconColor = Colors.grey;
      displayIcon = icon;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        displayIcon,
        size: 16,
        color: iconColor,
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, String step, int index) {
    final config = _stepConfigs[step]!;
    final isCompleted = _isStepCompleted(step);
    final isActive = currentStep == step;
    final isLast = index == _stepOrder.length - 1;

    return Row(
      children: [
        _buildStepIcon(step, isCompleted, isActive),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config['title'] as String,
                style: TextStyles.smallSupplementalInfo(context).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.blue : Colors.grey,
                ),
              ),
              if (isActive)
                Text(
                  config['description'] as String,
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

  Widget _buildStatusContainer(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.smallSupplementalInfo(context).copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyles.tinySupplementalInfo(context).copyWith(
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isProcessing && currentStep == null) {
      return const SizedBox.shrink();
    }

    // Error state
    if (progressData != null && progressData!['type'] == 'error') {
      String errorMessage = 'An error occurred during processing';
      if (progressData!['data'] != null) {
        final data = progressData!['data'] as Map<String, dynamic>;
        if (data['type'] == 'error') {
          errorMessage = data.toString();
        }
      }
      
      return _buildStatusContainer(
        context,
        color: Colors.red,
        icon: Icons.error_outline,
        title: 'An Error Occurred',
        subtitle: errorMessage,
      );
    }

    // Completed state
    if (currentStep == '[[DONE]]') {
      return _buildStatusContainer(
        context,
        color: Colors.green,
        icon: Icons.check_circle_outline,
        title: 'AI request completed.',
      );
    }

    // Processing state
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
          // Header
          Row(
            children: [
              CustomIconButton(
                icon: Icons.sync,
                onPressed: () {},
                iconSize: 16,
                iconColor: Colors.blue,
                backgroundColor: Colors.blue.withOpacity(0.1),
                padding: 8,
                isProcessing: isProcessing,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Configuring test case...',
                  style: TextStyles.smallSupplementalInfo(context).copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Steps
          ...(_stepOrder.asMap().entries.map((entry) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildStepItem(context, entry.value, entry.key),
            ),
          )),
        ],
      ),
    );
  }
} 