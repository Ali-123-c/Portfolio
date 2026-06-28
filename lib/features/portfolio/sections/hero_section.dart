import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/glow_button.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onExploreProjects;

  const HeroSection({
    super.key,
    required this.onExploreProjects,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
    // Keep it responsive but ensure enough height for Hero
    final sectionHeight = size.height < 700 ? 700.0 : size.height;

    return Container(
      height: isDesktop ? sectionHeight : null, // Wrap content on mobile!
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: isDesktop ? 0 : 140, // Push content down below floating AppBar on mobile
        bottom: isDesktop ? 0 : 60,
      ),
      alignment: Alignment.center,
      child: MaxWidthContainer(
        maxWidth: 1200,
        child: isDesktop 
            ? Row(
                children: [
                  Expanded(flex: 6, child: _buildTypography(context, true)),
                  Expanded(flex: 5, child: _build3DCanvas(context, true)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _build3DCanvas(context, false), // No Expanded on mobile!
                  const SizedBox(height: 32),
                  _buildTypography(context, false), // No Expanded on mobile!
                ],
              ),
      ),
    );
  }

  // Left Column - Text Details & Action Buttons
  Widget _buildTypography(BuildContext context, bool isDesktop) {
    final align = isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = isDesktop ? TextAlign.left : TextAlign.center;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: align,
      children: [
        // Glowing Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cyanAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.cyanAccent.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            'WELCOME TO MY SPACE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.cyanAccent,
              letterSpacing: 3,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
        
        const SizedBox(height: 24),
        
        // Large Name Header
        RichText(
          textAlign: textAlign,
          text: TextSpan(
            children: [
              TextSpan(
                text: "HI, I'M ",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 60 : 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: "ALI",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 60 : 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cyanAccent,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(
                      color: AppColors.cyanAccent.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
        
        const SizedBox(height: 12),
        
        // Title Subtitle
        Text(
          'Flutter Mobile Developer | Building Exceptional Android Experiences',
          textAlign: textAlign,
          style: GoogleFonts.spaceGrotesk(
            fontSize: isDesktop ? 22 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
        
        const SizedBox(height: 16),
        
        // Tagline description
        Text(
          'Focused on robust architectures, premium user interfaces, and modular backend integrations. Engineering elegant solutions with C# / .NET backend services and high-performance native Dart compilation.',
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 15 : 13,
            color: AppColors.textMuted,
            height: 1.6,
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
        
        const SizedBox(height: 36),
        
        // Action Buttons Row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          children: [
            GlowButton(
              text: 'Explore Projects',
              icon: FontAwesomeIcons.bolt,
              onPressed: onExploreProjects,
            ),
            GlowButton(
              text: 'Resume',
              icon: FontAwesomeIcons.download,
              isSecondary: true,
              onPressed: () {
                // Future implementation for file downloads or external URLs
              },
            ),
          ],
        ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
      ],
    );
  }

  // Right Column - Interactive 3D Avatar Canvas
  Widget _build3DCanvas(BuildContext context, bool isDesktop) {
    return _Interactive3DAvatarCanvas(isDesktop: isDesktop);
  }
}

// Interactive 3D Parallax Floating Avatar Canvas
class _Interactive3DAvatarCanvas extends StatefulWidget {
  final bool isDesktop;

  const _Interactive3DAvatarCanvas({required this.isDesktop});

  @override
  State<_Interactive3DAvatarCanvas> createState() => _Interactive3DAvatarCanvasState();
}

class _Interactive3DAvatarCanvasState extends State<_Interactive3DAvatarCanvas> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isHovered = false;

  void _onPointerMove(PointerEvent event) {
    if (!widget.isDesktop) return; // Only apply tilt on desktop cursor hover

    final size = context.size;
    if (size == null) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    setState(() {
      _tiltX = (event.localPosition.dy - centerY) / centerY * 0.12; // Dynamic 3D tilt X
      _tiltY = -(event.localPosition.dx - centerX) / centerX * 0.12; // Dynamic 3D tilt Y
    });
  }

  void _onPointerEnter(PointerEvent event) {
    setState(() {
      _isHovered = true;
    });
  }

  void _onPointerExit(PointerEvent event) {
    setState(() {
      _isHovered = false;
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double canvasSize = widget.isDesktop ? 380 : 250;
    final double avatarSize = widget.isDesktop ? 220 : 160;

    return MouseRegion(
      onEnter: _onPointerEnter,
      onExit: _onPointerExit,
      onHover: _onPointerMove,
      child: Center(
        child: AnimatedRotation(
          turns: _isHovered ? 0.015 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D Perspective Warp entry
              ..rotateX(_tiltX)
              ..rotateY(_tiltY),
            child: RepaintBoundary(
              child: Stack(
                alignment: Alignment.center,
                children: [
                // 1. Outer Neon Cyan Orbiting Ring
                Container(
                  width: canvasSize,
                  height: canvasSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cyanAccent.withValues(alpha: _isHovered ? 0.22 : 0.08),
                      width: 1.5,
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat()).rotate(duration: 25.seconds),

                // 2. Inner Neon Purple Orbiting Ring (Counter-rotating)
                Container(
                  width: canvasSize - 35,
                  height: canvasSize - 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.purpleAccent.withValues(alpha: _isHovered ? 0.16 : 0.06),
                      width: 1,
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat()).rotate(duration: 20.seconds, begin: 1.0, end: 0.0),

                // 3. Cyberpunk Radial Glow Backdrop
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: avatarSize + 25,
                  height: avatarSize + 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyanAccent.withValues(alpha: _isHovered ? 0.26 : 0.08),
                        blurRadius: _isHovered ? 40 : 25,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: AppColors.purpleAccent.withValues(alpha: _isHovered ? 0.18 : 0.04),
                        blurRadius: _isHovered ? 30 : 15,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),

                // 4. The 3D Floating Avatar Sphere
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cyanAccent, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyanAccent.withValues(alpha: 0.15),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/profile.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(begin: -8, end: 8, duration: 3.seconds, curve: Curves.easeInOut)
                .animate()
                .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

// Utility widget to enforce clean layout constraints
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidthContainer({
    super.key,
    required this.child,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
