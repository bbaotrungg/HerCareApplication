import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/app/theme/app_theme.dart';
import 'package:hercare/core/localization/app_language.dart';
import 'package:hercare/core/providers/app_providers.dart';
import 'package:hercare/features/calendar/presentation/calendar_screen.dart';
import 'package:hercare/features/care/presentation/care_screen.dart';
import 'package:hercare/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hercare/features/navigation/main_navigation_scaffold.dart';
import 'package:hercare/features/notes/presentation/notes_screen.dart';

void main() {
  const size20x9Compact = Size(360, 800);
  const size20x9Standard = Size(412, 915);

  Widget createTestWidget({
    required Widget child,
    AppLanguage language = AppLanguage.en,
  }) {
    return ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => language),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: child,
      ),
    );
  }

  void checkNoException(WidgetTester tester, [String? step]) {
    final exception = tester.takeException();
    if (exception != null) {
      // ignore: avoid_print
      print('EXCEPTION AT STEP $step: $exception');
    }
    expect(exception, isNull);
  }

  group('20:9 Portrait Mobile Layout - Dashboard Responsiveness', () {
    testWidgets('Dashboard renders on compact 20:9 (360x800) in English with zero overflows',
        (WidgetTester tester) async {
      tester.view.physicalSize = size20x9Compact;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(child: const DashboardScreen()));
      await tester.pumpAndSettle();

      checkNoException(tester, 'Initial pump compact EN');

      expect(find.text('Awaiting first period date'), findsOneWidget);
      expect(find.text('Possible Symptoms & Mood Today'), findsOneWidget);
      expect(find.text('Today\'s Care Suggestions'), findsOneWidget);

      final periodButton = find.text('Record Period Start');
      await tester.scrollUntilVisible(periodButton, 100);
      expect(periodButton, findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Optional manual log'), findsOneWidget);

      checkNoException(tester, 'After scroll compact EN');
    });

    testWidgets('Dashboard renders on standard 20:9 (412x915) in Vietnamese with zero overflows',
        (WidgetTester tester) async {
      tester.view.physicalSize = size20x9Standard;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          child: const DashboardScreen(),
          language: AppLanguage.vi,
        ),
      );
      await tester.pumpAndSettle();

      checkNoException(tester, 'Initial pump standard VI');

      expect(find.text('Đang chờ ngày đầu kỳ kinh'), findsOneWidget);
      expect(find.text('Gợi ý chăm sóc hôm nay'), findsOneWidget);

      final viPeriodButton = find.text('Ghi nhận ngày đầu kỳ kinh');
      await tester.scrollUntilVisible(viPeriodButton, 100);
      expect(viPeriodButton, findsOneWidget);
      expect(find.text('Ghi chú'), findsOneWidget);
      expect(find.text('Ghi nhận tùy chọn'), findsOneWidget);

      checkNoException(tester, 'After scroll standard VI');
    });

    testWidgets('Dashboard renders on narrow 20:9 (360x800) in Vietnamese without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = size20x9Compact;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          child: const DashboardScreen(),
          language: AppLanguage.vi,
        ),
      );
      await tester.pumpAndSettle();

      checkNoException(tester, 'Initial pump compact VI');

      final viPeriodButton = find.text('Ghi nhận ngày đầu kỳ kinh');
      await tester.scrollUntilVisible(viPeriodButton, 100);
      expect(viPeriodButton, findsOneWidget);

      checkNoException(tester, 'After scroll compact VI');
    });
  });

  group('20:9 Portrait Mobile Layout - Full Application Screens', () {
    testWidgets('CalendarScreen renders on 20:9 (360x800) without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = size20x9Compact;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(child: const CalendarScreen()));
      await tester.pumpAndSettle();

      checkNoException(tester, 'Calendar initial');

      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Confirmed Period'), findsOneWidget);
      expect(find.text('Estimated Window'), findsOneWidget);

      checkNoException(tester, 'Calendar checked');
    });

    testWidgets('CareScreen renders on 20:9 (360x800) in Vietnamese without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = size20x9Compact;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          child: const CareScreen(),
          language: AppLanguage.vi,
        ),
      );
      await tester.pumpAndSettle();

      checkNoException(tester, 'Care screen initial VI');

      expect(find.text('Gợi ý chăm sóc'), findsOneWidget);
      expect(find.text('Cẩm nang kiến thức'), findsOneWidget);

      await tester.tap(find.text('Cẩm nang kiến thức'));
      await tester.pumpAndSettle();

      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Hiểu về chu kỳ'), findsOneWidget);

      checkNoException(tester, 'Care screen tab switched VI');
    });

    testWidgets('NotesScreen renders on 20:9 (360x800) in Vietnamese without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = size20x9Compact;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          child: const NotesScreen(),
          language: AppLanguage.vi,
        ),
      );
      await tester.pumpAndSettle();

      checkNoException(tester, 'Notes screen initial VI');

      expect(find.text('Sở thích'), findsOneWidget);
      expect(find.text('Ghi chú cá nhân'), findsOneWidget);
      expect(find.text('Thêm sở thích'), findsOneWidget);

      checkNoException(tester, 'Notes screen checked VI');
    });

    testWidgets('MainNavigationScaffold navigates all tabs seamlessly on 20:9 aspect ratio',
        (WidgetTester tester) async {
      tester.view.physicalSize = size20x9Compact;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(child: const MainNavigationScaffold()));
      await tester.pumpAndSettle();

      expect(find.text('HerCare'), findsOneWidget);
      checkNoException(tester, 'Main scaffold initial');

      // Tap Calendar Tab
      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarScreen), findsOneWidget);
      checkNoException(tester, 'Main scaffold calendar tab');

      // Tap Care Tab
      await tester.tap(find.byIcon(Icons.favorite_outline));
      await tester.pumpAndSettle();
      expect(find.byType(CareScreen), findsOneWidget);
      checkNoException(tester, 'Main scaffold care tab');

      // Tap Notes Tab
      await tester.tap(find.byIcon(Icons.bookmark_border_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(NotesScreen), findsOneWidget);
      checkNoException(tester, 'Main scaffold notes tab');
    });
  });
}
