import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watersort/ui/core/theme/app_colors.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.0),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.headingWhite,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'SUPPORT',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingWhite,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.volunteer_activism_rounded,
                              color: AppColors.accent,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'KEEP IT COZY & AD-FREE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.headingWhite,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Water Sort is 100% free, open-source, and has absolutely zero ads or tracking. Keeping the game continuously polished and ad-free takes dedicated time and resources.\n\nIf the sorting puzzles bring you a sense of relaxation or joy, please consider backing development to keep the game alive and cozy!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.subtext,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'HOW TO SUPPORT',
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 16,
                        color: AppColors.subtext,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInteractiveCard(
                      title: 'TIP ONE TIME ON KO-FI',
                      description: 'Quickly buy a coffee or fuel a coding session. Simple, secure, instant, and directly supports the project.',
                      icon: Icons.coffee_rounded,
                      color: const Color(0xFFFF5E5B),
                      actionText: 'TIP VIA KO-FI',
                      onTap: () => _launchUrl('https://ko-fi.com/sidhant947'),
                    ),
                    const SizedBox(height: 16),
                    _buildInteractiveCard(
                      title: 'BECOME A CONSISTENT BACKER',
                      description: 'Sustainable recurring pledges (weekly or monthly) to support continuous updates and further development.',
                      icon: Icons.autorenew_rounded,
                      color: const Color(0xFF00B4D8),
                      actionText: 'SPONSOR ON LIBERAPAY',
                      onTap: () => _launchUrl('https://liberapay.com/sidhant947'),
                    ),
                    const SizedBox(height: 16),
                    _buildInteractiveCard(
                      title: 'STAR THE REPOSITORY',
                      description: 'Show your appreciation for free by starring the open-source repository on GitHub. It boosts project visibility!',
                      icon: Icons.star_rounded,
                      color: const Color(0xFFF9C74F),
                      actionText: 'STAR ON GITHUB',
                      onTap: () => _launchUrl('https://github.com/sidhant947/water-sort'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white10,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 16,
                            color: AppColors.headingWhite,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.subtext,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: color.withValues(alpha: 0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      actionText,
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: color,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
