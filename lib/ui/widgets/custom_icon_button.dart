import 'package:flutter/material.dart';

class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? padding;
  final bool isProcessing;
  final bool isEnabled;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
    this.padding,
    this.isProcessing = false,
    this.isEnabled = true,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
    final fg = widget.iconColor ?? Theme.of(context).colorScheme.secondary;

    return Opacity(
      opacity: widget.isEnabled ? 1.0 : 0.5,
      child: MouseRegion(
        onEnter: widget.isEnabled ? (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        } : null,
        onExit: widget.isEnabled ? (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        } : null,
        child: Tooltip(
          message: widget.tooltip ?? '',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (widget.isProcessing || !widget.isEnabled) ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(12),
              splashColor: widget.isEnabled ? fg.withOpacity(0.1) : Colors.transparent,
              highlightColor: widget.isEnabled ? fg.withOpacity(0.2) : Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(widget.padding ?? 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: bg.withOpacity(_isHovered && widget.isEnabled ? 0.4 : 0.3),
                      blurRadius: _isHovered && widget.isEnabled ? 12 : 8,
                      offset: Offset(0, _isHovered && widget.isEnabled ? 3 : 2),
                    ),
                  ],
                ),
                child: ScaleTransition(
                  scale: _scaleAnimation,
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
                          widget.icon,
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
