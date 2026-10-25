import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../education/data/curated_tips.dart';
import '../../education/domain/models/educational_tip.dart';
import '../../notes/domain/models/personal_note.dart';
import '../domain/models/care_recommendation.dart';

class CareScreen extends ConsumerStatefulWidget {
  const CareScreen({super.key});

  @override
  ConsumerState<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends ConsumerState<CareScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TipCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsProvider);
    final recommendations = ref.watch(careRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.isVietnamese ? 'Chăm sóc & Chỉ dẫn' : 'Care & Guidance'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.lavender,
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor: theme.textTheme.bodySmall?.color,
          tabs: [
            Tab(text: l10n.tabCareSuggestions, icon: const Icon(Icons.favorite_outline, size: 20)),
            Tab(text: l10n.tabEducationalLibrary, icon: const Icon(Icons.auto_stories_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Recommendations
          _buildRecommendationsTab(theme, recommendations, l10n),

          // Tab 2: Educational Tips
          _buildEducationTab(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(
    ThemeData theme,
    List<CareRecommendation> recommendations,
    AppLocalizations l10n,
  ) {
    if (recommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa_outlined, size: 56, color: AppColors.sage),
              const SizedBox(height: 16),
              Text(
                'Awaiting Cycle Data',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Record the start date of her period from the Home screen or Calendar to view contextual care ideas.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final rec = recommendations[index];
        return _buildRecommendationCard(theme, rec, l10n);
      },
    );
  }

  Widget _buildRecommendationCard(ThemeData theme, CareRecommendation rec, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Context basis badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      content: '${rec.naturalThought}\n\n${rec.gentleContext ?? ""}',
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
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
                height: 1.45,
              ),
            ),

            if (rec.gentleContext != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.lavender),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec.gentleContext!,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEducationTab(ThemeData theme, AppLocalizations l10n) {
    final tips = _selectedCategory == null
        ? CuratedTips.allTips
        : CuratedTips.allTips.where((t) => t.category == _selectedCategory).toList();

    String getCategoryLabel(TipCategory cat) {
      if (l10n.isVietnamese) {
        switch (cat) {
          case TipCategory.cycleUnderstanding:
            return l10n.topicUnderstanding;
          case TipCategory.physicalComfort:
            return l10n.topicComfort;
          case TipCategory.emotionalSupport:
            return l10n.topicCommunication;
          case TipCategory.respectfulCommunication:
            return 'Giao tiếp tinh tế';
          case TipCategory.practicalEssentials:
            return 'Đồ dùng thiết yếu';
          case TipCategory.predictionUncertainty:
            return 'Dao động tự nhiên';
        }
      }
      return cat.displayName;
    }

    return Column(
      children: [
        // Category chips filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              FilterChip(
                selected: _selectedCategory == null,
                label: Text(l10n.topicAll),
                onSelected: (selected) {
                  setState(() => _selectedCategory = null);
                },
              ),
              const SizedBox(width: 8),
              ...TipCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    avatar: Icon(cat.icon, size: 14),
                    label: Text(getCategoryLabel(cat)),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat : null;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const Divider(height: 1),

        // Tips List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return _buildTipCard(theme, tip);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(ThemeData theme, EducationalTip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lavenderSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(tip.category.icon, color: AppColors.lavenderDark, size: 22),
        ),
        title: Text(
          tip.title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            tip.summary,
            style: theme.textTheme.bodySmall,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            tip.fullContent,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          if (tip.actionablePoints.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Helpful Partner Actions:',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...tip.actionablePoints.map((pt) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 16, color: AppColors.sage),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(pt, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
