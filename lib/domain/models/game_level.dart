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
    bool hasAnyPhysicalMove = false;
    for (int i = 0; i < tubes.length; i++) {
      final from = tubes[i];
      if (from.isEmpty) continue;
      final colorToMove = from.topColor!;
      for (int j = 0; j < tubes.length; j++) {
        if (i == j) continue;
        final to = tubes[j];
        if (!to.isFull && to.canReceive(colorToMove)) {
          hasAnyPhysicalMove = true;
          break;
        }
      }
      if (hasAnyPhysicalMove) break;
    }
    if (!hasAnyPhysicalMove) return false;
    return _isSolvable(tubes);
  }

  bool _isSolvable(List<Tube> initialTubes) {
    final visited = <String>{};
    const maxStates = 1000;

    String getStateKey(List<Tube> tubesList) {
      return tubesList.map((t) => t.colors.map((c) => c.value).join(',')).join(';');
    }

    bool dfs(List<Tube> currentTubes) {
      if (visited.length > maxStates) {
        return true;
      }

      final key = getStateKey(currentTubes);
      if (visited.contains(key)) return false;
      visited.add(key);

      bool isComplete = true;
      for (final tube in currentTubes) {
        if (!tube.isEmpty && !tube.isSolved) {
          isComplete = false;
          break;
        }
      }
      if (isComplete) return true;

      for (int fromIdx = 0; fromIdx < currentTubes.length; fromIdx++) {
        final fromTube = currentTubes[fromIdx];
        if (fromTube.isEmpty) continue;

        final colorToMove = fromTube.topColor!;
        int countToMove = 0;
        for (int i = fromTube.colors.length - 1; i >= 0; i--) {
          if (fromTube.colors[i] == colorToMove) {
            countToMove++;
          } else {
            break;
          }
        }

        for (int toIdx = 0; toIdx < currentTubes.length; toIdx++) {
          if (fromIdx == toIdx) continue;
          final toTube = currentTubes[toIdx];

          if (toTube.isFull) continue;
          if (!toTube.isEmpty && toTube.topColor != colorToMove) continue;

          final availableSpace = toTube.capacity - toTube.colors.length;
          final pourCount = countToMove < availableSpace ? countToMove : availableSpace;
          if (pourCount == 0) continue;

          final fromHasOnlyOneColor = fromTube.colors.every((c) => c == colorToMove);
          if (toTube.isEmpty && fromHasOnlyOneColor) {
            continue;
          }

          final newFromColors = List<Color>.from(fromTube.colors)
            ..removeRange(fromTube.colors.length - pourCount, fromTube.colors.length);
          final newToColors = List<Color>.from(toTube.colors)
            ..addAll(List.filled(pourCount, colorToMove));

          final nextTubes = List<Tube>.from(currentTubes);
          nextTubes[fromIdx] = fromTube.copyWith(colors: newFromColors);
          nextTubes[toIdx] = toTube.copyWith(colors: newToColors);

          if (dfs(nextTubes)) return true;
        }
      }

      return false;
    }

    return dfs(initialTubes);
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
