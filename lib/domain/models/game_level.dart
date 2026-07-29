import 'package:flutter/material.dart';

import 'tube.dart';

@immutable
class GameLevel {
  const GameLevel({
    required this.levelNumber,
    required this.tubes,
    this.totalMoves = 0,
    required this.optimalMoves,
  });

  final int levelNumber;
  final List<Tube> tubes;
  final int totalMoves;
  final int optimalMoves;

  int get colorCount =>
      tubes.expand((t) => t.colors).toSet().length;

  int get tubeCount => tubes.length;

  bool get isComplete => tubes.every((t) => t.isSolved || t.isEmpty);

  bool get hasPossibleMoves {
    if (isComplete) return false;
    for (int i = 0; i < tubes.length; i++) {
      final from = tubes[i];
      if (from.isEmpty) continue;
      final colorToMove = from.topColor!;
      for (int j = 0; j < tubes.length; j++) {
        if (i == j) continue;
        final to = tubes[j];
        if (!to.isFull && to.canReceive(colorToMove)) {
          return true;
        }
      }
    }
    return false;
  }

  GameLevel copyWith({
    int? levelNumber,
    List<Tube>? tubes,
    int? totalMoves,
    int? optimalMoves,
  }) {
    return GameLevel(
      levelNumber: levelNumber ?? this.levelNumber,
      tubes: tubes ?? this.tubes,
      totalMoves: totalMoves ?? this.totalMoves,
      optimalMoves: optimalMoves ?? this.optimalMoves,
    );
  }
}
