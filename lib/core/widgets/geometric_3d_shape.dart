import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A 3D rotating geometric shape rendered via CustomPainter.
/// Draws a rotating wireframe icosahedron-like structure with glowing edges.
class Geometric3DShape extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final bool autoRotate;

  const Geometric3DShape({
    super.key,
    this.size = 250,
    this.primaryColor = AppColors.cyanAccent,
    this.secondaryColor = AppColors.purpleAccent,
    this.autoRotate = true,
  });

  @override
  State<Geometric3DShape> createState() => _Geometric3DShapeState();
}

class _Geometric3DShapeState extends State<Geometric3DShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0.0;
  double _rotationY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateRotation(double dx, double dy) {
    setState(() {
      _rotationX += dy * 0.03;
      _rotationY += dx * 0.03;
    });
  }

  void resetRotation() {
    setState(() {
      _rotationX = 0;
      _rotationY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final size = context.size;
        if (size == null) return;
        final dx = (event.localPosition.dx / size.width - 0.5) * 2;
        final dy = (event.localPosition.dy / size.height - 0.5) * 2;
        updateRotation(dx, dy);
      },
      onExit: (_) => resetRotation(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final autoRotX = widget.autoRotate ? _controller.value * 2 * pi : 0.0;
          final autoRotY = widget.autoRotate ? _controller.value * pi : 0.0;

          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _GeometricPainter(
              rotationX: _rotationX + autoRotX,
              rotationY: _rotationY + autoRotY,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
              time: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _GeometricPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final Color primaryColor;
  final Color secondaryColor;
  final double time;

  _GeometricPainter({
    required this.rotationX,
    required this.rotationY,
    required this.primaryColor,
    required this.secondaryColor,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Generate vertices of a complex 3D shape (like a stellated icosahedron)
    final vertices = _generateVertices(radius, center);

    // Project 3D vertices to 2D
    final projected = vertices.map((v) => _project3D(v, center)).toList();

    // Sort by depth for proper painter order
    final indices = List.generate(projected.length, (i) => i);
    indices.sort((a, b) => projected[b].z.compareTo(projected[a].z));

    // Draw outer glow aura
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.06),
          secondaryColor.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 2));
    canvas.drawCircle(center, radius * 1.8, glowPaint);

    // Draw edges
    for (int i = 0; i < projected.length; i++) {
      for (int j = i + 1; j < projected.length; j++) {
        final p1 = projected[i];
        final p2 = projected[j];

        // Calculate distance between projected points
        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final dist = sqrt(dx * dx + dy * dy);

        // Only connect nearby vertices
        if (dist < radius * 1.2) {
          final depthFactor1 = (p1.z / radius + 1) / 2;
          final depthFactor2 = (p2.z / radius + 1) / 2;
          final avgDepth = (depthFactor1 + depthFactor2) / 2;

          // Interpolate color based on depth
          final edgeColor = Color.lerp(
            secondaryColor.withValues(alpha: 0.3 * avgDepth),
            primaryColor.withValues(alpha: 0.6 * avgDepth),
            avgDepth,
          )!;

          final edgePaint = Paint()
            ..color = edgeColor
            ..strokeWidth = 0.8 + avgDepth * 0.5;

          // Glow on edges
          if (avgDepth > 0.6) {
            final glowEdgePaint = Paint()
              ..color = edgeColor.withValues(alpha: 0.2)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
              ..strokeWidth = 2;
            canvas.drawLine(
              Offset(p1.x, p1.y),
              Offset(p2.x, p2.y),
              glowEdgePaint,
            );
          }

          canvas.drawLine(
            Offset(p1.x, p1.y),
            Offset(p2.x, p2.y),
            edgePaint,
          );
        }
      }
    }

    // Draw vertices
    for (var i in indices) {
      final p = projected[i];
      final depthFactor = (p.z / radius + 1) / 2;
      final vertexSize = 1.0 + depthFactor * 3;

      // Outer glow
      final glowVertexPaint = Paint()
        ..color = Color.lerp(
          secondaryColor.withValues(alpha: 0.1),
          primaryColor.withValues(alpha: 0.2),
          depthFactor,
        )!
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(p.x, p.y), vertexSize * 4, glowVertexPaint);

      // Core vertex
      final vertexPaint = Paint()
        ..color = Color.lerp(
          secondaryColor,
          primaryColor,
          depthFactor,
        )!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), vertexSize, vertexPaint);

      // Bright center
      if (depthFactor > 0.5) {
        final brightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.6 * depthFactor);
        canvas.drawCircle(Offset(p.x, p.y), vertexSize * 0.3, brightPaint);
      }
    }
  }

  List<_Vertex3D> _generateVertices(double radius, Offset center) {
    final vertices = <_Vertex3D>[];
    final t = (1 + sqrt(5)) / 2; // Golden ratio

    // Icosahedron base vertices
    final baseVertices = [
      _Vertex3D(-1, t, 0),
      _Vertex3D(1, t, 0),
      _Vertex3D(-1, -t, 0),
      _Vertex3D(1, -t, 0),
      _Vertex3D(0, -1, t),
      _Vertex3D(0, 1, t),
      _Vertex3D(0, -1, -t),
      _Vertex3D(0, 1, -t),
      _Vertex3D(t, 0, -1),
      _Vertex3D(t, 0, 1),
      _Vertex3D(-t, 0, -1),
      _Vertex3D(-t, 0, 1),
    ];

    // Normalize and scale
    for (var v in baseVertices) {
      final len = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
      // Add some pulsing animation to radius
      final pulseRadius = radius * (1 + sin(time * 3 + v.x) * 0.05);
      vertices.add(_Vertex3D(
        v.x / len * pulseRadius,
        v.y / len * pulseRadius,
        v.z / len * pulseRadius,
      ));
    }

    // Add mid-face vertices for more complexity
    for (int i = 0; i < 20; i++) {
      final angle1 = i * 2.3999;
      final angle2 = i * 1.309;
      final r = radius * 0.65;
      vertices.add(_Vertex3D(
        sin(angle1) * cos(angle2) * r,
        sin(angle1) * sin(angle2) * r,
        cos(angle1) * r + sin(time * 2 + i) * radius * 0.08,
      ));
    }

    return vertices;
  }

  _ProjectedPoint _project3D(_Vertex3D v, Offset center) {
    // Apply rotations
    final cosX = cos(rotationX);
    final sinX = sin(rotationX);
    final cosY = cos(rotationY);
    final sinY = sin(rotationY);

    // Rotate around Y axis first
    double x1 = v.x * cosY - v.z * sinY;
    double y1 = v.y;
    double z1 = v.x * sinY + v.z * cosY;

    // Then rotate around X axis
    double x2 = x1;
    double y2 = y1 * cosX - z1 * sinX;
    double z2 = y1 * sinX + z1 * cosX;

    // Perspective projection
    final perspective = 600 / (600 + z2);
    final px = center.dx + x2 * perspective;
    final py = center.dy + y2 * perspective;

    return _ProjectedPoint(px, py, z2);
  }

  @override
  bool shouldRepaint(_GeometricPainter oldDelegate) => true;
}

class _Vertex3D {
  final double x, y, z;
  _Vertex3D(this.x, this.y, this.z);
}

class _ProjectedPoint {
  final double x, y, z;
  _ProjectedPoint(this.x, this.y, this.z);
}
