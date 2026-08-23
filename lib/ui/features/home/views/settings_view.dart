import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watersort/ui/core/theme/app_colors.dart';
import 'package:watersort/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final themeSpecs = _getThemeSpecs();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF222222),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingWhite,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    icon: Icons.timer_rounded,
                    title: 'GAMEPLAY TIMER',
                    description: 'Add a timer countdown to levels for a standard challenge, or keep it off to play relaxed.',
                    value: state.isTimerEnabled,
                    onTap: () => ref.read(homeViewModelProvider.notifier).toggleTimer(),
                  ),
                  _buildSettingTile(
                    icon: Icons.visibility_off_rounded,
                    title: 'SUPER HARD DIFFICULTY',
                    description: 'Only the topmost color of each tube is shown; all hidden segments below are turned pure white.',
                    value: state.isSuperHardModeEnabled,
                    onTap: () => ref.read(homeViewModelProvider.notifier).toggleSuperHardMode(),
                  ),
                  _buildSettingTile(
                    icon: Icons.blur_on_rounded,
                    title: 'COMPLETED TUBES VISUALS',
                    description: 'Frost completed tubes with a blurred liquid glass effect to easily focus on active tubes.',
                    value: state.isBlurSolvedTubesEnabled,
                    onTap: () => ref.read(homeViewModelProvider.notifier).toggleBlurSolvedTubes(),
                  ),
                  _buildSettingTile(
                    icon: Icons.motion_photos_off_rounded,
                    title: 'TURN OFF ANIMATIONS',
                    description: 'Disable all water pouring, animations, sound effects, waves, and visual effects for instant gameplay.',
                    value: state.isInstantPouringEnabled,
                    onTap: () => ref.read(homeViewModelProvider.notifier).toggleInstantPouring(),
                  ),
                  _buildSettingTile(
                    icon: state.isSoundEffectsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    title: 'SOUND EFFECTS',
                    description: 'Play realistic liquid pouring sound effects during moves. Automatically disabled when animations are turned off.',
                    value: state.isSoundEffectsEnabled,
                    isEnabled: !state.isInstantPouringEnabled,
                    onTap: () => ref.read(homeViewModelProvider.notifier).toggleSoundEffects(),
                  ),
                  _buildSettingTile(
                    icon: Icons.lightbulb_rounded,
                    title: 'HINT HELPER',
                    description: 'Show a hint button during gameplay to highlight the next optimal move.',
                    value: state.isHintHelperEnabled,
                    onTap: () => ref.read(homeViewModelProvider.notifier).toggleHintHelper(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF22222B),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.palette_rounded,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'THEME PALETTES',
                                    style: TextStyle(
                                      fontFamily: 'BebasNeue',
                                      fontSize: 16,
                                      color: AppColors.headingWhite,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Choose a color palette to customize backgrounds, accents, and tube liquid colors.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.subtext,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: ThemePack.values.map((theme) {
                              final spec = themeSpecs[theme]!;
                              final isSelected = state.activeTheme == theme;

                              return GestureDetector(
                                onTap: () => ref.read(homeViewModelProvider.notifier).setThemePack(theme),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: spec.bg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? spec.accent : const Color(0xFF33333E),
                                      width: isSelected ? 2.5 : 1.5,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: spec.accent.withValues(alpha: 0.45),
                                          blurRadius: 10,
                                          spreadRadius: 1.5,
                                        ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isSelected
                                        ? Icon(
                                            Icons.check_rounded,
                                            color: spec.accent,
                                            size: 24,
                                          )
                                        : Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: spec.accent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse('https://github.com/sidhant947/water-sort');
                      try {
                        final launched =
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                        if (!launched) debugPrint('Could not launch $url');
                      } catch (e) {
                        debugPrint('Could not launch $url: $e');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF22222B),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bug_report_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'REPORT BUGS / SUGGESTIONS',
                                  style: TextStyle(
                                    fontFamily: 'BebasNeue',
                                    fontSize: 16,
                                    color: AppColors.headingWhite,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Open the GitHub repository to report issues or suggest improvements directly.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.subtext,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.open_in_new_rounded,
                            color: AppColors.subtext,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.38,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16161B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF22222B),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (value && isEnabled) ? AppColors.accent.withValues(alpha: 0.1) : const Color(0xFF202026),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: (value && isEnabled) ? AppColors.accent : AppColors.subtext,
                size: 20,
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
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _PremiumSwitch(
              value: value,
              onTap: isEnabled ? onTap : () {},
            ),
          ],
        ),
      ),
    );
  }

  Map<ThemePack, _ThemeSpec> _getThemeSpecs() {
    return {
      ThemePack.midnight: const _ThemeSpec(
        bg: Color(0xFF121212),
        accent: Color(0xFF86EF4D),
      ),
      ThemePack.cyberpunk: const _ThemeSpec(
        bg: Color(0xFF0F0B1E),
        accent: Color(0xFFFF007F),
      ),
      ThemePack.forest: const _ThemeSpec(
        bg: Color(0xFF0D140F),
        accent: Color(0xFF50C878),
      ),
      ThemePack.space: const _ThemeSpec(
        bg: Color(0xFF090A15),
        accent: Color(0xFFBD93F9),
      ),
      ThemePack.retro: const _ThemeSpec(
        bg: Color(0xFF17130E),
        accent: Color(0xFFFFB86C),
      ),
      ThemePack.sunset: const _ThemeSpec(
        bg: Color(0xFF1E0E25),
        accent: Color(0xFFF9844A),
      ),
      ThemePack.neon: const _ThemeSpec(
        bg: Color(0xFF050505),
        accent: Color(0xFF39FF14),
      ),
      ThemePack.ocean: const _ThemeSpec(
        bg: Color(0xFF0A192F),
        accent: Color(0xFF00D2FF),
      ),
      ThemePack.volcano: const _ThemeSpec(
        bg: Color(0xFF1A0A0A),
        accent: Color(0xFFFF4500),
      ),
      ThemePack.aurora: const _ThemeSpec(
        bg: Color(0xFF0B1B1E),
        accent: Color(0xFF00FFCC),
      ),
      ThemePack.lavender: const _ThemeSpec(
        bg: Color(0xFF15101F),
        accent: Color(0xFFE0B0FF),
      ),
      ThemePack.desert: const _ThemeSpec(
        bg: Color(0xFF221A0F),
        accent: Color(0xFFE6C229),
      ),
      ThemePack.glitch: const _ThemeSpec(
        bg: Color(0xFF0D0208),
        accent: Color(0xFF00FF00),
      ),
      ThemePack.sakura: const _ThemeSpec(
        bg: Color(0xFF261820),
        accent: Color(0xFFFFB7C5),
      ),
      ThemePack.monochrome: const _ThemeSpec(
        bg: Color(0xFF1A1A1A),
        accent: Color(0xFFE0E0E0),
      ),
      ThemePack.aquamarine: const _ThemeSpec(
        bg: Color(0xFF081C15),
        accent: Color(0xFF7FFFD4),
      ),
      ThemePack.solar: const _ThemeSpec(
        bg: Color(0xFF200F00),
        accent: Color(0xFFFFCC00),
      ),
    };
  }
}

class _ThemeSpec {
  final Color bg;
  final Color accent;
  const _ThemeSpec({
    required this.bg,
    required this.accent,
  });
}

class _PremiumSwitch extends StatelessWidget {
  const _PremiumSwitch({
    required this.value,
    required this.onTap,
  });

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? AppColors.accent.withValues(alpha: 0.15) : const Color(0xFF1E1E24),
          border: Border.all(
            color: value ? AppColors.accent : const Color(0xFF33333C),
            width: 1.5,
          ),
          boxShadow: [
            if (value)
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? AppColors.accent : const Color(0xFF888896),
                    boxShadow: [
                      if (value)
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 0.5,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
