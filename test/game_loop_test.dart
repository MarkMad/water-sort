import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watersort/domain/models/game_level.dart';
import 'package:watersort/domain/models/tube.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';

void main() {
  test('isNoMovesLeft identifies loop and physical moves correctly', () {
    final tube1 = Tube(colors: const [Colors.red, Colors.blue], capacity: 4);
    final tube2 = Tube(colors: const [Colors.red], capacity: 4);
    final tube3 = Tube(colors: const [], capacity: 4);
    final initialTubes = [tube1, tube2, tube3];

    final level = GameLevel(
      levelNumber: 1,
      tubes: initialTubes,
      optimalMoves: 5,
    );

    var state = GameViewModelState(
      level: level,
      moveHistory: const [],
    );

    expect(state.isNoMovesLeft, isFalse);

    final nextTubes = [
      Tube(colors: const [Colors.red], capacity: 4),
      Tube(colors: const [Colors.red], capacity: 4),
      Tube(colors: const [Colors.blue], capacity: 4),
    ];

    final snapshot = MoveSnapshot(
      tubes: initialTubes,
      moveCount: 0,
    );

    state = state.copyWith(
      level: GameLevel(levelNumber: 1, tubes: nextTubes, optimalMoves: 5),
      moveCount: 1,
      moveHistory: [snapshot],
    );

    expect(state.isNoMovesLeft, isFalse);

    final loopTubes = [
      Tube(colors: const [Colors.red, Colors.blue], capacity: 4),
      Tube(colors: const [Colors.red], capacity: 4),
      Tube(colors: const [], capacity: 4),
    ];

    final loopSnapshot = MoveSnapshot(
      tubes: nextTubes,
      moveCount: 1,
    );

    state = state.copyWith(
      level: GameLevel(levelNumber: 1, tubes: loopTubes, optimalMoves: 5),
      moveCount: 2,
      moveHistory: [snapshot, loopSnapshot],
    );

    expect(state.isNoMovesLeft, isTrue);
  });
}
