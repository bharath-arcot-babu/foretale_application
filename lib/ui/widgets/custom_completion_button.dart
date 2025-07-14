import 'package:flutter/material.dart';

class CustomCompletionButton extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback onToggle;
  final String? tooltip;
  final double iconSize;
  final Color? backgroundColor;
  final Color? completedColor;
  final Color? incompleteColor;
  final double? padding;
  final bool isProcessing;

  const CustomCompletionButton({
    super.key,
    required this.isCompleted,
    required this.onToggle,
    this.tooltip,
    this.iconSize = 20,
    this.backgroundColor,
    this.completedColor,
    this.incompleteColor,
    this.padding,
    this.isProcessing = false,
  });

  @override
  State<CustomCompletionButton> createState() => _CustomCompletionButtonState();
}

class _CustomCompletionButtonState extends State<CustomCompletionButton> 
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer;
    final completedColor = widget.completedColor ?? Colors.green;
    final incompleteColor = widget.incompleteColor ?? Theme.of(context).colorScheme.secondary;
    
    final fg = widget.isCompleted ? completedColor : incompleteColor;
    final icon = widget.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: Tooltip(
        message: widget.tooltip ?? (widget.isCompleted ? 'Mark as incomplete' : 'Mark as complete'),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isProcessing ? null : widget.onToggle,
            borderRadius: BorderRadius.circular(12),
            splashColor: fg.withOpacity(0.1),
            highlightColor: fg.withOpacity(0.2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(widget.padding ?? 8),
              decoration: BoxDecoration(
                color: widget.isCompleted ? completedColor.withOpacity(0.1) : bg,
                borderRadius: BorderRadius.circular(12),
                border: widget.isCompleted 
                    ? Border.all(color: completedColor.withOpacity(0.3), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: fg.withOpacity(_isHovered ? 0.4 : 0.3),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: Offset(0, _isHovered ? 3 : 2),
                  ),
                ],
              ),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: RotationTransition(
                  turns: _rotationAnimation,
                  child: widget.isProcessing
                      ? SizedBox(
                          width: widget.iconSize,
                          height: widget.iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(fg),
                          ),
                        )
                      : Icon(
                          icon,
                          size: widget.iconSize,
                          color: fg,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 