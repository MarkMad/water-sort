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
    this.randomColorCount,
    this.randomCapacity,
  });

  final int levelNumber;
  final bool isRandom;
  final String randomDifficulty;
  final int? randomColorCount;
  final int? randomCapacity;

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
        ref.read(gameViewModelProvider.notifier).loadRandomLevel(
              widget.randomDifficulty,
              colorCount: widget.randomColorCount,
              capacity: widget.randomCapacity,
            );
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

    return Scaffold(
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
                    state.isRandomMode
                        ? 'RANDOM PUZZLE'
                        : widget.levelNumber % 10 == 0
                            ? 'LEVEL ${widget.levelNumber} (BOSS)'
                            : widget.levelNumber % 5 == 0
                                ? 'LEVEL ${widget.levelNumber} (SPECIAL)'
                                : 'LEVEL ${widget.levelNumber}',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: !state.isRandomMode && widget.levelNumber % 10 == 0
                          ? Colors.redAccent
                          : !state.isRandomMode && widget.levelNumber % 5 == 0
                              ? Colors.amber
                              : AppColors.headingWhite,
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
    );
  }

  Widget _buildGame(GameViewModelState state) {
    final level = state.level;
    if (level == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 6, 20, 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF131317),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF23232D),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C24),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.swap_vert_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.moveCount}',
                          style: const TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingWhite,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'MOVES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.subtext,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (state.timeLeft != null) ...[
                Container(
                  width: 1.0,
                  height: 24,
                  color: const Color(0xFF2A2A35),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 16,
                        color: state.timeLeft! <= 15 ? Colors.redAccent : AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(state.timeLeft!),
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: state.timeLeft! <= 15 ? Colors.redAccent : AppColors.headingWhite,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'TIME LEFT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: state.timeLeft! <= 15 ? Colors.redAccent.withOpacity(0.7) : AppColors.subtext,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              Container(
                width: 1.0,
                height: 24,
                color: const Color(0xFF2A2A35),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: state.canUndo
                          ? () => ref.read(gameViewModelProvider.notifier).undoMove()
                          : null,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: state.canUndo
                              ? AppColors.accent.withOpacity(0.1)
                              : const Color(0xFF17171C),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: state.canUndo
                                ? AppColors.accent.withOpacity(0.3)
                                : const Color(0xFF22222A),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.undo_rounded,
                              size: 14,
                              color: state.canUndo
                                  ? AppColors.accent
                                  : AppColors.subtext.withOpacity(0.3),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'UNDO',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: state.canUndo
                                    ? AppColors.accent
                                    : AppColors.subtext.withOpacity(0.3),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                          notifier.loadRandomLevel(
                            state.randomDifficulty ?? 'Easy',
                            colorCount: state.randomColorCount,
                            capacity: state.randomCapacity,
                          );
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TangibleButton(
                    text: 'Try Again',
                    height: 50,
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(gameViewModelProvider.notifier).resetLevel();
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
