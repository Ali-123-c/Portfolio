import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/particle_background.dart';
import '../../../core/widgets/scroll_to_top_button.dart';
import '../providers/portfolio_providers.dart';

// Section widgets import
import '../sections/hero_section.dart';
import '../sections/about_section.dart';
import '../sections/skills_section.dart';
import '../sections/projects_section.dart';
import '../sections/experience_section.dart';
import '../sections/contact_section.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final ScrollController _scrollController = ScrollController();

  // Setup Global Keys for each section to measure coordinates for scroll-snaps
  final Map<String, GlobalKey> _sectionKeys = {
    'home': GlobalKey(),
    'about': GlobalKey(),
    'skills': GlobalKey(),
    'projects': GlobalKey(),
    'experience': GlobalKey(),
    'contact': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // Scroll tracking algorithm to highlight the correct navbar button
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    String currentSection = 'home';
    double minDistance = double.infinity;

    for (var entry in _sectionKeys.entries) {
      final key = entry.value;
      final sectionName = entry.key;
      final context = key.currentContext;

      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          final distance = position.dy.abs();

          if (position.dy <= 300 && distance < minDistance) {
            minDistance = distance;
            currentSection = sectionName;
          }
        }
      }
    }

    if (ref.read(activeSectionProvider) != currentSection) {
      ref.read(activeSectionProvider.notifier).state = currentSection;
    }
  }

  void _scrollToContact() {
    _scrollToSection('contact');
  }

  void _scrollToSection(String sectionName) {
    final key = _sectionKeys[sectionName];
    if (key == null) return;

    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _downloadCV() async {
    final Uri url = Uri.parse('assets/documents/Ali Haider.pdf');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSection = ref.watch(activeSectionProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      drawer: isMobile ? _buildMobileDrawer(activeSection) : null,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: _buildStickyNavbar(activeSection, isMobile),
      ),
      body: Stack(
        children: [
          ParticleBackground(
            enableParallax: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  HeroSection(
                    key: _sectionKeys['home'],
                    onExploreProjects: () => _scrollToSection('projects'),
                    onResumePressed: _downloadCV,
                    onHireMe: _scrollToContact,
                  ),
                  AboutSection(key: _sectionKeys['about']),
                  SkillsSection(key: _sectionKeys['skills']),
                  ProjectsSection(key: _sectionKeys['projects']),
                  ExperienceSection(key: _sectionKeys['experience']),
                  ContactSection(key: _sectionKeys['contact']),
                  _buildFooter(),
                ],
              ),
            ),
          ),
          // Floating Back to Top button
          Positioned(
            right: 24,
            bottom: 32,
            child: ScrollToTopButton(scrollController: _scrollController),
          ),
        ],
      ),
    );
  }

  // Floating Glass Capsule Navigation Bar
  Widget _buildStickyNavbar(String activeSection, bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        borderRadius: 20,
        borderColor: AppColors.glassBorder,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _scrollToSection('home'),
                child: Row(
                  children: [
                    Text(
                      'ALI',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      '.DEV',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cyanAccent,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isMobile)
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavLink('HOME', activeSection == 'home', () => _scrollToSection('home')),
                  const SizedBox(width: 24),
                  _buildNavLink('ABOUT', activeSection == 'about', () => _scrollToSection('about')),
                  const SizedBox(width: 24),
                  _buildNavLink('SKILLS', activeSection == 'skills', () => _scrollToSection('skills')),
                  const SizedBox(width: 24),
                  _buildNavLink('PROJECTS', activeSection == 'projects', () => _scrollToSection('projects')),
                  const SizedBox(width: 24),
                  _buildNavLink('TIMELINE', activeSection == 'experience', () => _scrollToSection('experience')),
                  const SizedBox(width: 24),
                  _buildNavLink('CONTACT', activeSection == 'contact', () => _scrollToSection('contact')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(String text, bool isActive, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isActive ? AppColors.cyanAccent.withValues(alpha: 0.12) : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.cyanAccent.withValues(alpha: 0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.cyanAccent : Colors.white70,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(String activeSection) {
    return Drawer(
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.glassBorder, width: 1)),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.glassBorder, width: 0.5)),
              ),
              child: Center(
                child: Text(
                  'NAVIGATION',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cyanAccent,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildDrawerItem('HOME', activeSection == 'home', () {
                    Navigator.pop(context);
                    _scrollToSection('home');
                  }),
                  _buildDrawerItem('ABOUT', activeSection == 'about', () {
                    Navigator.pop(context);
                    _scrollToSection('about');
                  }),
                  _buildDrawerItem('SKILLS', activeSection == 'skills', () {
                    Navigator.pop(context);
                    _scrollToSection('skills');
                  }),
                  _buildDrawerItem('PROJECTS', activeSection == 'projects', () {
                    Navigator.pop(context);
                    _scrollToSection('projects');
                  }),
                  _buildDrawerItem('TIMELINE', activeSection == 'experience', () {
                    Navigator.pop(context);
                    _scrollToSection('experience');
                  }),
                  _buildDrawerItem('CONTACT', activeSection == 'contact', () {
                    Navigator.pop(context);
                    _scrollToSection('contact');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String text, bool isActive, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? AppColors.cyanAccent.withValues(alpha: 0.08) : Colors.transparent,
        title: Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.cyanAccent : Colors.white70,
            letterSpacing: 3,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: isActive ? AppColors.cyanAccent : Colors.white30,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github, color: AppColors.textSecondary, size: 20),
                  onPressed: () => _launchURL('https://github.com/Ali-123-c'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.linkedinIn, color: AppColors.textSecondary, size: 20),
                  onPressed: () => _launchURL('https://www.linkedin.com/in/ali-haider-2172823a7'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '© ${DateTime.now().year} Ali. All rights reserved.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Designed & Engineered with Futuristic Flutter Web',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: AppColors.cyanAccent.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
