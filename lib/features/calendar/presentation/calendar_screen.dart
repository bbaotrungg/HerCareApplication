import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../cycle_tracking/domain/models/cycle_record.dart';
import '../../symptoms/domain/models/daily_observation.dart';
import '../../symptoms/presentation/log_observation_sheet.dart';
import 'widgets/period_entry_dialog.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(selectedDateProvider);
    _focusedMonth = DateTime(selected.year, selected.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final records = ref.watch(cycleRecordsProvider).value ?? [];
    final estimate = ref.watch(cycleEstimateProvider);
    final observations = ref.watch(dailyObservationsProvider).value ?? [];

    // Find observation for selected date
    final selectedDateObs = observations.where((o) => AppDateUtils.isSameDay(o.date, selectedDate)).firstOrNull;

    // Find period record covering selected date
    final selectedDateCycle = records.where((r) => r.containsDate(selectedDate)).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.isVietnamese ? 'Lịch chu kỳ' : 'Menstrual Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: l10n.isVietnamese ? 'Về hôm nay' : 'Jump to Today',
            onPressed: () {
              final today = DateTime.now();
              ref.read(selectedDateProvider.notifier).select(today);
              setState(() {
                _focusedMonth = DateTime(today.year, today.month, 1);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l10n.btnRecordPeriodStart,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => PeriodEntryDialog(defaultDate: selectedDate),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Month Header with arrows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    AppDateUtils.formatMonthYear(_focusedMonth),
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),

            // Weekday labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Calendar Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildMonthGrid(
                context,
                focusedMonth: _focusedMonth,
                selectedDate: selectedDate,
                records: records,
                estimate: estimate,
                observations: observations,
              ),
            ),

            const SizedBox(height: 12),

            // Calendar Visual Legend
            _buildLegend(theme, l10n),

            const SizedBox(height: 16),

            // Selected Date Detail Section
            _buildSelectedDateDetails(
              context,
              theme: theme,
              date: selectedDate,
              cycleRecord: selectedDateCycle,
              observation: selectedDateObs,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid(
    BuildContext context, {
    required DateTime focusedMonth,
    required DateTime selectedDate,
    required List<CycleRecord> records,
    required dynamic estimate,
    required List<DailyObservation> observations,
  }) {
    final daysInMonth = AppDateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final firstWeekday = DateTime(focusedMonth.year, focusedMonth.month, 1).weekday % 7; // Sunday = 0
    final today = DateTime.now();

    final totalCells = ((daysInMonth + firstWeekday) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (index < firstWeekday || index >= firstWeekday + daysInMonth) {
          return const SizedBox.shrink(); // Empty padding cell
        }

        final dayNumber = index - firstWeekday + 1;
        final cellDate = DateTime(focusedMonth.year, focusedMonth.month, dayNumber);

        // Status checks
        final isToday = AppDateUtils.isSameDay(cellDate, today);
        final isSelected = AppDateUtils.isSameDay(cellDate, selectedDate);

        // Check if confirmed period day
        final isConfirmedPeriod = records.any((r) => r.containsDate(cellDate));

        // Check if in estimated period window (strictly for future/unconfirmed dates)
        final isEstimatedPeriod = !isConfirmedPeriod &&
            estimate.hasPrediction &&
            estimate.estimatedPeriodWindowStart != null &&
            estimate.estimatedPeriodWindowEnd != null &&
            AppDateUtils.isDateInRange(
              cellDate,
              estimate.estimatedPeriodWindowStart!,
              estimate.estimatedPeriodWindowEnd!,
            );

        // Check if symptoms or emotions logged
        final hasObservation = observations.any((o) => AppDateUtils.isSameDay(o.date, cellDate));

        return InkWell(
          onTap: () {
            ref.read(selectedDateProvider.notifier).select(cellDate);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isConfirmedPeriod
                  ? AppColors.softRose.withValues(alpha: 0.85)
                  : (isEstimatedPeriod
                      ? AppColors.softRoseLight.withValues(alpha: 0.35)
                      : (isSelected ? AppColors.lavenderSurface : Colors.transparent)),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.lavender, width: 2)
                  : (isToday
                      ? Border.all(color: AppColors.sage, width: 1.5)
                      : (isEstimatedPeriod
                          ? Border.all(color: AppColors.softRose.withValues(alpha: 0.5), width: 1)
                          : null)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: (isToday || isSelected || isConfirmedPeriod)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isConfirmedPeriod
                            ? Colors.white
                            : (isSelected ? AppColors.lavenderDark : null),
                      ),
                    ),
                    if (isEstimatedPeriod) ...[
                      const Text(
                        'EST',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softRoseDark,
                        ),
                      ),
                    ],
                  ],
                ),
                // Indicator dot for observations
                if (hasObservation)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isConfirmedPeriod ? Colors.white : AppColors.lavender,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _legendItem(
            color: AppColors.softRose,
            label: l10n.calendarConfirmedPeriod,
          ),
          _legendItem(
            color: AppColors.softRoseLight.withValues(alpha: 0.5),
            borderColor: AppColors.softRose,
            label: l10n.calendarEstimatedWindow,
          ),
          _legendItem(
            color: Colors.transparent,
            borderColor: AppColors.sage,
            label: l10n.calendarToday,
          ),
          _legendItem(
            dotColor: AppColors.lavender,
            label: l10n.calendarNotes,
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    Color? color,
    Color? borderColor,
    Color? dotColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dotColor != null)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          )
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color ?? Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
            ),
          ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildSelectedDateDetails(
    BuildContext context, {
    required ThemeData theme,
    required DateTime date,
    required CycleRecord? cycleRecord,
    required DailyObservation? observation,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDateUtils.formatFullDate(date),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (cycleRecord != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softRoseSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.softRoseLight),
                  ),
                  child: const Text(
                    'Confirmed Period',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.softRoseDark,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Period status & quick period record action
          if (cycleRecord == null) ...[
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PeriodEntryDialog(defaultDate: date),
                );
              },
              icon: const Icon(Icons.water_drop_outlined, size: 16, color: AppColors.softRose),
              label: const Text('Mark as Period Start Date'),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    cycleRecord.endDate != null
                        ? 'Period: ${AppDateUtils.formatShortDate(cycleRecord.startDate)} to ${AppDateUtils.formatShortDate(cycleRecord.endDate!)} (${cycleRecord.durationInDays} days)'
                        : 'Period started on ${AppDateUtils.formatShortDate(cycleRecord.startDate)} (Ongoing)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PeriodEntryDialog(initialRecord: cycleRecord),
                    );
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
          ],

          const Divider(height: 24),

          // Symptoms & Mood Observation details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Symptoms & Mood',
                style: theme.textTheme.titleSmall,
              ),
              TextButton.icon(
                onPressed: () {
                  LogObservationSheet.show(context, date: date, existing: observation);
                },
                icon: Icon(observation != null ? Icons.edit_outlined : Icons.add, size: 16),
                label: Text(observation != null ? 'Edit Log' : 'Add Log'),
              ),
            ],
          ),

          if (observation == null ||
              (observation.symptoms.isEmpty &&
                  observation.emotionalStates.isEmpty &&
                  (observation.note == null || observation.note!.isEmpty))) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No observations or shared notes recorded for this date.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ] else ...[
            if (observation.symptoms.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: observation.symptoms.map((s) {
                  return Chip(
                    backgroundColor: s.intensity.color.withValues(alpha: 0.2),
                    side: BorderSide(color: s.intensity.color.withValues(alpha: 0.5)),
                    avatar: Icon(s.type.icon, size: 14, color: s.intensity.color),
                    label: Text(
                      '${s.type.displayName} (${s.intensity.displayName})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (observation.emotionalStates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: observation.emotionalStates.map((e) {
                  return Chip(
                    backgroundColor: AppColors.lavenderSurface,
                    side: const BorderSide(color: AppColors.lavenderLight),
                    avatar: Icon(e.icon, size: 14, color: AppColors.lavenderDark),
                    label: Text(
                      e.displayName,
                      style: const TextStyle(fontSize: 11, color: AppColors.lavenderDark),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (observation.note != null && observation.note!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Note: ${observation.note!}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
