import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/models/reminder_item.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  void _showAddCustomReminderDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final messageController = TextEditingController(
      text: 'Thoughtful moment: check in on how she feels today.',
    );
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Care Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Reminder Title',
                    hintText: 'e.g. Evening tea check-in',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: messageController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Discreet Notification Text',
                    hintText: 'Text shown on lock screen (keep considerate & private)',
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Reminder Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setDialogState(() => selectedTime = picked);
                      }
                    },
                    child: const Text('Change'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final msg = messageController.text.trim();
                if (title.isEmpty) return;

                final item = ReminderItem(
                  title: title,
                  discreetMessage: msg.isEmpty ? 'Thoughtful care reminder.' : msg,
                  type: ReminderType.custom,
                  hour: selectedTime.hour,
                  minute: selectedTime.minute,
                  isEnabled: true,
                );

                ref.read(remindersProvider.notifier).save(item);
                Navigator.of(context).pop();
              },
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = ref.watch(appLocalizationsProvider);
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.remindersTitle),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Discreet privacy guarantee card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lavenderSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lavenderLight.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.lavenderDark, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.isVietnamese
                                ? 'Thông báo kín đáo & Tinh tế'
                                : 'Discreet & Respectful Notifications',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.lavenderDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.isVietnamese
                                ? 'Thông báo của HerCare không bao giờ hiển thị giai đoạn chu kỳ hay thuật ngữ nhạy cảm trên màn hình khóa. Chúng chỉ xuất hiện như những lời nhắc quan tâm nhẹ nhàng.'
                                : 'HerCare notifications never display sensitive cycle phases or symptom terms on the lock screen. They appear as gentle, considerate prompts.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.lavenderDark.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.isVietnamese ? 'Lời nhắc đang hoạt động' : 'Active Reminders',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              ...reminders.map((reminder) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: reminder.isEnabled
                            ? AppColors.lavenderSurface
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        reminder.type.icon,
                        color: reminder.isEnabled ? AppColors.lavender : theme.disabledColor,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      reminder.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${reminder.formattedTime} • "${reminder.discreetMessage}"',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Switch(
                      value: reminder.isEnabled,
                      activeThumbColor: AppColors.lavender,
                      onChanged: (val) {
                        ref.read(remindersProvider.notifier).toggleReminder(reminder, val);
                      },
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showAddCustomReminderDialog(context, ref),
                icon: const Icon(Icons.add_alarm),
                label: Text(l10n.btnAddReminder),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading reminders: $e')),
      ),
    );
  }
}
