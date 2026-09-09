import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watersort/domain/models/game_level.dart';
import 'package:watersort/domain/models/tube.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';
import 'package:watersort/ui/features/game/views/water_sort_game.dart';

class SilentGame extends WaterSortGame {
  SilentGame({required super.initialState, required super.onPourComplete})
    : super(onTubeTap: (_) {});

  // Audio playback is platform-specific and is not part of these tests.
  @override
  Future<void> onLoad() async {}
}

const initial = GameViewModelState(
  isSoundEffectsEnabled: false,
  level: GameLevel(
    levelNumber: 4,
    optimalMoves: 3,
    tubes: [
      Tube(colors: [Colors.red, Colors.blue], capacity: 2),
      Tube(colors: [Colors.blue, Colors.red], capacity: 2),
      Tube(colors: [], capacity: 2),
    ],
  ),
);

GameViewModelState pouring(GameViewModelState state) => state.copyWith(
  selectedTubeIndex: () => 0,
  pouringFromIndex: () => 0,
  pouringToIndex: () => 2,
);

Future<SilentGame> mountGame(
  WidgetTester tester,
  VoidCallback onComplete,
) async {
  final game = SilentGame(initialState: initial, onPourComplete: onComplete);
  await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
  for (
    var i = 0;
    i < 10 && game.children.whereType<TubeComponent>().isEmpty;
    i++
  ) {
    await tester.pump();
  }
  game.pauseEngine();
  expect(game.children.whereType<TubeComponent>(), hasLength(3));
  return game;
}

void main() {
  test('liquid spring stays bounded and settles after a long frame', () {
    final tube = TubeComponent(
      index: 0,
      tube: initial.level!.tubes[0],
      isSelected: true,
    );
    tube.update(1 / 60);
    tube.isSelected = false;
    tube.update(5);
    expect(tube.sloshVelocity.abs(), lessThanOrEqualTo(60));
    expect(tube.sloshDisplacement.abs(), lessThanOrEqualTo(15));
    for (var i = 0; i < 600; i++) {
      tube.update(1 / 60);
    }
    expect(tube.sloshVelocity, 0);
    expect(tube.sloshDisplacement, 0);
  });

  test('ripples have the same radius at equal elapsed times', () {
    TapRipple ripple() => TapRipple(
      position: Vector2.zero(),
      radius: 5,
      maxRadius: 50,
      life: 0,
      maxLife: 0.3,
      color: Colors.blue,
    );
    final slow = ripple();
    final fast = ripple();
    slow.update(0.15);
    for (var i = 0; i < 15; i++) {
      fast.update(0.01);
    }
    expect(slow.radius, closeTo(fast.radius, 0.00001));
    expect(slow.radius, closeTo(27.5, 0.00001));
    expect(slow.update(0.2), true);
  });

  testWidgets('pour finishes on schedule at 20 FPS', (tester) async {
    var completed = 0;
    final game = await mountGame(tester, () => completed++);
    game.updateState(pouring(initial));
    for (var i = 0; i < 12; i++) {
      game.update(0.05);
    }
    expect(completed, 0);
    game.update(0.1);
    expect(completed, 1);
    game.update(1);
    expect(completed, 1);
  });

  for (final transition in ['restart', 'next level', 'timeout', 'undo']) {
    testWidgets('$transition cancels the previous pour', (tester) async {
      var completed = 0;
      final game = await mountGame(tester, () => completed++);
      final before = initial.copyWith(
        moveHistory: [MoveSnapshot(tubes: initial.level!.tubes)],
      );
      game.updateState(pouring(before));
      game.update(0.2);
      final tubes = game.children.whereType<TubeComponent>().toList();
      expect(tubes[0].isAnimatingSource, true);
      expect(tubes[2].isAnimatingTarget, true);

      switch (transition) {
        case 'restart':
          game.updateState(const GameViewModelState(isLoading: true));
          game.updateState(initial);
        case 'next level':
          game.updateState(
            initial.copyWith(level: initial.level!.copyWith(levelNumber: 5)),
          );
        case 'timeout':
          game.updateState(pouring(before).copyWith(isTimeOut: true));
        case 'undo':
          game.updateState(initial);
      }
      expect(tubes[0].isAnimatingSource, false);
      expect(tubes[2].isAnimatingTarget, false);
      game.update(1);
      expect(completed, 0);

      // A fresh pour still works after the cancelled animation.
      game.updateState(pouring(initial));
      game.update(0.7);
      expect(completed, 1);
    });
  }
}
