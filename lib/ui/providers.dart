import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/data/services/hive_service.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';
import 'package:watersort/ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return HomeViewModel(progressRepository: progressRepository);
});

final gameViewModelProvider =
    StateNotifierProvider.autoDispose<GameViewModel, GameViewModelState>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return GameViewModel(progressRepository: progressRepository);
});
