import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glow_button.dart';
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
    final projects = _getMockProjects().where((project) {
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
            projects.isEmpty
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
                            text: project.secondaryText ?? 'Explore Code',
                            icon: FontAwesomeIcons.codeBranch,
                            isSecondary: true,
                            onPressed: () => _launchURL(project.secondaryUrl ?? project.githubUrl),
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

  // Data generator mapping internship and university creations from the repository
  List<_ProjectData> _getMockProjects() {
    return [
      const _ProjectData(
        title: 'Smart Expense Tracker & Finance Manager',
        category: 'Full-stack',
        description: 'A modern expense tracker with budgeting tools, trend charts, and cloud sync — inspired by Money Manager and Spendee.',
        longDescription: 'A full-featured personal finance application built with Flutter and Firebase. Supports income/expense tracking with categorization, monthly budget management with visual progress bars and alerts, spending trend charts, pie chart visualizations, multi-currency support, biometric login, PDF report generation and export, dark mode, and offline-first architecture using Hive with Firebase Cloud Firestore synchronization.',
        challenge: 'Implementing reliable offline-first data synchronization between local Hive storage and Cloud Firestore without data conflicts or loss.',
        solution: 'Designed a synchronized queue system that caches writes locally when offline and replays them to Firestore once connectivity is restored, ensuring data integrity across sessions.',
        techTags: ['Flutter', 'Dart', 'Riverpod', 'Firebase Auth', 'Cloud Firestore', 'Hive', 'fl_chart', 'PDF Gen'],
        githubUrl: 'https://github.com/Ali-123-c/FINANCE_APP',
      ),
      const _ProjectData(
        title: 'FieldOps Service Management',
        category: 'Full-stack',
        description: 'A cross-platform field service management app for assigning, tracking, and completing service requests with role-based access.',
        longDescription: 'A comprehensive field service management solution built with Flutter and Supabase. Features a dual-role system with distinct Manager and Technician interfaces. Managers can create service requests, assign/reassign jobs to technicians, and oversee the entire team. Technicians can accept or reject jobs, update status through a strict workflow (Pending → Accepted → In Progress → Completed), and submit detailed service reports. Includes real-time notifications via FCM and Supabase Realtime subscriptions, offline-first caching with Hive, and PostgreSQL Row Level Security for data isolation between roles.',
        challenge: 'Implementing real-time job status synchronization between managers and technicians with offline support while enforcing strict role-based data privacy.',
        solution: 'Leveraged Supabase Realtime subscriptions for live job updates, Hive local caching for seamless offline resilience, and PostgreSQL RLS policies to isolate data access per role, ensuring each technician only sees their assigned jobs.',
        techTags: ['Flutter', 'Dart', 'Supabase', 'Riverpod', 'GoRouter', 'FCM', 'Hive', 'PostgreSQL'],
        githubUrl: 'https://github.com/Ali-123-c/-fieldops-app',
      ),
      const _ProjectData(
        title: 'GymFlow Management System',
        category: 'Full-stack',
        description: 'A comprehensive gym management system with fingerprint attendance tracking, member management, and payment processing.',
        longDescription: 'GymFlow is a robust, full-stack gym management solution built with Next.js 15, TypeScript, and Supabase. It offers a complete suite of tools for gym administrators including member management, real-time attendance tracking via USB fingerprint integration, and payment processing. The system features a responsive dashboard providing an overview of total members, daily attendance, pending fees, and revenue.',
        challenge: 'Integrating a local hardware device (USB fingerprint scanner) with a modern web application for seamless attendance logging.',
        solution: 'Developed a local Python application that interfaces with the biometric scanner and communicates with the Next.js API routes, transmitting scan data to the Supabase backend in real-time.',
        techTags: ['Next.js 15', 'TypeScript', 'Supabase', 'Tailwind CSS', 'Python', 'Biometrics'],
        githubUrl: 'https://github.com/Ali-123-c/RockHardGym',
      ),
      const _ProjectData(
        title: 'Lost & Found Campus Core (FYP)',
        category: 'Full-stack',
        description: 'Flagship Final Year Project combining a Flutter mobile client with a Clean Architecture .NET 8 backend ecosystem.',
        longDescription: 'A landmark university Final Year Project (FYP) engineered to streamline lost object logging, automated algorithmic item matching, and unclaimed assets liquidation. Consists of a responsive Flutter mobile client for students and administrators, backed by a Clean Architecture .NET 8 Web API server coordinating SQL Server storage.',
        challenge: 'Restricting concurrent modifications and preventing dirty-reads/overwrites (e.g. multiple admins approving claim matches simultaneously) while ensuring instantaneous matching notifications.',
        solution: 'Implemented RowVersion concurrency token locking inside EF Core transactional pipelines, coupled with native provider states on the Flutter mobile client to guarantee strict lifecycle thread synchronization.',
        techTags: ['Flutter', 'Dart', '.NET 8 Core', 'EF Core', 'SQL Server', 'Clean Architecture', 'Algorithmic Matching'],
        githubUrl: 'https://github.com/Ali-123-c/LOST-AND-FOUND-APP-UNI-PROJECT',
        secondaryUrl: 'https://github.com/Ali-123-c/LOST-AND-FOUND-APP-UNI-PROJECT/tree/main/Frontend',
        secondaryText: 'Explore Frontend',
      ),
      const _ProjectData(
        title: 'Advanced Task Manager (FCM)',
        category: 'Full-stack',
        description: 'Resilient task scheduler integrating Firebase Cloud Messaging (FCM), push alerts, and Firestore persistence.',
        longDescription: 'Developed as a flagship capstone project during the internship program. This application orchestrates real-time task notifications using Firebase Cloud Messaging (FCM) backplanes, Firestore cloud databases, and offline state synchronization. Allows users to schedule, update, and receive immediate alerts for task status modifications.',
        challenge: 'Implementing background sync workers that coordinate push message receipts and update local databases seamlessly without draining the device\'s battery resources.',
        solution: 'Configured WorkManager hooks and streams that handle incoming FCM notification payloads on dedicated background threads, updating state providers dynamically.',
        techTags: ['Flutter', 'Dart', 'Firebase FCM', 'Cloud Firestore', 'Riverpod', 'Android SDK'],
        githubUrl: 'https://github.com/Ali-123-c/complete_code/tree/main/complete_code/final_project_2',
      ),
      const _ProjectData(
        title: 'Cloud Auth & Firestore DB',
        category: 'Backend',
        description: 'Secure personal authentication pipeline wired to real-time Firestore database cloud synchronization hooks.',
        longDescription: 'A cloud-connected security module leveraging Firebase Auth protocols (supporting email/password and secure tokens validation) paired with a real-time data storage backend in Cloud Firestore. Features automatic authentication state detection and real-time document listeners.',
        challenge: 'Restricting cloud database reads and writes to authenticated owners while preserving low-latency synchronization.',
        solution: 'Authored structured Firebase Security Rules validating user ID tokens on each document path, backed by local offline persistence queries.',
        techTags: ['Flutter', 'Dart', 'Firebase Auth', 'Cloud Firestore', 'Security Rules'],
        githubUrl: 'https://github.com/Ali-123-c/complete_code/tree/main/task_5',
      ),
      const _ProjectData(
        title: 'REST API Client Integration',
        category: 'Backend',
        description: 'High-throughput API integrator querying RESTful service points with custom JSON serializers.',
        longDescription: 'An API client integration pipeline engineered using the Dart http module. Implements custom request intercepts, automated token refresh logic, robust JSON serialization structures, and state-driven loaders to display fetched datasets in responsive list grids.',
        challenge: 'Preventing UI threads from freezing during large JSON deserialization tasks on lower-end mobile handsets.',
        solution: 'Moved high-payload serialization workflows to background threads using Flutter\'s compute isolates, ensuring a continuous 60fps scrolling experience.',
        techTags: ['Flutter', 'Dart', 'HTTP REST API', 'JSON Serialization', 'Isolates', 'State Notifier'],
        githubUrl: 'https://github.com/Ali-123-c/complete_code/tree/main/task_4',
      ),
      const _ProjectData(
        title: 'Task Management CRUD Portal',
        category: 'Android',
        description: 'Feature-rich personal planner supporting local SQLite persistence, screen transitions, and splash gates.',
        longDescription: 'An offline-first personal scheduler application designed during the internship core. Features custom animated splash gates, intuitive task categorization grids, full Create-Read-Update-Delete (CRUD) functions, and robust SQLite/SharedPreferences storage rules to maintain state across reboots.',
        challenge: 'Building fluid custom animations for the landing splash screen that scale gracefully on tablets and standard phones alike.',
        solution: 'Utilized Flutter\'s custom painters and the flutter_animate engine, configuring layout grids using dynamic MediaQueries.',
        techTags: ['Flutter', 'Dart', 'SQLite', 'SharedPreferences', 'Custom Splash'],
        githubUrl: 'https://github.com/Ali-123-c/complete_code/tree/main/final_project',
      ),
      const _ProjectData(
        title: 'State & Local Storage Portal',
        category: 'Android',
        description: 'Resilient persistence portal integrating counter sessions and checklist schedulers utilizing SharedPreferences.',
        longDescription: 'An Android-optimized utility designed to demonstrate state tracking and local storage architectures. Implements session management and lightweight checklist schedulers backed by asynchronous SharedPreferences caching.',
        challenge: 'Maintaining reactive state bindings when updating counter values from nested, deep-tree widgets.',
        solution: 'Implemented Riverpod notifier hooks to track local values, triggering asynchronous writes to disk off the main thread.',
        techTags: ['Flutter', 'Dart', 'SharedPreferences', 'Riverpod', 'State Persistence'],
        githubUrl: 'https://github.com/Ali-123-c/complete_code/tree/main/task_2',
      ),
      const _ProjectData(
        title: 'Interactive Secure Gate',
        category: 'Android',
        description: 'Authenticating interface featuring validation forms, secure state caches, and navigation routes.',
        longDescription: 'A production-ready onboarding interface built to demonstrate strict input validation rules. Employs comprehensive form validators, custom keyboard listeners, and secure route guard gates to filter incoming user access.',
        challenge: 'Creating smooth, non-blocking UI validations for complex email/password patterns in real-time.',
        solution: 'Implemented asynchronous streams that debounce keystrokes, executing regex validation rules only when typing pauses.',
        techTags: ['Flutter', 'Dart', 'Form Validation', 'Route Guards', 'Streams'],
        githubUrl: 'https://github.com/Ali-123-c/complete_code/tree/main/task_1',
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
  final String? secondaryUrl;
  final String? secondaryText;

  const _ProjectData({
    required this.title,
    required this.category,
    required this.description,
    required this.longDescription,
    required this.challenge,
    required this.solution,
    required this.techTags,
    required this.githubUrl,
    this.secondaryUrl,
    this.secondaryText,
  });
}
