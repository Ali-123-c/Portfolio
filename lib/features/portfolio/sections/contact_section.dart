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

class ContactSection extends ConsumerStatefulWidget {
  const ContactSection({super.key});

  @override
  ConsumerState<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends ConsumerState<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Simple Email Regex check
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Trigger submission to C# API or Launch Email
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(contactFormStatusProvider.notifier);
    notifier.setStatus(ContactFormStatus.loading);

    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'hali49537@gmail.com',
        queryParameters: {
          'subject': 'Portfolio Inquiry from ${_nameController.text.trim()}',
          'body': 'Hi Ali,\n\n${_messageController.text.trim()}\n\nBest regards,\n${_nameController.text.trim()}\nEmail: ${_emailController.text.trim()}',
        },
      );

      // Launch mail composer
      await launchUrl(emailLaunchUri);

      // Transition to success screen
      notifier.setStatus(ContactFormStatus.success);
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (e) {
      notifier.setStatus(ContactFormStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    final formStatus = ref.watch(contactFormStatusProvider);

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

            // Responsive Layout (Form on Left/Right, Social details adjacent)
            RevealAnimation(
              delayMilliseconds: 200,
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildFormCard(formStatus)),
                        const SizedBox(width: 56),
                        Expanded(flex: 5, child: _buildDirectDetails(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildFormCard(formStatus),
                        const SizedBox(height: 48),
                        _buildDirectDetails(context),
                      ],
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
          '// INBOUND PIPELINE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.cyanAccent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Get in Touch',
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

  // Interactive Form Widget container wrapped in Glassmorphism
  Widget _buildFormCard(ContactFormStatus status) {
    if (status == ContactFormStatus.success) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        glowColor: AppColors.cyanAccent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing success checkmark
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cyanAccent, width: 2),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.cyanAccent,
                  size: 36,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'TRANSMISSION SUCCESSFUL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for reaching out! Ali will get back to you shortly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              GlowButton(
                text: 'Send Another Message',
                isSecondary: true,
                onPressed: () =>
                    ref.read(contactFormStatusProvider.notifier).reset(),
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(32),
      glowColor: AppColors.cyanAccent,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRANSMIT AN ENQUIRY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameController,
              enabled: status != ContactFormStatus.loading,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person_outline, size: 18),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Name is required.';
                }
                if (val.trim().length < 3) {
                  return 'Must be at least 3 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Email Field
            TextFormField(
              controller: _emailController,
              enabled: status != ContactFormStatus.loading,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.mail_outline, size: 18),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Email is required.';
                }
                if (!_isValidEmail(val.trim())) {
                  return 'Please enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Message Field
            TextFormField(
              controller: _messageController,
              enabled: status != ContactFormStatus.loading,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Type your message...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 80.0),
                  child: Icon(Icons.chat_bubble_outline, size: 18),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Message is required.';
                }
                if (val.trim().length < 10) {
                  return 'Must be at least 10 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Buttons
            status == ContactFormStatus.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.cyanAccent,
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: GlowButton(
                      text: 'Initiate Transfer',
                      icon: FontAwesomeIcons.paperPlane,
                      onPressed: _submitForm,
                    ),
                  ),

            if (status == ContactFormStatus.error) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'TRANSMISSION FAILED. PLEASE TRY AGAIN.',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Right details: social handles, direct email
  Widget _buildDirectDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direct Connections',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Looking for a futuristic Android product developer or scalable .NET API service patterns? Let\'s sync coordinates and discuss how we can build high-performance systems.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),

        // Detail components
        _buildInfoRow(
          Icons.email_outlined,
          'EMAIL',
          'hali49537@gmail.com',
          onTap: () async {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'hali49537@gmail.com',
            );
            await launchUrl(emailLaunchUri);
          },
        ),
        const SizedBox(height: 20),
        _buildInfoRow(
          Icons.location_on_outlined,
          'BASE COORDINATES',
          'Pakistan, Islamabad / Rawalpindi',
        ),
        const SizedBox(height: 20),
        _buildInfoRow(
          Icons.wifi_tethering_outlined,
          'AVAILABILITY',
          'Freelance & Permanent Collaborations',
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    Widget content = Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.glassBorder, width: 0.8),
          ),
          child: Icon(icon, color: AppColors.cyanAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onTap != null ? AppColors.cyanAccent : Colors.white70,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ],
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return content;
  }
}
