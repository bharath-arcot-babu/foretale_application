import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/button_styles.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class CustomElevatedButton extends StatefulWidget {
  final double? width;
  final double? height;
  final String text;
  final double textSize;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final bool useGradient;
  final Gradient? customGradient;
  final Color? disabledColor;
  final Color? disabledTextColor;

  const CustomElevatedButton({
    super.key,
    this.width,
    this.height,
    required this.text,
    required this.textSize,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.useGradient = false,
    this.customGradient,
    this.disabledColor,
    this.disabledTextColor,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading && widget.useGradient) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(CustomElevatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && widget.useGradient) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.text.trim().isNotEmpty;
    final hasIcon = widget.icon != null;
    final isDisabled = !widget.isEnabled || widget.isLoading;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              gradient: _getGradient(),
              boxShadow: isDisabled ? null : [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isDisabled ? null : widget.onPressed,
              style: _getButtonStyle(),
              child: widget.isLoading
                  ? _buildLoadingContent()
                  : _buildContent(context, hasText, hasIcon),
            ),
          );
        },
      ),
    );
  }

  Gradient? _getGradient() {
    if (!widget.useGradient) return null;
    
    if (widget.customGradient != null) {
      return widget.customGradient;
    }

    if (!widget.isEnabled) {
      return LinearGradient(
        colors: [
          widget.disabledColor ?? ButtonColors.disabledButtonColor,
          (widget.disabledColor ?? ButtonColors.disabledButtonColor).withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (widget.isLoading) {
      return LinearGradient(
        colors: [
          AppColors.primaryColor.withOpacity(0.7),
          AppColors.accentColor.withOpacity(0.5),
          AppColors.primaryColor.withOpacity(0.7),
        ],
        stops: [
          _animation.value - 0.2,
          _animation.value,
          _animation.value + 0.2,
        ].map((value) => value.clamp(0.0, 1.0)).toList(),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return LinearGradient(
      colors: [
        AppColors.primaryColor.withOpacity(0.8),
        AppColors.accentColor.withOpacity(0.6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  ButtonStyle _getButtonStyle() {
    final baseStyle = ButtonStyles.elevatedButtonStyle();
    
    if (!widget.isEnabled) {
      return baseStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(
          widget.disabledTextColor ?? Colors.grey[600],
        ),
        elevation: MaterialStateProperty.all(0),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
      );
    }

    if (widget.useGradient) {
      return baseStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        elevation: MaterialStateProperty.all(0),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
      );
    }

    return baseStyle;
  }

  Widget _buildLoadingContent() {
    if (widget.useGradient) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.textSize + 2,
            height: widget.textSize + 2,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
          if (widget.text.trim().isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              widget.text,
              style: TextStyles.elevatedButtonTextStyle(context).copyWith(
                fontSize: widget.textSize,
                color: Colors.white,
              ),
            ),
          ],
        ],
      );
    }

    return SizedBox(
      width: widget.textSize + 2,
      height: widget.textSize + 2,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool hasText, bool hasIcon) {
    final textColor = !widget.isEnabled 
        ? (widget.disabledTextColor ?? Colors.grey[600])
        : Colors.white;

    final textWidget = Text(
      widget.text,
      style: TextStyles.elevatedButtonTextStyle(context).copyWith(
        fontSize: widget.textSize,
        color: textColor,
      ),
    );

    if (hasIcon && hasText) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon, 
            size: widget.textSize + 2,
            color: textColor,
          ),
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    } else if (hasIcon) {
      return Icon(
        widget.icon, 
        size: widget.textSize + 2,
        color: textColor,
      );
    } else {
      return textWidget;
    }
  }
}
