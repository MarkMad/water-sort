import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/data/services/hive_service.dart';
import 'package:watersort/domain/models/user_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'reset removes only the active profile progress, stars and puzzle',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'water_sort_reset_test_',
      );
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => directory.path,
      );
      addTearDown(() async {
        await Hive.close();
        messenger.setMockMethodCallHandler(channel, null);
        await directory.delete(recursive: true);
      });
      final hive = HiveService();
      await hive.init();
      final repository = ProgressRepository(hiveService: hive);
      final firstId = (await hive.getActiveProfileId())!;
      await repository.saveProgress(
        const UserProgress(
          currentLevel: 5,
          highestLevelCompleted: 4,
          totalMoves: 40,
        ),
      );
      await repository.saveLevelStars(4, 3);
      await repository.saveActiveLevelState({'levelNumber': 5});
      await repository.setTimerEnabled(false);
      await repository.setThemePack('ocean');
      await repository.createProfile('Other player', 'X');
      final otherId = (await hive.getActiveProfileId())!;
      await repository.saveProgress(
        const UserProgress(currentLevel: 3, highestLevelCompleted: 2),
      );
      await repository.saveLevelStars(2, 2);
      await repository.saveActiveLevelState({'levelNumber': 3});
      await repository.switchProfile(firstId);
      await repository
          .getProgress(); // Populate the repository cache before reset.

      await repository.resetProgress();
      expect((await repository.getProgress()).currentLevel, 1);
      expect((await repository.getProgress()).totalMoves, 0);
      expect(repository.getAllLevelStars(), isEmpty);
      expect(repository.getSavedLevelState(), isNull);
      expect(repository.isTimerEnabled(), false);
      expect(repository.getThemePack(), 'ocean');
      expect((await repository.getProfiles()).length, 2);

      await repository.switchProfile(otherId);
      expect((await repository.getProgress()).currentLevel, 3);
      expect(repository.getAllLevelStars()[2], 2);
      expect(repository.getSavedLevelState()!['levelNumber'], 3);
    },
  );
}
