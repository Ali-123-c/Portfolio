import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_card.dart';
import 'hero_section.dart'; // For MaxWidthContainer

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      width: double.infinity,
      color: Colors.transparent,
      child: MaxWidthContainer(
        maxWidth: 1200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            _buildSectionHeader(),
            const SizedBox(height: 48),

            // Responsive Layout Grid
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _buildBioDescription(context)),
                      const SizedBox(width: 48),
                      Expanded(flex: 5, child: _buildMetricsGrid(context)),
                    ],
                  )
                : Column(
                    children: [
                      _buildBioDescription(context),
                      const SizedBox(height: 40),
                      _buildMetricsGrid(context),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // Neon-accented Section Header
  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// ABOUT ME',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.cyanAccent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Designing the Future of Mobile & Backend',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.cyanAccent, AppColors.purpleAccent],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
  }

  // Developer Biography Summary
  Widget _buildBioDescription(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cyanAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyanAccent.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/images/profile.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              'Who is Ali?',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          "I am a highly passionate Flutter Mobile Developer with a specialized focus on building premium Android architectures. Over the past year, I have dedicated myself to engineering digital products that combine beautiful, dynamic frontend animations with reliable, robust backend architectures.",
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text(
          "Beyond pixel-perfect mobile clients, I possess core expertise in backend services powered by C# and .NET Core. By bridging the gap between frontend state engines (using Riverpod or Bloc) and high-performance server APIs, I build unified full-stack systems that load fast and scale endlessly.",
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        
        // Highlights Checklist
        Align(
          alignment: isDesktop ? Alignment.centerLeft : Alignment.center,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
            children: [
              _buildTag('Flutter Core & Native bindings'),
              _buildTag('C# / .NET Core Web API'),
              _buildTag('Clean Architecture (MVVM)'),
              _buildTag('Performance Optimization'),
              _buildTag('Reactive State Management'),
              _buildTag('Android Native Bindings'),
            ],
          ),
        ),
      ],
    );
  }

  // Skill pill widgets with cyberpunk design elements
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.code, color: AppColors.purpleAccent, size: 14),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Grid showing portfolio numbers and accomplishments
  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard('1+', 'Years Experience', AppColors.cyanAccent),
        _buildMetricCard('7+', 'Completed Apps', AppColors.purpleAccent),
        _buildMetricCard('10+', 'REST APIs Designed', Colors.white),
        _buildMetricCard('100%', 'Production Success', AppColors.cyanAccent),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale();
  }

  // Custom high-tech Metric card utilizing Glassmorphic scaling
  Widget _buildMetricCard(String value, String label, Color highlightColor) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      glowColor: highlightColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: highlightColor,
              shadows: [
                Shadow(
                  color: highlightColor.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
