import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../features/navigation/main_navigation_scaffold.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import 'theme/app_theme.dart';

class HerCareApp extends ConsumerWidget {
  const HerCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'HerCare',
      debugShowCheckedModeBanner: false,
      locale: Locale(settings.language.code),
      themeMode: settings.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: settings.onboardingCompleted
          ? const MainNavigationScaffold()
          : const OnboardingScreen(),
    );
  }
}

