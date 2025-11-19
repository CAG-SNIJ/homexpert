import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class HomepageFooter extends StatelessWidget {
  const HomepageFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _DesktopFooter();
              } else {
                return _MobileFooter();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _DesktopFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/homexpert_logo_white.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.white.withOpacity(0.35),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'HomeXpert is Malaysia\'s trusted property listing platform designed to help you discover, buy, or rent your dream property. From AI-powered search tools to verified agents, we simplify every step of your real estate journey.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      _SocialIcon(Icons.facebook),
                      SizedBox(width: 16),
                      _SocialIcon(Icons.play_circle_outline),
                      SizedBox(width: 16),
                      _SocialIcon(Icons.alternate_email),
                      SizedBox(width: 16),
                      _SocialIcon(Icons.camera_alt),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Quick Links',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16),
                  _FooterLink('Buy'),
                  _FooterLink('Rent'),
                  _FooterLink('New Project'),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Get In Touch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16),
                  _ContactInfo(Icons.location_on, '18, Gurney Dr, Georgetown,\n10250 George Town, Penang'),
                  SizedBox(height: 12),
                  _ContactInfo(Icons.phone, '+6017-584 7588'),
                  SizedBox(height: 12),
                  _ContactInfo(Icons.email, 'snijders143@gmail.com'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Divider(color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                _FooterLink('About', isSmall: true),
                SizedBox(width: 24),
                _FooterLink('Contact Us', isSmall: true),
                SizedBox(width: 24),
                _FooterLink('Privacy Policy', isSmall: true),
                SizedBox(width: 24),
                _FooterLink('Terms of Service', isSmall: true),
              ],
            ),
            Text(
              '© Copyright 2025 HomeXpert. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MobileFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/homexpert_logo_white.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 2,
          color: Colors.white.withOpacity(0.35),
        ),
        const SizedBox(height: 16),
        const Text(
          'HomeXpert is Malaysia\'s trusted property listing platform. Find your dream home with confidence.',
          style: TextStyle(fontSize: 14, color: Colors.white, height: 1.6),
        ),
        const SizedBox(height: 20),
        Row(
          children: const [
            _SocialIcon(Icons.facebook),
            SizedBox(width: 16),
            _SocialIcon(Icons.play_circle_outline),
            SizedBox(width: 16),
            _SocialIcon(Icons.alternate_email),
            SizedBox(width: 16),
            _SocialIcon(Icons.camera_alt),
          ],
        ),
        const SizedBox(height: 32),
        Divider(color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 24),
        const Text(
          'Quick Links',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        const _FooterLink('Buy'),
        const _FooterLink('Rent'),
        const _FooterLink('New Project'),
        const SizedBox(height: 24),
        const Text(
          'Get In Touch',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 14),
        const _ContactInfo(Icons.location_on, '18, Gurney Dr, Georgetown,\n10250 George Town, Penang'),
        const SizedBox(height: 12),
        const _ContactInfo(Icons.phone, '+6017-584 7588'),
        const SizedBox(height: 12),
        const _ContactInfo(Icons.email, 'snijders143@gmail.com'),
        const SizedBox(height: 32),
        Divider(color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 24),
        const _FooterLink('About', isSmall: true),
        const _FooterLink('Contact Us', isSmall: true),
        const _FooterLink('Privacy Policy', isSmall: true),
        const _FooterLink('Terms of Service', isSmall: true),
        const SizedBox(height: 24),
        const Text(
          '© Copyright 2025 HomeXpert. All rights reserved.',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;

  const _SocialIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final bool isSmall;

  const _FooterLink(this.text, {this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {},
        hoverColor: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 12 : 14,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactInfo(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

