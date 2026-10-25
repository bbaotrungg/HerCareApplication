import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/models/daily_observation.dart';
import '../domain/models/emotional_state.dart';
import '../domain/models/symptom_type.dart';

class LogObservationSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final DailyObservation? existingObservation;

  const LogObservationSheet({
    super.key,
    required this.initialDate,
    this.existingObservation,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    DailyObservation? existing,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => LogObservationSheet(
        initialDate: date,
        existingObservation: existing,
      ),
    );
  }

  @override
  ConsumerState<LogObservationSheet> createState() => _LogObservationSheetState();
}

class _LogObservationSheetState extends ConsumerState<LogObservationSheet> {
  late DateTime _selectedDate;
  late ObservationSource _source;
  final Map<SymptomType, SymptomIntensity> _selectedSymptoms = {};
  final Set<EmotionalState> _selectedEmotions = {};
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _selectedDate = AppDateUtils.dateOnly(widget.initialDate);
    _source = widget.existingObservation?.source ?? ObservationSource.reportedByPartner;
    _noteController = TextEditingController(text: widget.existingObservation?.note ?? '');

    if (widget.existingObservation != null) {
      for (final s in widget.existingObservation!.symptoms) {
        _selectedSymptoms[s.type] = s.intensity;
      }
      _selectedEmotions.addAll(widget.existingObservation!.emotionalStates);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final symptomsList = _selectedSymptoms.entries
        .map((e) => SymptomEntry(type: e.key, intensity: e.value))
        .toList();

    final obs = widget.existingObservation != null
        ? widget.existingObservation!.copyWith(
            date: _selectedDate,
            symptoms: symptomsList,
            emotionalStates: _selectedEmotions.toList(),
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
            source: _source,
          )
        : DailyObservation(
            date: _selectedDate,
            symptoms: symptomsList,
            emotionalStates: _selectedEmotions.toList(),
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
            source: _source,
          );

    ref.read(dailyObservationsProvider.notifier).save(obs);
    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.existingObservation != null) {
      ref.read(dailyObservationsProvider.notifier).delete(widget.existingObservation!.id);
    }
    Navigator.of(context).pop();
  }

  bool get _hasSevereSymptom =>
      _selectedSymptoms.values.any((intensity) => intensity == SymptomIntensity.severe);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag Handle & Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Log Symptoms & Mood',
                        style: theme.textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form Body
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Date and Source Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 7)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = AppDateUtils.dateOnly(picked));
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(AppDateUtils.formatShortDate(_selectedDate)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<ObservationSource>(
                          initialValue: _source,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          items: ObservationSource.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s == ObservationSource.reportedByPartner
                                    ? 'Shared by her'
                                    : 'Observed & discussed',
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _source = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Severe Symptom Safety Notice
                  if (_hasSevereSymptom) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.softRoseSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.softRoseLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.softRoseDark, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Gentle note: Severe pain can be debilitating. Always encourage seeking professional medical advice if pain is intense or persistent.',
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.softRoseDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Physical Symptoms Section
                  Text(
                    'Physical Sensations Shared',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to select and configure intensity (Mild, Moderate, Severe)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SymptomType.values.map((type) {
                      final isSelected = _selectedSymptoms.containsKey(type);
                      final intensity = _selectedSymptoms[type] ?? SymptomIntensity.mild;

                      return FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        avatar: Icon(
                          type.icon,
                          size: 16,
                          color: isSelected ? Colors.white : theme.iconTheme.color,
                        ),
                        label: Text(
                          isSelected ? '${type.displayName} (${intensity.displayName})' : type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        selectedColor: intensity.color,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSymptoms[type] = SymptomIntensity.mild;
                            } else {
                              _selectedSymptoms.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  // Intensity Adjuster for Selected Symptoms
                  if (_selectedSymptoms.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adjust Intensity for Selected:',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          ..._selectedSymptoms.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key.displayName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SegmentedButton<SymptomIntensity>(
                                    segments: SymptomIntensity.values.map((i) {
                                      return ButtonSegment(
                                        value: i,
                                        label: Text(i.displayName, style: const TextStyle(fontSize: 11)),
                                      );
                                    }).toList(),
                                    selected: {entry.value},
                                    onSelectionChanged: (set) {
                                      setState(() {
                                        _selectedSymptoms[entry.key] = set.first;
                                      });
                                    },
                                    style: ButtonStyle(
                                      visualDensity: VisualDensity.compact,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Emotional State Section
                  Text(
                    'Emotional Experience Voluntarily Shared',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Never assume emotions are caused solely by cycles; every person feels differently.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: EmotionalState.values.map((emotion) {
                      final isSelected = _selectedEmotions.contains(emotion);

                      return FilterChip(
                        selected: isSelected,
                        avatar: Icon(
                          emotion.icon,
                          size: 16,
                          color: isSelected ? Colors.white : theme.iconTheme.color,
                        ),
                        label: Text(
                          emotion.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        selectedColor: AppColors.lavender,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedEmotions.add(emotion);
                            } else {
                              _selectedEmotions.remove(emotion);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Optional Personal Note
                  Text(
                    'Optional Personal Note',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g., She enjoyed hot chamomile tea and requested an early quiet night.',
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  if (widget.existingObservation != null) ...[
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete observation',
                      onPressed: _delete,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Log'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
