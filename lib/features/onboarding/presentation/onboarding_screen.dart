import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/hercare_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ref.read(appSettingsProvider.notifier).setPartnerName(name);
    }
    await ref.read(appSettingsProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsProvider);

    final pages = [
      _buildWelcomeSlide(theme, l10n),
      _buildPrinciplesSlide(theme, l10n),
      _buildPrivacyAndSetupSlide(theme, l10n),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.lavender
                              : theme.colorScheme.outline.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Next / Start Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    child: Text(_currentPage == pages.length - 1 ? l10n.btnGetStarted : l10n.btnNext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSlide(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const HerCareLogo(size: 60),
          ),
          const SizedBox(height: 28),
          Text(
            'Welcome to HerCare',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'A thoughtful menstrual care companion designed for partners who want to understand, support, and care for their loved one.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          _buildBullet(
            Icons.lightbulb_outline,
            'Practical care suggestions over complex medical charts',
          ),
          _buildBullet(
            Icons.lock_outline,
            '100% offline, local storage. No accounts, cloud, or tracking',
          ),
          _buildBullet(
            Icons.handshake_outlined,
            'Based solely on information she voluntarily shares with you',
          ),
        ],
      ),
    );
  }

  Widget _buildPrinciplesSlide(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            l10n.onboardingPrinciplesTitle,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'How HerCare approaches care and privacy',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          _buildPrincipleCard(
            theme,
            icon: Icons.shield_outlined,
            title: 'Care, Never Surveillance',
            description:
                'Only record information your partner voluntarily chooses to share. HerCare is a tool for kindness, not covert monitoring.',
          ),
          const SizedBox(height: 16),
          _buildPrincipleCard(
            theme,
            icon: Icons.auto_graph_outlined,
            title: 'Transparent Estimates',
            description:
                'Menstrual cycles naturally vary. Predictions are rule-based estimates, never medical guarantees, contraception, or pregnancy tests.',
          ),
          const SizedBox(height: 16),
          _buildPrincipleCard(
            theme,
            icon: Icons.hearing_outlined,
            title: 'Listening Over Assumptions',
            description:
                'Avoid assuming she is emotional because of her cycle. HerCare offers gentle ideas to ask and support, never stereotypes.',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyAndSetupSlide(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            l10n.onboardingSetupTitle,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Optionally add her name or nickname for personalized care prompts. Stored strictly on this device.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Her Name or Nickname (Optional)",
              hintText: "e.g., Sarah, Emma, Sweetheart",
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sageSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sageLight.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.sageDark, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Zero Network Traffic: All notes, cycle records, and preferences remain encrypted inside Android application-private storage on this device.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.sageDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.lavender),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lavenderSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: AppColors.lavender),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
