import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    description: 'Disable all water pouring, waves, bubbles, and visual effects for 100% static gameplay.',
                    value: state.isInstantPouringEnabled,
                    onTap: () => ref.read(homeViewModelProvider.notifier).toggleInstantPouring(),
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
                                color: AppColors.accent.withOpacity(0.1),
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
                                    'THEME PACKS',
                                    style: TextStyle(
                                      fontFamily: 'BebasNeue',
                                      fontSize: 16,
                                      color: AppColors.headingWhite,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Choose a theme pack to change the UI background, accents, and tube water colors.',
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
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: ThemePack.values.length,
                          itemBuilder: (context, index) {
                            final theme = ThemePack.values[index];
                            final spec = themeSpecs[theme]!;
                            final isSelected = state.activeTheme == theme;

                            return GestureDetector(
                              onTap: () => ref.read(homeViewModelProvider.notifier).setThemePack(theme),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? spec.accent.withValues(alpha: 0.08)
                                      : const Color(0xFF1E1E26),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? spec.accent : const Color(0xFF2C2C35),
                                    width: isSelected ? 2.0 : 1.5,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: spec.accent.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        spec.name.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'BebasNeue',
                                          fontSize: 16,
                                          color: isSelected ? AppColors.headingWhite : AppColors.subtext,
                                          letterSpacing: 0.8,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: spec.bg,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: spec.accent,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
  }) {
    return Container(
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
              color: value ? AppColors.accent.withValues(alpha: 0.1) : const Color(0xFF202026),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.accent : AppColors.subtext,
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
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Map<ThemePack, _ThemeSpec> _getThemeSpecs() {
    return {
      ThemePack.midnight: const _ThemeSpec(
        name: 'Midnight',
        bg: Color(0xFF121212),
        accent: Color(0xFF86EF4D),
      ),
      ThemePack.cyberpunk: const _ThemeSpec(
        name: 'Cyberpunk',
        bg: Color(0xFF0F0B1E),
        accent: Color(0xFFFF007F),
      ),
      ThemePack.forest: const _ThemeSpec(
        name: 'Forest',
        bg: Color(0xFF0D140F),
        accent: Color(0xFF50C878),
      ),
      ThemePack.space: const _ThemeSpec(
        name: 'Space',
        bg: Color(0xFF090A15),
        accent: Color(0xFFBD93F9),
      ),
      ThemePack.retro: const _ThemeSpec(
        name: 'Retro',
        bg: Color(0xFF17130E),
        accent: Color(0xFFFFB86C),
      ),
      ThemePack.sunset: const _ThemeSpec(
        name: 'Sunset',
        bg: Color(0xFF1E0E25),
        accent: Color(0xFFF9844A),
      ),
      ThemePack.neon: const _ThemeSpec(
        name: 'Neon',
        bg: Color(0xFF050505),
        accent: Color(0xFF39FF14),
      ),
    };
  }
}

class _ThemeSpec {
  final String name;
  final Color bg;
  final Color accent;
  const _ThemeSpec({
    required this.name,
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
