import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A floating glassmorphic "Back to Top" button that smoothly fades in/out
/// based on the scroll controller's offset. Clicking it scrolls to the top
/// with a smooth cubic-bezier animation.
class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final double showThreshold;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
    this.showThreshold = 600,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    widget.scrollController.addListener(_onScroll);
    // Check initial position
    _onScroll();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final shouldShow = widget.scrollController.offset > widget.showThreshold;

    if (shouldShow != _isVisible) {
      setState(() => _isVisible = shouldShow);
      if (shouldShow) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _scrollToTop,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.2,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF0A0A0A),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.cyanAccent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanAccent.withValues(alpha: 0.15),
                      blurRadius: 15,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: AppColors.purpleAccent.withValues(alpha: 0.08),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring glow
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cyanAccent.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    // Arrow icon
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.cyanAccent,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
