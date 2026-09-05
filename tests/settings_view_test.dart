import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/data/services/hive_service.dart';
import 'package:watersort/ui/core/theme/app_colors.dart';
import 'package:watersort/ui/features/home/view_models/home_view_model.dart';
import 'package:watersort/ui/features/home/views/settings_view.dart';
import 'package:watersort/ui/providers.dart';

class TestHomeViewModel extends HomeViewModel {
  TestHomeViewModel()
    : super(progressRepository: ProgressRepository(hiveService: HiveService()));

  ThemePack get selectedTheme => state.activeTheme;

  @override
  Future<void> setThemePack(ThemePack theme) async {
    state = state.copyWith(activeTheme: theme);
  }
}

void main() {
  testWidgets('all themes can be selected without an unlock dialog', (
    tester,
  ) async {
    final model = TestHomeViewModel();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeViewModelProvider.overrideWith((ref) => model)],
        child: const MaterialApp(home: SettingsView()),
      ),
    );
    for (final theme in ThemePack.values) {
      final tile = find.widgetWithText(
        GestureDetector,
        theme.name.toUpperCase(),
      );
      await tester.scrollUntilVisible(
        tile,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(model.selectedTheme, theme);
      expect(find.byType(Dialog), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('settings fit a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith((ref) => TestHomeViewModel()),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const SettingsView(),
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('RESET ALL PROGRESS'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
