import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/hercare_logo.dart';
import '../calendar/presentation/calendar_screen.dart';
import '../care/presentation/care_screen.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../notes/presentation/notes_screen.dart';
import '../reminders/presentation/reminders_screen.dart';
import '../settings/presentation/settings_screen.dart';

class MainNavigationScaffold extends ConsumerStatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  ConsumerState<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends ConsumerState<MainNavigationScaffold> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = ref.watch(appLocalizationsProvider);

    final screens = [
      DashboardScreen(onNavigateToTab: _onTabChanged),
      const CalendarScreen(),
      const CareScreen(),
      const NotesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: const HerCareLogo(size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'HerCare',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            tooltip: l10n.tooltipReminders,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RemindersScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.tooltipSettings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.navCare,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border_outlined),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.navNotes,
          ),
        ],
      ),
    );
  }
}
