import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/app/app.dart';
import 'package:hercare/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('HerCare App Smoke & Onboarding Flow Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: HerCareApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Onboarding Screen is shown by default
    expect(find.text('Welcome to HerCare'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap Next to advance to principles
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Core Principles'), findsOneWidget);

    // Tap Next to advance to setup slide
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Personal Touch'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
