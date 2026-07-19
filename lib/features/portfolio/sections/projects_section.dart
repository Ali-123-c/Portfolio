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

  // URL Launch Helper
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
            // Section Header
            _buildSectionHeader(),
            const SizedBox(height: 40),

            // Filter Chips Row
            _buildFilterChips(context, ref, selectedFilter),
            const SizedBox(height: 48),

            // Project Cards Grid
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

  // Section Header
  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// INTERNSHIP CREDENTIALS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.cyanAccent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selected Work & Projects',
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

  // Category Filter Chips Navigation Row
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

  // Individual Project card component
  Widget _buildProjectCard(BuildContext context, _ProjectData project) {
    return GlassCard(
      padding: EdgeInsets.zero,
      glowColor: project.category == 'Backend' ? AppColors.purpleAccent : AppColors.cyanAccent,
      onTap: () => _openProjectDetailsModal(context, project),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic Banner Placeholder (Futuristic layout)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: project.category == 'Backend'
                      ? [AppColors.darkPurple.withValues(alpha: 0.6), AppColors.backgroundCard]
                      : [AppColors.cyanAccent.withValues(alpha: 0.08), AppColors.backgroundCard],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: const Border(bottom: BorderSide(color: AppColors.glassBorder, width: 0.5)),
              ),
              child: RepaintBoundary(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Abstract geometric lines
                    Opacity(
                      opacity: 0.15,
                      child: GridPaper(
                        color: AppColors.cyanAccent.withValues(alpha: 0.3),
                        interval: 40,
                        divisions: 1,
                        subdivisions: 1,
                      ),
                    ),
                    FaIcon(
                      project.category == 'Backend' ? FontAwesomeIcons.terminal : FontAwesomeIcons.mobileScreen,
                      size: 44,
                      color: project.category == 'Backend' ? AppColors.purpleAccent : AppColors.cyanAccent,
                    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 3.seconds, color: Colors.white24),
                  ],
                ),
              ),
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
                          Text(
                            project.category.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: project.category == 'Backend' ? AppColors.purpleAccent : AppColors.cyanAccent,
                              letterSpacing: 2,
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
                          fontSize: 16,
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
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  
                  // Tech stacks tags list
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: project.techTags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.glassBorder, width: 0.5),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.inter(
                            fontSize: 9,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.code_off, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'No matching internship projects found.',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Multi-Screenshot, challenge & solution details modal overlay
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
              glowColor: project.category == 'Backend' ? AppColors.purpleAccent : AppColors.cyanAccent,
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
                      // Subtitle Category Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: project.category == 'Backend'
                              ? AppColors.purpleAccent.withValues(alpha: 0.12)
                              : AppColors.cyanAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: project.category == 'Backend' ? AppColors.purpleAccent : AppColors.cyanAccent,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          project.category.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: project.category == 'Backend' ? AppColors.purpleAccent : AppColors.cyanAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Full detailed description
                      Text(
                        project.longDescription,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Challenge & Solution Panel (Custom UI)
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
                      
                      // Tech Stack List
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
                      
                      // Action buttons: main repo, specific code branch
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

  // Block Quote helper container
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

  // Real projects based on actual internship and development experience
  List<_ProjectData> _getProjects() {
    return [
      const _ProjectData(
        title: 'AGI Field Operations Portal',
        category: 'Full-stack',
        description: 'Cross-platform mobile application built with Flutter and .NET Core backend for field operations management and data collection.',
        longDescription: 'Developed during the AGI internship as a cross-platform mobile solution that streamlines field operations. The Flutter frontend communicates with a .NET Core Web API backend for seamless data management and database operations. Features include real-time data synchronization, offline-capable forms for field data collection, role-based access control, and an admin dashboard for monitoring field activity. Built following clean architecture principles with a focus on performance optimization and code maintainability.',
        challenge: 'Ensuring reliable data synchronization between mobile clients and the .NET Core backend under inconsistent network conditions while maintaining data integrity across concurrent field operations.',
        solution: 'Implemented a robust retry-and-queue mechanism on the Flutter client that caches form submissions locally when offline and replays them to the .NET Core API once connectivity is restored, with SQL Server transaction guards preventing duplicate entries.',
        techTags: ['Flutter', 'Dart', '.NET Core', 'C#', 'REST API', 'SQL Server', 'EF Core'],
        githubUrl: 'https://github.com/Ali-123-c',
      ),
      const _ProjectData(
        title: 'TaskFlow Manager with FCM',
        category: 'Full-stack',
        description: 'Production-ready task management application refactored with Provider architecture and Firebase Cloud Messaging real-time notifications.',
        longDescription: 'A flagship internship project that refactored an existing Flutter codebase by implementing Provider state management architecture, reducing widget rebuild time by 25% and significantly improving app performance and maintainability. Integrated Firebase Cloud Messaging (FCM) for real-time push notifications, boosting user engagement by 20% and improving retention rates. Features include task scheduling, real-time status updates, Firestore cloud persistence, and offline state synchronization with background sync workers.',
        challenge: 'Refactoring a monolithic Flutter codebase into a clean Provider-driven architecture without breaking existing functionality while simultaneously integrating Firebase Cloud Messaging for background push notifications.',
        solution: 'Strategically decomposed the codebase into Provider-driven modules with dedicated ChangeNotifier classes, configured WorkManager hooks to handle FCM payloads on background threads, and used Firestore listeners to sync state across sessions.',
        techTags: ['Flutter', 'Dart', 'Provider', 'Firebase FCM', 'Cloud Firestore', 'WorkManager'],
        githubUrl: 'https://github.com/Ali-123-c',
      ),
      const _ProjectData(
        title: 'ShopCore REST API Backend',
        category: 'Backend',
        description: 'Scalable .NET Core Web API with ASP.NET MVC architecture, Entity Framework Core, and SQL Server for e-commerce operations.',
        longDescription: 'A robust backend API built with .NET Core and ASP.NET MVC following clean architecture and repository patterns. Features include complete CRUD operations for products, categories, orders, and users; JWT-based authentication with role-based authorization; middleware pipeline for request logging and error handling; Entity Framework Core with SQL Server for data persistence; and comprehensive input validation and API versioning. Designed with scalability in mind, the API supports pagination, filtering, and sorting for all list endpoints.',
        challenge: 'Designing a clean, maintainable backend architecture that separates concerns across layers while enforcing strict validation rules and providing comprehensive API documentation.',
        solution: 'Applied Repository Pattern with Unit of Work on top of Entity Framework Core, structured the solution into distinct layers (Controller, Service, Repository, Domain), and implemented FluentValidation rules with custom middleware for consistent error responses.',
        techTags: ['C#', '.NET Core', 'ASP.NET MVC', 'EF Core', 'SQL Server', 'JWT Auth', 'REST API'],
        githubUrl: 'https://github.com/Ali-123-c',
      ),
    ];
  }
}

// Data holder model for featured projects
class _ProjectData {
  final String title;
  final String category;
  final String description;
  final String longDescription;
  final String challenge;
  final String solution;
  final List<String> techTags;
  final String githubUrl;
  const _ProjectData({
    required this.title,
    required this.category,
    required this.description,
    required this.longDescription,
    required this.challenge,
    required this.solution,
    required this.techTags,
    required this.githubUrl,
  });
}
