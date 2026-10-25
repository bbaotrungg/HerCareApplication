import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/hercare_logo.dart';
import '../../calendar/presentation/widgets/period_entry_dialog.dart';
import '../../care/domain/models/care_recommendation.dart';
import '../../cycle_tracking/domain/models/cycle_estimate.dart';
import '../../notes/domain/models/personal_note.dart';
import '../../symptoms/domain/models/daily_symptom_mood_estimate.dart';
import '../../symptoms/domain/models/symptom_possibility.dart';
import '../../symptoms/presentation/log_observation_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  String _getTimeBasedGreeting(String partnerName, AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.greetingMorning(partnerName);
    } else if (hour < 17) {
      return l10n.greetingAfternoon(partnerName);
    } else {
      return l10n.greetingEvening(partnerName);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final language = ref.watch(appLanguageProvider);
    final l10n = ref.watch(appLocalizationsProvider);
    final estimate = ref.watch(cycleEstimateProvider);
    final symptomMoodEstimate = ref.watch(dailySymptomMoodEstimateProvider);
    final recommendations = ref.watch(careRecommendationsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: const HerCareLogo(size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTimeBasedGreeting(settings.partnerName, l10n),
                    style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16),
                  ),
                  Text(
                    AppDateUtils.formatFullDate(today),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(cycleRecordsProvider.notifier).loadRecords();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Current Cycle Overview & Phase Banner
            _buildCycleStatusCard(context, theme, estimate, l10n, language),

            const SizedBox(height: 20),

            // 2. Possible Symptoms & Mood Today (Automated contextual estimates)
            _buildPossibleSymptomsAndMoodSection(
              context,
              theme,
              symptomMoodEstimate,
              estimate,
              l10n,
            ),

            const SizedBox(height: 20),

            // 3. Today's Care Suggestions (Derived from the estimated context above)
            _buildCareSuggestionsSection(
              context,
              ref,
              theme,
              recommendations,
              l10n,
            ),

            const SizedBox(height: 20),

            // 4. Quick Actions (Minimal user input: Period Start is primary)
            _buildQuickActionsBar(context, ref, selectedDate, l10n),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleStatusCard(
    BuildContext context,
    ThemeData theme,
    CycleEstimate estimate,
    AppLocalizations l10n,
    AppLanguage language,
  ) {
    final phase = estimate.currentEstimatedPhase;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: phase.color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: phase.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(phase.icon, size: 16, color: phase.color),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          phase.localizedName(language),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: phase.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  estimate.reliability.localizedBadgeLabel(language),
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current Cycle Day (if recorded)
          if (estimate.dayOfCycle != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: phase.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.cycleDayBadge(estimate.dayOfCycle!),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: phase.color,
                ),
              ),
            ),
          ],

          // Timing Headline
          Text(
            estimate.localizedTimingHeadline(language),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Gentle Phase Explanation
          Text(
            phase.localizedExplanation(language),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 6),

          // Estimation Transparency Disclaimer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 15, color: AppColors.lavender),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  estimate.localizedExplanationMessage(language),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPossibleSymptomsAndMoodSection(
    BuildContext context,
    ThemeData theme,
    DailySymptomMoodEstimate estimate,
    CycleEstimate cycleEstimate,
    AppLocalizations l10n,
  ) {
    if (!estimate.hasEstimates) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined, size: 18, color: AppColors.lavender),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.symptomsSectionTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              estimate.transparentNotice,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.symptomsSectionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.symptomsTransparentNotice,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lavenderSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  estimate.confidenceBadge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lavenderDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Physical Possibilities Subheading
          if (estimate.physicalPossibilities.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.accessibility_new_outlined, size: 15, color: AppColors.softRose),
                const SizedBox(width: 6),
                Text(
                  l10n.physicalSensationsHeading,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.softRoseDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...estimate.physicalPossibilities.map((p) => _buildPossibilityCard(theme, p)),
            const SizedBox(height: 14),
          ],

          // Emotional Possibilities Subheading
          if (estimate.emotionalPossibilities.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.self_improvement_outlined, size: 15, color: AppColors.lavender),
                const SizedBox(width: 6),
                Text(
                  l10n.emotionalStateHeading,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lavenderDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...estimate.emotionalPossibilities.map((p) => _buildPossibilityCard(theme, p)),
          ],

          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 4),

          // Transparent Context Note
          Text(
            estimate.transparentNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPossibilityCard(ThemeData theme, SymptomPossibility p) {
    final isPhysical = p.type == PossibilityType.physical;
    final primaryColor = isPhysical ? AppColors.softRose : AppColors.lavender;
    final surfaceColor = isPhysical ? AppColors.softRoseSurface : AppColors.lavenderSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(p.icon, size: 18, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (p.likelihoodContext.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Text(
                          p.likelihoodContext,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  p.naturalExplanation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareSuggestionsSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    List<CareRecommendation> recommendations,
    AppLocalizations l10n,
  ) {
    // Show 2-3 suggestions at a time
    final displayedSuggestions = recommendations.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.careSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.isVietnamese
                      ? 'Những cử chỉ ân cần phù hợp với thời điểm chu kỳ hôm nay'
                      : 'Considerate gestures matching today\'s estimated context',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
            if (onNavigateToTab != null)
              TextButton(
                onPressed: () => onNavigateToTab!(2), // Tab 2: Care & Learn
                child: Text(l10n.careExploreMore),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (displayedSuggestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(l10n.careEmptyMessage),
          )
        else
          ...displayedSuggestions.map((rec) => _buildSuggestionCard(context, ref, theme, rec, l10n)),
      ],
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    CareRecommendation rec,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lavenderSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(rec.icon, size: 14, color: AppColors.lavenderDark),
                    const SizedBox(width: 6),
                    Text(
                      rec.contextBasis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lavenderDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_outline, size: 18),
                tooltip: l10n.careSaveToNotes,
                onPressed: () {
                  final note = PersonalNote(
                    title: rec.contextBasis,
                    content: rec.naturalThought,
                    category: 'Care Idea',
                  );
                  ref.read(personalNotesProvider.notifier).save(note);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.careSavedToNotes)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Natural Thought
          Text(
            rec.naturalThought,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),

          if (rec.gentleContext != null) ...[
            const SizedBox(height: 8),
            Text(
              rec.gentleContext!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsBar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActionsTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Primary input: Record Period Start
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PeriodEntryDialog(defaultDate: selectedDate),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.water_drop, size: 18),
                label: Text(
                  l10n.btnRecordPeriodStart,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Secondary: Quick Note
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showQuickNoteDialog(context, ref, l10n),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: Text(l10n.btnNote),
              ),
            ),
            const SizedBox(width: 8),
            // Optional Manual Log icon button
            IconButton.outlined(
              onPressed: () => LogObservationSheet.show(context, date: DateTime.now()),
              tooltip: l10n.btnOptionalManualLog,
              icon: const Icon(Icons.playlist_add, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  void _showQuickNoteDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.btnAddNote),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: l10n.isVietnamese ? 'Tiêu đề' : 'Title',
                hintText: l10n.isVietnamese ? 'e.g. Món ăn cô ấy thích hôm nay' : 'e.g. Her favorite soup today',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.isVietnamese ? 'Nội dung' : 'Content',
                hintText: l10n.isVietnamese ? 'Nhập ghi chú nhỏ...' : 'Enter thoughtful observation...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isNotEmpty || content.isNotEmpty) {
                ref.read(personalNotesProvider.notifier).save(
                      PersonalNote(
                        title: title.isEmpty ? (l10n.isVietnamese ? 'Ghi chú nhanh' : 'Quick Note') : title,
                        content: content,
                        category: l10n.isVietnamese ? 'Chung' : 'General',
                      ),
                    );
              }
              Navigator.of(context).pop();
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }
}
