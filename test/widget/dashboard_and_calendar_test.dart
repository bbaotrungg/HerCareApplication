import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/features/calendar/presentation/calendar_screen.dart';
import 'package:hercare/features/care/presentation/care_screen.dart';
import 'package:hercare/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hercare/features/navigation/main_navigation_scaffold.dart';
import 'package:hercare/features/notes/presentation/notes_screen.dart';

void main() {
  testWidgets('Dashboard renders cycle card, possible symptoms, and care suggestions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Cycle Card explanation is present
    expect(find.text('Awaiting first period date'), findsOneWidget);

    // Verify Possible Symptoms & Mood Today section is present
    expect(find.text('Possible Symptoms & Mood Today'), findsOneWidget);

    // Verify Today's Care Suggestions section is present
    expect(find.text('Today\'s Care Suggestions'), findsOneWidget);

    // Verify Primary Action button is Record Period Start
    final periodButton = find.text('Record Period Start');
    await tester.scrollUntilVisible(periodButton, 100);
    expect(periodButton, findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
  });

  testWidgets('Calendar renders month header, weekdays, and visual legend',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CalendarScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify weekdays are present
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);

    // Verify visual legend items
    expect(find.text('Confirmed Period'), findsOneWidget);
    expect(find.text('Estimated Window'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('Care Screen renders Care Suggestions and Educational Library tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CareScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Care Suggestions'), findsOneWidget);
    expect(find.text('Educational Library'), findsOneWidget);

    // Tap Educational Library tab
    await tester.tap(find.text('Educational Library'));
    await tester.pumpAndSettle();

    // Verify category chips exist
    expect(find.text('All Topics'), findsOneWidget);
    expect(find.text('Understanding the Cycle'), findsOneWidget);
  });

  testWidgets('Notes Screen renders Preferences and Personal Notes tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NotesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Personal Notes'), findsOneWidget);
    expect(find.text('Add Preference'), findsOneWidget);
  });

  testWidgets('Main Navigation Scaffold switches destinations smoothly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainNavigationScaffold(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify App Bar Title
    expect(find.text('HerCare'), findsOneWidget);

    // Tap Calendar Tab
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarScreen), findsOneWidget);

    // Tap Care Tab
    await tester.tap(find.byIcon(Icons.favorite_outline));
    await tester.pumpAndSettle();

    expect(find.byType(CareScreen), findsOneWidget);

    // Tap Notes Tab
    await tester.tap(find.byIcon(Icons.bookmark_border_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(NotesScreen), findsOneWidget);
  });
}
