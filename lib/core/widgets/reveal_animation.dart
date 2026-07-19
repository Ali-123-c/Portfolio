import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A wrapper widget that triggers a smooth reveal animation when its child
/// becomes visible in the viewport (i.e. when the user scrolls to it).
/// Uses fade + slide combination driven by an AnimationController for
/// stable widget identity and reliable scroll-triggered playback.
class RevealAnimation extends StatefulWidget {
  final Widget child;
  final int delayMilliseconds;
  final Axis slideAxis;

  const RevealAnimation({
    super.key,
    required this.child,
    this.delayMilliseconds = 0,
    this.slideAxis = Axis.vertical,
  });

  @override
  State<RevealAnimation> createState() => _RevealAnimationState();
}

class _RevealAnimationState extends State<RevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasTriggered = false;

  // Static counter for stable unique visibility keys
  static int _counter = 0;
  late final String _uniqueId;

  @override
  void initState() {
    super.initState();
    _uniqueId = 'reveal_${++_counter}';

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideAxis == Axis.vertical
          ? const Offset(0, 0.12)
          : const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_hasTriggered && info.visibleFraction > 0) {
      _hasTriggered = true;
      Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(_uniqueId),
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
