import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watersort/ui/core/theme/app_colors.dart';
import 'package:watersort/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);

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
                  const Text(
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
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF222222),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GAMEPLAY TIMER',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingWhite,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enabling the timer adds a countdown limit to levels. Disable it for a relaxed puzzle solving experience.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.subtext,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRadioOption(
                          ref: ref,
                          title: 'Timer ON (Normal Difficulty)',
                          subtitle: 'Standard timed level gameplay',
                          selected: state.isTimerEnabled,
                          onTap: () {
                            if (!state.isTimerEnabled) {
                              ref.read(homeViewModelProvider.notifier).toggleTimer();
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildRadioOption(
                          ref: ref,
                          title: 'Timer OFF (Relaxed Mode)',
                          subtitle: 'Solve puzzles at your own pace',
                          selected: !state.isTimerEnabled,
                          onTap: () {
                            if (state.isTimerEnabled) {
                              ref.read(homeViewModelProvider.notifier).toggleTimer();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF222222),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SUPER HARD DIFFICULTY',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingWhite,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hides all colors below the surface. Only the topmost color is shown; all hidden segments turn pure white.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.subtext,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRadioOption(
                          ref: ref,
                          title: 'Super Hard: OFF',
                          subtitle: 'All colors and icons remain visible',
                          selected: !state.isSuperHardModeEnabled,
                          onTap: () {
                            if (state.isSuperHardModeEnabled) {
                              ref.read(homeViewModelProvider.notifier).toggleSuperHardMode();
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildRadioOption(
                          ref: ref,
                          title: 'Super Hard: ON',
                          subtitle: 'Only top color is shown. Lower levels turn white.',
                          selected: state.isSuperHardModeEnabled,
                          onTap: () {
                            if (!state.isSuperHardModeEnabled) {
                              ref.read(homeViewModelProvider.notifier).toggleSuperHardMode();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF222222),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COMPLETED TUBES VISUALS',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingWhite,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Frosts completed tubes with a blurred liquid glass effect to keep your focus on active tubes.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.subtext,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRadioOption(
                          ref: ref,
                          title: 'Frost Completed: OFF',
                          subtitle: 'Completed tubes retain normal colors and icons',
                          selected: !state.isBlurSolvedTubesEnabled,
                          onTap: () {
                            if (state.isBlurSolvedTubesEnabled) {
                              ref.read(homeViewModelProvider.notifier).toggleBlurSolvedTubes();
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildRadioOption(
                          ref: ref,
                          title: 'Frost Completed: ON',
                          subtitle: 'Completed tubes fade into blurred liquid glass',
                          selected: state.isBlurSolvedTubesEnabled,
                          onTap: () {
                            if (!state.isBlurSolvedTubesEnabled) {
                              ref.read(homeViewModelProvider.notifier).toggleBlurSolvedTubes();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF202026) : const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : const Color(0xFF222222),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.accent : const Color(0xFF444444),
                  width: 2.0,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                      ),
                    )
                  : null,
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
                      color: selected ? Colors.white : AppColors.subtext,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
