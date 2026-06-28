import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_card.dart';
import 'hero_section.dart'; // For MaxWidthContainer

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
    final columns = isDesktop ? 3 : (size.width > 600 ? 2 : 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      width: double.infinity,
      color: Colors.transparent,
      child: MaxWidthContainer(
        maxWidth: 1200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            _buildSectionHeader(),
            const SizedBox(height: 48),

            // Categories Grid
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: isDesktop ? 0.8 : (size.width > 600 ? 0.85 : 0.95),
                  children: [
                    _buildSkillCategoryCard(
                      'MOBILE FRONTEND',
                      FontAwesomeIcons.mobileScreenButton,
                      AppColors.cyanAccent,
                      [
                        const _SkillInfo('Flutter Framework', 0.95),
                        const _SkillInfo('Dart Programming', 0.95),
                        const _SkillInfo('Reactive Programming', 0.88),
                        const _SkillInfo('Responsive UI/UX Layouts', 0.92),
                      ],
                    ),
                    _buildSkillCategoryCard(
                      'BACKEND SOLUTIONS',
                      FontAwesomeIcons.server,
                      AppColors.purpleAccent,
                      [
                        const _SkillInfo('C# / .NET Core', 0.80),
                        const _SkillInfo('Entity Framework Core', 0.75),
                        const _SkillInfo('REST API Architecture', 0.88),
                        const _SkillInfo('Identity & Authorization', 0.80),
                      ],
                    ),
                    _buildSkillCategoryCard(
                      'NATIVE & DATABASES',
                      FontAwesomeIcons.database,
                      Colors.white,
                      [
                        const _SkillInfo('Android Native Bindings', 0.70),
                        const _SkillInfo('SQL Server / SQLite', 0.78),
                        const _SkillInfo('State (Riverpod / Bloc)', 0.92),
                        const _SkillInfo('Firebase Integration', 0.85),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Section Header with glow lines
  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// TECHNICAL ARSENAL',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.cyanAccent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Skills & Capabilities',
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

  // Core skill capsule container
  Widget _buildSkillCategoryCard(
    String categoryTitle,
    FaIconData icon,
    Color glowColor,
    List<_SkillInfo> skills,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      glowColor: glowColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, color: glowColor, size: 24),
              const SizedBox(width: 12),
              Text(
                categoryTitle,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: skills.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final skill = skills[index];
                return _buildSkillProgressBar(skill.name, skill.percentage, glowColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Glowing visual master progress bar
  Widget _buildSkillProgressBar(String skillName, double percentage, Color glowColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skillName,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: glowColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Dark track background
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
            ),
            // Dynamic neon-glowing bar
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  height: 6,
                  width: constraints.maxWidth * percentage,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [
                        glowColor,
                        glowColor.withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                );
              },
            ).animate().shimmer(delay: 500.ms, duration: 1500.ms, color: Colors.white24),
          ],
        ),
      ],
    );
  }
}

// Simple data representation model for skills
class _SkillInfo {
  final String name;
  final double percentage;

  const _SkillInfo(this.name, this.percentage);
}
