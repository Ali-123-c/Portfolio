import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glow_button.dart';
import '../../../core/widgets/reveal_animation.dart';
import '../providers/portfolio_providers.dart';
import 'hero_section.dart'; // For MaxWidthContainer

class ProjectsSection extends ConsumerWidget {
  const ProjectsSection({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    final selectedFilter = ref.watch(projectFilterProvider);
    final projects = _getProjects().where((project) {
      if (selectedFilter == 'All') return true;
      return project.category == selectedFilter;
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      width: double.infinity,
      color: Colors.transparent,
      child: MaxWidthContainer(
        maxWidth: 1200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 40),
            _buildFilterChips(context, ref, selectedFilter),
            const SizedBox(height: 48),
            RevealAnimation(
              delayMilliseconds: 200,
              child: projects.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projects.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : (size.width > 600 ? 2 : 1),
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return _buildProjectCard(context, project);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// FEATURED PROJECTS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.cyanAccent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Real-World Applications',
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

  Widget _buildFilterChips(BuildContext context, WidgetRef ref, String activeFilter) {
    final categories = ['All', 'Android', 'Backend', 'Full-stack'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isActive = category == activeFilter;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              ref.read(projectFilterProvider.notifier).state = category;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.cyanAccent.withValues(alpha: 0.12) : AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isActive ? AppColors.cyanAccent : AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Text(
                category.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.cyanAccent : AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildProjectCard(BuildContext context, _ProjectData project) {
    return GlassCard(
      padding: EdgeInsets.zero,
      glowColor: project.glowColor,
      onTap: () => _openProjectDetailsModal(context, project),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Image / Banner
          Expanded(
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient with grid pattern
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        project.glowColor.withValues(alpha: 0.15),
                        AppColors.backgroundCard,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.glassBorder, width: 0.5),
                    ),
                  ),
                  child: Opacity(
                    opacity: 0.1,
                    child: GridPaper(
                      color: project.glowColor.withValues(alpha: 0.3),
                      interval: 40,
                      divisions: 1,
                      subdivisions: 1,
                    ),
                  ),
                ),
                // Real screenshot image OR icon fallback
                if (project.imagePath != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      project.imagePath!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => _buildIconFallback(project),
                    ),
                  )
                else
                  _buildIconFallback(project),
                // Gradient overlay at bottom for text contrast
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.backgroundCard.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details content
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: project.glowColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: project.glowColor.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              project.category.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: project.glowColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_outward,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tech tags
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: project.techTags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.glassBorder, width: 0.5),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconFallback(_ProjectData project) {
    return Center(
      child: FaIcon(
        project.icon,
        size: 40,
        color: project.glowColor.withValues(alpha: 0.7),
      ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 3.seconds, color: Colors.white12),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.code_off, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'No matching projects found.',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _openProjectDetailsModal(BuildContext context, _ProjectData project) {
    showDialog(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.85),
      builder: (context) {
        return Center(
          child: Container(
            width: 800,
            constraints: const BoxConstraints(maxHeight: 700),
            margin: const EdgeInsets.all(24),
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 24,
              borderColor: AppColors.glassBorder,
              glowColor: project.glowColor,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Text(
                    project.title.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: project.glowColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: project.glowColor,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          project.category.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: project.glowColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        project.longDescription,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildBlockQuote(
                        'THE TECHNICAL CHALLENGE',
                        project.challenge,
                        AppColors.purpleAccent,
                      ),
                      const SizedBox(height: 20),
                      _buildBlockQuote(
                        'THE DIGITAL SOLUTION',
                        project.solution,
                        AppColors.cyanAccent,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Wired Technologies',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: project.techTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.glassBorder, width: 0.8),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          GlowButton(
                            text: 'Main Repository',
                            icon: FontAwesomeIcons.github,
                            onPressed: () => _launchURL(project.githubUrl),
                          ),
                          const SizedBox(width: 16),
                          GlowButton(
                            text: 'Explore Code',
                            icon: FontAwesomeIcons.codeBranch,
                            isSecondary: true,
                            onPressed: () => _launchURL(project.githubUrl),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlockQuote(String title, String body, Color borderGlowColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderGlowColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: borderGlowColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<_ProjectData> _getProjects() {
    return [
      _ProjectData(
        title: 'Smart Expense Tracker & Finance Manager',
        category: 'Full-stack',
        description: 'Modern personal finance app with income/expense tracking, budget management, trend charts, PDF reports, and offline-first architecture.',
        longDescription: 'A modern, full-featured personal finance application built with Flutter and Firebase. Designed to help users manage their finances with intuitive budgeting tools, trend charts, and cloud synchronization. Features include income/expense tracking with categorization, monthly budget management with visual progress bars and alerts, spending trend and pie chart visualizations, multi-currency support, biometric login for security, PDF report generation and export, dark mode support, and offline-first architecture using Hive with Cloud Firestore sync.',
        challenge: 'Implementing reliable offline-first data synchronization between local Hive storage and Cloud Firestore without data conflicts or loss.',
        solution: 'Designed a synchronized queue system that caches writes locally when offline and replays them to Firestore once connectivity is restored, ensuring data integrity across sessions.',
        techTags: ['Flutter', 'Dart', 'Riverpod', 'Firebase', 'Cloud Firestore', 'Hive', 'fl_chart'],
        githubUrl: 'https://github.com/Ali-123-c/FINANCE_APP',
        icon: FontAwesomeIcons.wallet,
        glowColor: const Color(0xFF00E676), // Green for finance
      ),
      _ProjectData(
        title: 'Smart Blood & Emergency Donor Network',
        category: 'Full-stack',
        description: 'Flutter + Supabase mobile app connecting blood donors, patients, and hospitals with GPS discovery and real-time emergency alerts.',
        longDescription: 'A comprehensive Flutter-based mobile application connecting blood donors, patients, hospitals, and blood banks in real-time. Features include user authentication with email verification, role-based dashboards (Donor, Patient, Hospital, Admin), blood request system with priority levels, FCM-based push notifications, GPS-based nearby donor discovery within a radius, hospital and blood bank directory with maps and contact details, paginated donation history with achievements and levels, comprehensive admin panel for user management and approvals, Hive-powered offline caching for 6 data tables, smooth hero transitions, multi-language support (English, Hindi, Urdu), and dark mode. Built with 30+ routes following a feature-first architecture.',
        challenge: 'Building a real-time emergency notification system that can instantly alert nearby donors when a blood request is created, while maintaining reliable offline support.',
        solution: 'Leveraged Supabase Realtime subscriptions for instant push of blood requests to matching donors, Firebase Cloud Messaging for background notifications when the app is closed, and Hive local caching with a sync queue to ensure the app works seamlessly offline.',
        techTags: ['Flutter', 'Dart', 'Supabase', 'PostgreSQL', 'Riverpod', 'GoRouter', 'FCM', 'Hive', 'FlutterMap'],
        githubUrl: 'https://github.com/QADRI1212/BLOOD_DONATION',
        icon: FontAwesomeIcons.droplet,
        glowColor: const Color(0xFFE53935), // Red for blood
      ),
      _ProjectData(
        title: 'FieldOps Service Management',
        category: 'Full-stack',
        description: 'Cross-platform field service management with dual-role system, real-time notifications, and PostgreSQL Row Level Security.',
        longDescription: 'A comprehensive cross-platform field service management solution for assigning, tracking, and completing service requests with role-based access. Features include a dual-role system (Manager & Technician interfaces), create/assign/reassign service requests, strict workflow state machine (Pending to Completed), real-time notifications via FCM and Supabase Realtime, detailed service report submission, offline-first caching with Hive, and PostgreSQL Row Level Security for data isolation.',
        challenge: 'Implementing real-time job status synchronization between managers and technicians with offline support while enforcing strict role-based data privacy.',
        solution: 'Leveraged Supabase Realtime subscriptions for live job updates, Hive local caching for seamless offline resilience, and PostgreSQL RLS policies to isolate data access per role, ensuring each technician only sees their assigned jobs.',
        techTags: ['Flutter', 'Dart', 'Supabase', 'Riverpod', 'GoRouter', 'FCM', 'Hive', 'PostgreSQL'],
        githubUrl: 'https://github.com/Ali-123-c/-fieldops-app',
        icon: FontAwesomeIcons.wrench,
        glowColor: const Color(0xFF2196F3), // Blue for service
      ),
      _ProjectData(
        title: 'Lost & Found Campus Core (FYP)',
        category: 'Full-stack',
        description: 'Final Year Project — lost object tracking system with algorithmic matching, .NET 8 backend, and real-time notifications.',
        longDescription: 'A landmark Final Year Project (FYP) engineered to streamline lost object logging, automated algorithmic item matching, and unclaimed assets liquidation. Combines a responsive Flutter mobile client with a Clean Architecture .NET 8 Web API backend. Features include a Flutter mobile client for students and administrators, Clean Architecture .NET 8 Web API backend, SQL Server database with EF Core, automated algorithmic matching of lost & found items, real-time notifications for matches, and admin approval workflow for claim matches.',
        challenge: 'Restricting concurrent modifications and preventing dirty-reads/overwrites (e.g., multiple admins approving claim matches simultaneously) while ensuring instantaneous matching notifications.',
        solution: 'Implemented RowVersion concurrency token locking inside EF Core transactional pipelines, coupled with native provider states on the Flutter mobile client to guarantee strict lifecycle thread synchronization.',
        techTags: ['Flutter', 'Dart', '.NET 8', 'EF Core', 'SQL Server', 'C#', 'REST API'],
        githubUrl: 'https://github.com/Ali-123-c/LOST-AND-FOUND-APP-UNI-PROJECT',
        icon: FontAwesomeIcons.magnifyingGlass,
        glowColor: AppColors.purpleAccent,
      ),
    ];
  }
}

class _ProjectData {
  final String title;
  final String category;
  final String description;
  final String longDescription;
  final String challenge;
  final String solution;
  final List<String> techTags;
  final String githubUrl;
  final FaIconData icon;
  final Color glowColor;
  final String? imagePath;

  const _ProjectData({
    required this.title,
    required this.category,
    required this.description,
    required this.longDescription,
    required this.challenge,
    required this.solution,
    required this.techTags,
    required this.githubUrl,
    this.icon = FontAwesomeIcons.mobileScreen,
    this.glowColor = AppColors.cyanAccent,
    this.imagePath,
  });
}
