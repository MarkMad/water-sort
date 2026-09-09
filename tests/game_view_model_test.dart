import 'package:flutter_test/flutter_test.dart';
import 'package:watersort/data/services/hive_service.dart';
import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';

class FakeHive implements HiveService {
  Map<dynamic, dynamic>? saved;
  bool timerEnabled = true;
  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #getSavedLevelState) return saved;
    if (i.memberName == #isTimerEnabled) return timerEnabled;
    if (i.memberName == #saveActiveLevelState) {
      saved = i.positionalArguments.first as Map<dynamic, dynamic>;
      return Future<void>.value();
    }
    if (i.memberName == #clearActiveLevelState) {
      saved = null;
      return Future<void>.value();
    }
    if ({
      #isSuperHardModeEnabled,
      #isBlurSolvedTubesEnabled,
      #isInstantPouringEnabled,
      #isHintHelperEnabled,
      #isSoundEffectsEnabled,
    }.contains(i.memberName)) {
      return false;
    }
    return super.noSuchMethod(i);
  }
}

Map<dynamic, dynamic> savedLevel({bool random = false}) => {
  'levelNumber': random ? -1 : 4,
  'isRandomMode': random,
  'randomDifficulty': 'Medium',
  'randomColorCount': 3,
  'randomCapacity': 4,
  'randomSeed': 123,
  'optimalMoves': 3,
  'moveCount': 1,
  'moveHistory': [],
  'timeLeft': 2,
  'tubes': [
    {
      'colors': [0xffff0000, 0xff0000ff, 0xffff0000, 0xff0000ff],
      'capacity': 4,
    },
    {
      'colors': [0xff0000ff, 0xffff0000, 0xff0000ff, 0xffff0000],
      'capacity': 4,
    },
    {'colors': [], 'capacity': 4},
  ],
};

class TestGameViewModel extends GameViewModel {
  TestGameViewModel(FakeHive hive)
    : super(progressRepository: ProgressRepository(hiveService: hive));

  GameViewModelState get snapshot => state;
}

TestGameViewModel modelFor(FakeHive hive) => TestGameViewModel(hive);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Undo becomes unavailable during a pour and returns afterwards',
    () async {
      final model = modelFor(
        FakeHive()
          ..saved = savedLevel()
          ..timerEnabled = false,
      );
      addTearDown(model.dispose);
      await model.loadLevel(4);
      model.selectTube(0);
      model.selectTube(2);
      await model.completePendingPour();
      expect(model.snapshot.canUndo, true);

      model.selectTube(1);
      model.selectTube(0);
      expect(model.snapshot.pouringFromIndex, 1);
      expect(model.snapshot.canUndo, false);
      final board = model.snapshot.level;
      model.undoMove();
      expect(model.snapshot.level, same(board));
      await model.completePendingPour();
      expect(model.snapshot.canUndo, true);
    },
  );
  for (final random in [false, true]) {
    Future<void> load(GameViewModel model) => random
        ? model.loadRandomLevel('Medium', colorCount: 3, seed: 123)
        : model.loadLevel(4);
    test('generation can finish after disposal (random: $random)', () async {
      final model = modelFor(FakeHive());
      final pending = load(model);
      model.dispose();
      await expectLater(pending, completes);
    });
    test('retry recovers without a loaded level (random: $random)', () async {
      final hive = FakeHive()..timerEnabled = false;
      hive.saved = savedLevel(random: random)..['tubes'] = 'invalid';
      final model = modelFor(hive);
      addTearDown(model.dispose);
      await load(model);
      expect(model.snapshot.error, isNotNull);
      expect(model.snapshot.level, isNull);
      await model.resetLevel();
      expect(model.snapshot.error, isNull);
      expect(model.snapshot.level, isNotNull);
      expect(model.snapshot.level!.levelNumber, random ? -1 : 4);
      if (random) {
        expect(model.snapshot.randomSeed, 123);
        expect(model.snapshot.randomColorCount, 3);
        expect(model.snapshot.randomCapacity, 4);
      }
    });
    testWidgets('countdown and timeout survive reopening (random: $random)', (
      tester,
    ) async {
      final hive = FakeHive()..saved = savedLevel(random: random);
      var model = modelFor(hive);
      await load(model);
      await tester.pump(const Duration(seconds: 1));
      expect(hive.saved!['timeLeft'], 1);
      model.dispose();
      model = modelFor(hive);
      await load(model);
      expect(model.snapshot.timeLeft, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(model.snapshot.isTimeOut, true);
      expect(hive.saved!['timeLeft'], 0);
      model.dispose();
      model = modelFor(hive);
      await load(model);
      expect(model.snapshot.isTimeOut, true);
      expect(model.snapshot.timeLeft, 0);
      model.dispose();
    });
  }
  test('hint can finish after disposal', () async {
    final model = modelFor(
      FakeHive()
        ..saved = savedLevel()
        ..timerEnabled = false,
    );
    await model.loadLevel(4);
    final pending = model.showHint();
    model.dispose();
    expect(await pending, false);
  });
  test('older generation cannot replace a newer loaded level', () async {
    final hive = FakeHive()..timerEnabled = false;
    final model = modelFor(hive);
    addTearDown(model.dispose);
    final pending = model.loadLevel(1);
    hive.saved = savedLevel();
    await model.loadLevel(4);
    await pending;
    expect(model.snapshot.level!.levelNumber, 4);
  });
  test('hint from previous puzzle is discarded', () async {
    final hive = FakeHive()
      ..saved = savedLevel()
      ..timerEnabled = false;
    final model = modelFor(hive);
    addTearDown(model.dispose);
    await model.loadLevel(4);
    final pending = model.showHint();
    await model.loadLevel(4);
    expect(await pending, false);
    expect(model.snapshot.hintFromIndex, isNull);
  });
}
