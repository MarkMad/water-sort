import 'dart:async';
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
  Timer? _hudSwitchTimer;
  bool _showTimerInHud = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isRandom) {
        ref
            .read(gameViewModelProvider.notifier)
            .loadRandomLevel(
              widget.randomDifficulty,
              colorCount: widget.randomColorCount,
              capacity: widget.randomCapacity,
            );
      } else {
        ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber);
      }
    });
    _hudSwitchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _showTimerInHud = !_showTimerInHud;
        });
      }
    });
  }

  @override
  void dispose() {
    _hudSwitchTimer?.cancel();
    super.dispose();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF2E2E3A),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.swap_vert_rounded,
                            size: 14,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${state.moveCount}',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1.0,
                      height: 16,
                      color: const Color(0xFF3E3E4D),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: (state.timeLeft != null && (state.isRandomMode || _showTimerInHud))
                              ? Row(
                                  key: const ValueKey('timer'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: (state.timeLeft! <= 15
                                                ? Colors.redAccent
                                                : AppColors.accent)
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.timer_rounded,
                                        size: 14,
                                        color: state.timeLeft! <= 15
                                            ? Colors.redAccent
                                            : AppColors.accent,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(state.timeLeft!),
                                      style: TextStyle(
                                        fontFamily: 'BebasNeue',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: state.timeLeft! <= 15
                                            ? Colors.redAccent
                                            : AppColors.headingWhite,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  key: const ValueKey('level'),
                                  state.isRandomMode ? 'RANDOM' : 'LEVEL ${widget.levelNumber}',
                                  style: TextStyle(
                                    fontFamily: 'BebasNeue',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: !state.isRandomMode && widget.levelNumber % 10 == 0
                                        ? Colors.redAccent
                                        : !state.isRandomMode && widget.levelNumber % 5 == 0
                                        ? Colors.amber
                                        : AppColors.headingWhite,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1.0,
                      height: 16,
                      color: const Color(0xFF3E3E4D),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: state.canUndo
                          ? () => ref
                                .read(gameViewModelProvider.notifier)
                                .undoMove()
                          : null,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: (state.canUndo
                                      ? AppColors.accent
                                      : AppColors.subtext)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.undo_rounded,
                              size: 14,
                              color: state.canUndo
                                  ? AppColors.accent
                                  : AppColors.subtext.withValues(alpha: 0.3),
                            ),
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
                                  : AppColors.subtext.withValues(alpha: 0.3),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1.0,
                      height: 16,
                      color: const Color(0xFF3E3E4D),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () =>
                          ref.read(gameViewModelProvider.notifier).resetLevel(),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: _game != null ? GameWidget(game: _game!) : const SizedBox.shrink(),
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
          side: const BorderSide(color: Color(0xFF222222), width: 1.0),
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
                      color: isFilled
                          ? AppColors.accent
                          : const Color(0xFF333333),
                      size: index == 1 ? 54 : 44,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Text(
                'LEVEL COMPLETE!',
                style: TextStyle(
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
                              builder: (context) =>
                                  GameView(levelNumber: widget.levelNumber + 1),
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
                      final Uri url = Uri.parse('https://ko-fi.com/sidhant947');
                      if (!await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      )) {
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
          side: const BorderSide(color: Color(0xFF222222), width: 1.0),
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
              Text(
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
              Text(
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
          side: const BorderSide(color: Color(0xFF222222), width: 1.0),
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
              Text(
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
              Text(
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
