import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/sql.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class CustomCodeFormatter extends StatefulWidget {
  final String initialCode;
  final Function(String)? onCodeChanged;
  final bool readOnly;
  final double? height;
  final double? width;
  final String theme;

  const CustomCodeFormatter({
    super.key,
    required this.initialCode,
    this.onCodeChanged,
    this.readOnly = false,
    this.height,
    this.width,
    this.theme = 'vs2015',
  });

  @override
  State<CustomCodeFormatter> createState() => _CustomCodeFormatterState();
}

class _CustomCodeFormatterState extends State<CustomCodeFormatter> {
  late CodeController _codeController;
  late Map<String, TextStyle> _themeMap;

  @override
  void initState() {
    super.initState();
    _themeMap = _getThemeMap();

    _codeController = CodeController(
      text: widget.initialCode.isEmpty ? '' : widget.initialCode,
      language: sql,
    );

    if (widget.onCodeChanged != null) {
      _codeController.addListener(() {
        if (_codeController.text.isNotEmpty) {
          widget.onCodeChanged!(_codeController.text);
        }
      });
    }
  }

  Map<String, TextStyle> _getThemeMap() {
    switch (widget.theme.toLowerCase()) {
      case 'monokai':
        return monokaiSublimeTheme;
      case 'github':
        return githubTheme;
      case 'atom':
        return atomOneDarkTheme;
      case 'vs2015':
      default:
        return vs2015Theme;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 200, // Provide a default height
      width: widget.width,
      decoration: BoxDecoration(
        color: _themeMap['root']?.backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: CodeTheme(
        data: CodeThemeData(
          styles: _themeMap,
        ),
        child: CodeField(
          controller: _codeController,
          textStyle: TextStyles.gridText(context).copyWith(
            color: Colors.white30,
            fontFamily: 'monospace',
          ),
          readOnly: widget.readOnly,
          expands: true,
          cursorColor: AppColors.primaryColor,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColors.primaryColor,
            selectionColor: AppColors.primaryColor.withOpacity(0.2),
            selectionHandleColor: AppColors.primaryColor,
          ),
          gutterStyle: GutterStyle(
            textStyle: TextStyle(
              color: _themeMap['root']?.color?.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
