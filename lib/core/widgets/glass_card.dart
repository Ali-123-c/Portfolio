import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final Color borderColor;
  final Color glowColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool enable3DTilt;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.borderRadius = 16.0,
    this.borderColor = AppColors.glassBorder,
    this.glowColor = Colors.transparent,
    this.padding = const EdgeInsets.all(24.0),
    this.onTap,
    this.enable3DTilt = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  Offset _mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    // Fallback to Cyan accent if glowColor is not specified
    final effectiveGlowColor = widget.glowColor != Colors.transparent 
        ? widget.glowColor 
        : AppColors.cyanAccent;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _tiltX = 0.0;
        _tiltY = 0.0;
      }),
      onHover: widget.enable3DTilt ? (event) {
        if (!_isHovered) return;
        final size = context.size;
        if (size == null) return;
        setState(() {
          _mousePos = event.localPosition;
          final centerX = size.width / 2;
          final centerY = size.height / 2;
          _tiltY = ((event.localPosition.dx - centerX) / centerX) * 0.08;
          _tiltX = -((event.localPosition.dy - centerY) / centerY) * 0.08;
        });
      } : null,
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateX(_tiltX)
            ..rotateY(_tiltY)
            ..scaleByDouble(_isHovered ? 1.03 : 1.0, _isHovered ? 1.03 : 1.0, 1.0, 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? effectiveGlowColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                blurRadius: 30,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.glassBackground.withValues(alpha: 0.08)
                      : AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: _isHovered
                        ? effectiveGlowColor.withValues(alpha: 0.4)
                        : widget.borderColor,
                    width: _isHovered ? 1.2 : 1.0,
                  ),
                  gradient: _isHovered
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            effectiveGlowColor.withValues(alpha: 0.03),
                            Colors.transparent,
                            effectiveGlowColor.withValues(alpha: 0.01),
                          ],
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    widget.child,
                    // Shine effect overlay on hover
                    if (_isHovered && widget.enable3DTilt)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(widget.borderRadius),
                              gradient: RadialGradient(
                                center: Alignment(
                                  (_mousePos.dx / (context.size?.width ?? 1) - 0.5) * 2,
                                  (_mousePos.dy / (context.size?.height ?? 1) - 0.5) * 2,
                                ),
                                radius: 0.5,
                                colors: [
                                  Colors.white.withValues(alpha: 0.06),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
