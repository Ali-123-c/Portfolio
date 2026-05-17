import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_card.dart';
import 'hero_section.dart'; // For MaxWidthContainer

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
    final experiences = _getMockExperiences();

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
            const SizedBox(height: 56),

            // Timeline Tree
            isDesktop
                ? _buildDesktopTimeline(experiences)
                : _buildMobileTimeline(experiences),
          ],
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// CAREER CHRONOLOGY',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.cyanAccent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Experience & Journey',
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

  // Desktop alternating timeline (Left/Right items)
  Widget _buildDesktopTimeline(List<_ExperienceData> list) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Center Vertical Line
        Positioned(
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cyanAccent.withOpacity(0.4),
                  AppColors.purpleAccent.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        
        // Items list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final exp = list[index];
            final isLeft = index % 2 == 0;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                children: [
                  // Left side container (Card or Empty spacing)
                  Expanded(
                    child: isLeft
                        ? _buildCard(exp, true)
                        : const SizedBox(),
                  ),
                  
                  // Center glowing timeline node
                  _buildTimelineNode(isLeft),
                  
                  // Right side container (Card or Empty spacing)
                  Expanded(
                    child: !isLeft
                        ? _buildCard(exp, false)
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Mobile timeline (Aligned to the left)
  Widget _buildMobileTimeline(List<_ExperienceData> list) {
    return Stack(
      children: [
        // Left Aligned Vertical Line
        Positioned(
          top: 8,
          bottom: 8,
          left: 12,
          child: Container(
            width: 2,
            color: AppColors.cyanAccent.withOpacity(0.3),
          ),
        ),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final exp = list[index];
            return Padding(
              padding: const EdgeInsets.only(left: 36.0, bottom: 32.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Aligned mobile timeline node
                  Positioned(
                    left: -36,
                    top: 10,
                    child: _buildTimelineNode(true),
                  ),
                  _buildCard(exp, false),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // The Glassmorphic Alternating Card
  Widget _buildCard(_ExperienceData exp, bool isLeft) {
    final textTheme = GoogleFonts.spaceGrotesk(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AppColors.cyanAccent,
      letterSpacing: 2,
    );

    return Align(
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.92,
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          glowColor: isLeft ? AppColors.cyanAccent : AppColors.purpleAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period & Company Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(exp.period, style: textTheme),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.glassBorder, width: 0.5),
                    ),
                    child: Text(
                      exp.company.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Job Title
              Text(
                exp.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              
              // Summary bullet details
              ...exp.bulletPoints.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6.0, right: 10),
                        child: Icon(Icons.circle, size: 5, color: AppColors.purpleAccent),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0);
  }

  // Glowing timeline center dots
  Widget _buildTimelineNode(bool isLeft) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: isLeft ? AppColors.cyanAccent : AppColors.purpleAccent,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isLeft ? AppColors.cyanAccent.withOpacity(0.3) : AppColors.purpleAccent.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Mock Experience Data
  List<_ExperienceData> _getMockExperiences() {
    return [
      const _ExperienceData(
        title: 'Campus Lost & Found Core (FYP)',
        company: 'FULL-STACK CROWNING PROJECT',
        period: '2025 - PRESENT',
        bulletPoints: [
          'Engineered a complete university campus lost-and-found system, pairing a responsive Flutter student client with a .NET 8 backend Web API.',
          'Prevented dirty-reads/race conditions by implementing EF Core transactional pipelines with RowVersion optimistic concurrency locks.',
          'Structured Riverpod providers state management to validate student logins and fetch real-time matching notifications.',
        ],
      ),
      const _ExperienceData(
        title: 'Advanced Task Manager (FCM)',
        company: 'FULL-STACK INTERNSHIP PORTAL',
        period: '2025',
        bulletPoints: [
          'Developed and deployed multiple Flutter modules integrating Firebase Cloud Messaging (FCM) push notifications and real-time Firestore synchronization.',
          'Configured WorkManager background hooks to handle incoming FCM notification payloads on dedicated background threads.',
          'Created secured route guard gates and debounced input regex validators to authorize user access.',
        ],
      ),
      const _ExperienceData(
        title: 'Task Management SQLite Portal',
        company: 'OFFLINE-FIRST MOBILE CARD',
        period: '2025',
        bulletPoints: [
          'Wired local SQLite databases and SharedPreferences persistence models to ensure state stability offline across counter sessions.',
          'Built custom animated splash screens using dynamic MediaQueries and the flutter_animate engine, running at 60fps.',
        ],
      ),
      const _ExperienceData(
        title: 'REST API Client Integration',
        company: 'HIGH-THROUGHPUT API CLIENT',
        period: '2025',
        bulletPoints: [
          'Created API clients using the http module, incorporating automatic token refresh and custom header injectors.',
          'Moved heavy JSON payload deserialization to background compute isolates, preventing UI scrolling stutters on low-end handsets.',
        ],
      ),
    ];
  }
}

// Simple structural mapping model for experience
class _ExperienceData {
  final String title;
  final String company;
  final String period;
  final List<String> bulletPoints;

  const _ExperienceData({
    required this.title,
    required this.company,
    required this.period,
    required this.bulletPoints,
  });
}
