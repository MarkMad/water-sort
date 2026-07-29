import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:watersort/ui/core/theme/app_colors.dart';
import 'package:watersort/ui/core/widgets/tangible_button.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';
import 'package:watersort/ui/providers.dart';
import 'package:watersort/ui/features/game/views/water_sort_game.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
    this.isRandom = false,
    this.randomDifficulty = 'Easy',
  });

  final int levelNumber;
  final bool isRandom;
  final String randomDifficulty;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  WaterSortGame? _game;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isRandom) {
        ref.read(gameViewModelProvider.notifier).loadRandomLevel(widget.randomDifficulty);
      } else {
        ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameViewModelProvider);
    if (state.level != null) {
      if (_game == null) {
        _game = WaterSortGame(
          initialState: state,
          onTubeTap: (index) {
            ref.read(gameViewModelProvider.notifier).selectTube(index);
          },
          onPourComplete: () {
            ref.read(gameViewModelProvider.notifier).completePendingPour();
          },
        );
      } else {
        _game!.updateState(state);
      }
    }

    ref.listen<GameViewModelState>(gameViewModelProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        _showCompleteDialog();
      }
      if (next.isTimeOut && !(prev?.isTimeOut ?? false)) {
        _showTimeOutDialog();
      }
      if (next.isNoMovesLeft && !(prev?.isNoMovesLeft ?? false)) {
        _showNoMovesLeftDialog();
      }
    });

    final isComplete = state.isComplete;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isComplete) {
          Navigator.pop(context);
        } else {
          _showExitConfirmationDialog();
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _showExitConfirmationDialog(),
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
                    state.isRandomMode ? 'RANDOM PUZZLE' : 'LEVEL ${widget.levelNumber}',
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingWhite,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(gameViewModelProvider.notifier).resetLevel(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
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
                          Icons.refresh_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Game body
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(gameViewModelProvider.notifier)
                                    .resetLevel(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _buildGame(state),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildGame(GameViewModelState state) {
    final level = state.level;
    if (level == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF222222),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('MOVES', '${state.moveCount}', Icons.trending_up_rounded),
              if (state.timeLeft != null) ...[
                _verticalDivider(),
                _stat(
                  'TIME LEFT',
                  _formatTime(state.timeLeft!),
                  Icons.timer_rounded,
                  color: state.timeLeft! <= 15 ? Colors.red : AppColors.accent,
                ),
              ],
              _verticalDivider(),
              _actionStat(
                label: 'UNDO',
                icon: Icons.undo_rounded,
                enabled: state.canUndo,
                onTap: state.canUndo
                    ? () => ref.read(gameViewModelProvider.notifier).undoMove()
                    : null,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _game != null
                ? GameWidget(game: _game!)
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon, {Color? color}) {
    final displayColor = color ?? AppColors.accent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: displayColor,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color ?? AppColors.headingWhite,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.subtext,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1.0,
      height: 30,
      color: AppColors.gridLines,
    );
  }

  Widget _actionStat({
    required String label,
    required IconData icon,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    final color = enabled ? AppColors.accent : AppColors.subtext.withValues(alpha: 0.3);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF222222),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'QUIT LEVEL?',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingWhite,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your progress in this level will be lost.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TangibleButton(
                      text: 'Cancel',
                      isSecondary: true,
                      height: 50,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TangibleButton(
                      text: 'Quit',
                      height: 50,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompleteDialog() {
    final state = ref.read(gameViewModelProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF222222),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final moves = state.moveCount;
                  final optimal = state.level?.optimalMoves ?? 0;
                  final int filledStars;
                  if (moves < optimal) {
                    filledStars = 3;
                  } else if (moves == optimal) {
                    filledStars = 2;
                  } else {
                    filledStars = 1;
                  }
                  final isFilled = index < filledStars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star_rounded,
                      color: isFilled ? AppColors.accent : const Color(0xFF333333),
                      size: index == 1 ? 54 : 44,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Text(
                'LEVEL COMPLETE!',
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingWhite,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.isRandomMode
                    ? 'You sorted this ${state.randomDifficulty} puzzle in ${state.moveCount} moves.'
                    : 'You sorted Level ${widget.levelNumber} in ${state.moveCount} moves.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TangibleButton(
                    text: state.isRandomMode ? 'Play Again' : 'Next Level',
                    height: 50,
                    onPressed: () async {
                      final notifier = ref.read(gameViewModelProvider.notifier);
                      await notifier.completeLevel();
                      if (!mounted) return;
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (state.isRandomMode) {
                          notifier.loadRandomLevel(state.randomDifficulty ?? 'Easy');
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameView(levelNumber: widget.levelNumber + 1),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: 'Home',
                    isSecondary: true,
                    height: 50,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: 'Buy Me a Coffee ☕',
                    isSecondary: true,
                    height: 50,
                    onPressed: () async {
                      final Uri url = Uri.parse('https://buymeacoffee.com/sidhant947');
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                        debugPrint('Could not launch $url');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showTimeOutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF222222),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.timer_off_rounded,
                  color: Colors.red,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "TIME'S UP!",
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingWhite,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You ran out of time to sort the water colors.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TangibleButton(
                      text: 'Home',
                      isSecondary: true,
                      height: 50,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TangibleButton(
                      text: 'Try Again',
                      height: 50,
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(gameViewModelProvider.notifier).resetLevel();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoMovesLeftDialog() {
    final state = ref.read(gameViewModelProvider);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF222222),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.block_rounded,
                  color: Colors.amber,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'NO MORE MOVES!',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingWhite,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'There are no valid moves remaining for this configuration.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.canUndo) ...[
                    TangibleButton(
                      text: 'Undo Last Move',
                      height: 50,
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(gameViewModelProvider.notifier).undoMove();
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  TangibleButton(
                    text: 'Restart Level',
                    isSecondary: state.canUndo,
                    height: 50,
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(gameViewModelProvider.notifier).resetLevel();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
