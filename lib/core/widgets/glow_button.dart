import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/colors.dart';

class GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final FaIconData? icon;
  final Color color;
  final bool isSecondary;
  final double height;

  const GlowButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color = AppColors.cyanAccent,
    this.isSecondary = false,
    this.height = 50.0,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Scale on hover
    final scale = _isHovered ? 1.04 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isSecondary
                ? Colors.transparent
                : (_isHovered ? widget.color.withValues(alpha: 0.95) : widget.color.withValues(alpha: 0.8)),
            border: Border.all(
              color: widget.isSecondary
                  ? (_isHovered ? widget.color : widget.color.withValues(alpha: 0.5))
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? widget.color.withValues(alpha: 0.35) 
                    : widget.color.withValues(alpha: 0.12),
                blurRadius: _isHovered ? 20 : 10,
                spreadRadius: _isHovered ? 1 : -1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              if (widget.icon != null) ...[
                FaIcon(
                  widget.icon,
                  size: 16,
                  color: widget.isSecondary ? widget.color : Colors.black,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: widget.isSecondary ? widget.color : Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
