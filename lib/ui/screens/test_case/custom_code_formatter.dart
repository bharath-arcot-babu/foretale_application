import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:highlight/languages/sql.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';


class CustomCodeFormatter extends StatefulWidget {
  final String initialCode;
  final Test selectedTest;
  final Function(String)? onCodeChanged;
  final double? height;
  final double? width;
  final String theme;
  final VoidCallback? onSaveQuery;
  final VoidCallback? onRunQuery;
  final bool showSaveRunButtons;
  final bool showValidationButton;
  final VoidCallback? onMaximizeChanged;

  const CustomCodeFormatter({
    super.key,
    required this.selectedTest,
    required this.initialCode,
    this.onCodeChanged,
    this.height,
    this.width,
    this.theme = 'monokai',
    this.onSaveQuery,
    this.onRunQuery,
    this.showSaveRunButtons = false,
    this.showValidationButton = true,
    this.onMaximizeChanged,
  });

  @override
  State<CustomCodeFormatter> createState() => _CustomCodeFormatterState();
}

class _CustomCodeFormatterState extends State<CustomCodeFormatter> {
  late CodeController _codeController;
  Timer? _debounceTimer;
  bool _isValid = true;
  String _validationMessage = '';


  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.initialCode,
      language: sql,
    );
  }

  @override
  void didUpdateWidget(CustomCodeFormatter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCode != widget.initialCode) {
      _codeController.text = widget.initialCode;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Map<String, TextStyle> _getThemeStyles() {
    final baseTheme = switch (widget.theme.toLowerCase()) {
      'github' => githubTheme,
      'atom' => atomOneDarkTheme,
      'vs2015' => vs2015Theme,
      _ => monokaiSublimeTheme,
    };

    return {
      ...baseTheme,
      'root': const TextStyle(
        backgroundColor: AppColors.surfaceColor,
        color: TextColors.primaryTextColor,
      ),
      'code': const TextStyle(
        backgroundColor: AppColors.surfaceColor,
        color: TextColors.primaryTextColor,
      ),
    };
  }

  void _onCodeChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onCodeChanged?.call(value.trim());
    });
  }

  void _showMaximizedDialog() {
    widget.onMaximizeChanged?.call();
  }

  Widget _buildHeader(String title, bool isMaximized) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyles.gridText(context).copyWith(color: Colors.black)),
          ),          
          if (widget.showSaveRunButtons) ...[
            const SizedBox(width: 4),
            CustomIconButton(
              icon: Icons.save,
              onPressed: widget.onSaveQuery ?? () {},
              tooltip: 'Save',
              iconSize: 18.0,
              isEnabled: widget.selectedTest.testConfigExecutionStatus.trim() != "Running",
            ),
            const SizedBox(width: 4),
            CustomIconButton(
              icon: Icons.play_arrow,
              onPressed: widget.onRunQuery ?? () {},
              tooltip: 'Save & Run',
              iconSize: 18.0,
              isEnabled: widget.selectedTest.testConfigExecutionStatus.trim() != "Running",
            ),
          ],
          
          const SizedBox(width: 4),
          CustomIconButton(
            icon: isMaximized ? Icons.close : Icons.fullscreen,
            onPressed: isMaximized ? () => Navigator.of(context).pop() : _showMaximizedDialog,
            iconSize: 20,
            tooltip: isMaximized ? 'Minimize' : 'Maximize',
          ),
        ],
      ),
    );
  }

  Widget _buildEditorContainer({double? height, double? width, bool isMaximized = false}) {
    return Container(
      height: height ?? widget.height,
      width: width ?? widget.width,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BorderColors.tertiaryColor.withOpacity(0.3), width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(isMaximized ? 'Code Editor' : 'Code Editor', isMaximized),
          Expanded(
            child: SingleChildScrollView(
              child: _buildCodeField(),
            ),
          ),
          if (_validationMessage.isNotEmpty)
            _buildValidationMessage(),
        ],
      ),
    );
  }

  Widget _buildCodeField() {
    return CodeTheme(
      data: CodeThemeData(styles: _getThemeStyles()),
      child: CodeField(
        key: ValueKey(widget.initialCode),
        controller: _codeController,
        textStyle: TextStyles.gridText(context).copyWith(
          color: TextColors.primaryTextColor,
          fontFamily: 'monospace',
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryColor,
          selectionColor: AppColors.primaryColor.withOpacity(0.2),
          selectionHandleColor: AppColors.primaryColor,
        ),
        gutterStyle: const GutterStyle(
          textStyle: TextStyle(color: TextColors.hintTextColor),
        ),
        onChanged: _onCodeChanged,
      ),
    );
  }

  Widget _buildValidationMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: _isValid ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isValid ? Icons.check_circle : Icons.error,
            size: 16,
            color: _isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _validationMessage,
              style: TextStyle(
                color: _isValid ? Colors.green.shade700 : Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return _buildEditorContainer();
  }
}
