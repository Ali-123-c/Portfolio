import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final bool enableParallax;

  const ParticleBackground({
    super.key,
    required this.child,
    this.enableParallax = true,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Particle> _particles = [];
  Offset _mouseOffset = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    final random = Random(42);
    _particles = List.generate(120, (index) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        z: random.nextDouble(), // depth: 0 = far, 1 = near
        size: 0.5 + random.nextDouble() * 2.5,
        speed: 0.2 + random.nextDouble() * 0.8,
        opacity: 0.2 + random.nextDouble() * 0.6,
        driftX: (random.nextDouble() - 0.5) * 0.0003,
        driftY: (random.nextDouble() - 0.5) * 0.0003,
        color: random.nextDouble() > 0.7
            ? AppColors.purpleAccent
            : AppColors.cyanAccent,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent event) {
    if (!widget.enableParallax) return;
    final size = context.size;
    if (size == null) return;
    setState(() {
      _mouseOffset = Offset(
        (event.localPosition.dx / size.width - 0.5) * 2,
        (event.localPosition.dy / size.height - 0.5) * 2,
      );
      _isHovered = true;
    });
  }

  void _onPointerExit(PointerEvent event) {
    setState(() {
      _isHovered = false;
      _mouseOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onPointerMove,
      onExit: _onPointerExit,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final time = _controller.value;
          _updateParticles(time);
          return Stack(
            children: [
              // 3D Particle Canvas
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    mouseOffset: _isHovered ? _mouseOffset : Offset.zero,
                  ),
                ),
              ),
              // Content overlay
              widget.child,
            ],
          );
        },
      ),
    );
  }

  void _updateParticles(double time) {
    for (var p in _particles) {
      // Drift particles slowly
      p.x += p.driftX + sin(time * 2 + p.y * 10) * 0.0001;
      p.y += p.driftY + cos(time * 1.5 + p.x * 10) * 0.0001;

      // Wrap around edges
      if (p.x < -0.1) p.x = 1.1;
      if (p.x > 1.1) p.x = -0.1;
      if (p.y < -0.1) p.y = 1.1;
      if (p.y > 1.1) p.y = -0.1;
    }
  }
}

class _Particle {
  double x, y, z;
  double size, speed, opacity;
  double driftX, driftY;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.z,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.driftX,
    required this.driftY,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Offset mouseOffset;

  _ParticlePainter({
    required this.particles,
    required this.mouseOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Sort particles by depth (far to near) for painter order
    final sorted = List<_Particle>.from(particles)
      ..sort((a, b) => a.z.compareTo(b.z));

    // Draw connection lines between nearby particles
    for (int i = 0; i < sorted.length; i++) {
      for (int j = i + 1; j < sorted.length; j++) {
        final p1 = sorted[i];
        final p2 = sorted[j];

        // Depth-adjusted positions with mouse parallax
        final parallaxFactor1 = p1.z * 20;
        final parallaxFactor2 = p2.z * 20;

        final x1 = p1.x * size.width + mouseOffset.dx * parallaxFactor1;
        final y1 = p1.y * size.height + mouseOffset.dy * parallaxFactor1;
        final x2 = p2.x * size.width + mouseOffset.dx * parallaxFactor2;
        final y2 = p2.y * size.height + mouseOffset.dy * parallaxFactor2;

        final dx = x2 - x1;
        final dy = y2 - y1;
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < 150) {
          final opacity = (1 - distance / 150) * 0.15 * p1.z * p2.z;
          final paint = Paint()
            ..color = Colors.white.withValues(alpha: opacity.clamp(0.0, 0.15))
            ..strokeWidth = 0.5;
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
        }
      }
    }

    // Draw particles
    for (var p in sorted) {
      // Depth affects size, opacity, and parallax
      final depthScale = 0.5 + p.z * 0.5;
      final parallaxFactor = p.z * 20;

      final x = p.x * size.width + mouseOffset.dx * parallaxFactor;
      final y = p.y * size.height + mouseOffset.dy * parallaxFactor;

      final particleSize = p.size * depthScale;

      // Glow effect
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * 0.15 * depthScale)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), particleSize * 3, glowPaint);

      // Core particle
      final corePaint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * depthScale);
      canvas.drawCircle(Offset(x, y), particleSize, corePaint);

      // Bright center
      if (p.z > 0.6) {
        final brightPaint = Paint()
          ..color = Colors.white.withValues(alpha: p.opacity * 0.4 * depthScale);
        canvas.drawCircle(Offset(x, y), particleSize * 0.4, brightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
