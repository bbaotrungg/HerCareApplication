import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/models/care_preference.dart';
import '../domain/models/personal_note.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  void _showAddPreferenceDialog({CarePreference? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    String selectedCategory = existing?.category ?? 'Favorite Comfort Foods & Drinks';
    final descController = TextEditingController(text: existing?.description ?? '');

    final categories = [
      'Favorite Comfort Foods & Drinks',
      'Preferred Menstrual Products',
      'Relaxation & Comfort Measures',
      'Things She Dislikes When Unwell',
      'General Preference',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing != null ? 'Edit Care Preference' : 'Add Care Preference'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Item or Preference Title',
                    hintText: 'e.g. Organic Chamomile Tea, Dark Chocolate',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Optional Details / Brand Preference',
                    hintText: 'e.g. Preferred brand, specific flavor or temperature',
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
                if (title.isEmpty) return;

                final pref = existing != null
                    ? existing.copyWith(
                        title: title,
                        category: selectedCategory,
                        description: descController.text.trim(),
                      )
                    : CarePreference(
                        title: title,
                        category: selectedCategory,
                        description: descController.text.trim(),
                      );

                ref.read(carePreferencesProvider.notifier).save(pref);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog({PersonalNote? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    String selectedCategory = existing?.category ?? 'General';
    final contentController = TextEditingController(text: existing?.content ?? '');

    final categories = ['General', 'Care Reminder', 'Shared Preference', 'Gift Idea'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing != null ? 'Edit Personal Note' : 'Add Personal Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Note Title',
                    hintText: 'e.g., Supplies in car, favorite blanket',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Record helpful notes shared voluntarily by your partner...',
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
                final content = contentController.text.trim();
                if (title.isEmpty && content.isEmpty) return;

                final note = existing != null
                    ? existing.copyWith(
                        title: title.isEmpty ? 'Untitled Note' : title,
                        category: selectedCategory,
                        content: content,
                      )
                    : PersonalNote(
                        title: title.isEmpty ? 'Untitled Note' : title,
                        category: selectedCategory,
                        content: content,
                      );

                ref.read(personalNotesProvider.notifier).save(note);
                Navigator.of(context).pop();
              },
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete({required String title, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = ref.watch(appLocalizationsProvider);
    final preferences = ref.watch(carePreferencesProvider).value ?? [];
    final notes = ref.watch(personalNotesProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.isVietnamese ? 'Ghi chú & Sở thích' : 'Notes & Preferences'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.lavender,
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor: theme.textTheme.bodySmall?.color,
          tabs: [
            Tab(text: l10n.tabPreferences, icon: const Icon(Icons.favorite_outline, size: 20)),
            Tab(text: l10n.tabPersonalNotes, icon: const Icon(Icons.notes_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Preferences
          _buildPreferencesList(theme, preferences),

          // Tab 2: Notes
          _buildNotesList(theme, notes),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddPreferenceDialog();
          } else {
            _showAddNoteDialog();
          }
        },
        backgroundColor: AppColors.lavender,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? l10n.btnAddPreference : l10n.btnAddNote),
      ),
    );
  }

  Widget _buildPreferencesList(ThemeData theme, List<CarePreference> preferences) {
    if (preferences.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 56, color: AppColors.softRose),
              const SizedBox(height: 16),
              Text('No Preferences Saved Yet', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Remember her preferred tea, snacks, comfort measures, or menstrual supply brands.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showAddPreferenceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Her First Preference'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: preferences.length,
      itemBuilder: (context, index) {
        final pref = preferences[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pref.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lavenderDark,
                    ),
                  ),
                ),
                Text(
                  pref.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: pref.description.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(pref.description, style: theme.textTheme.bodyMedium),
                  )
                : null,
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  _showAddPreferenceDialog(existing: pref);
                } else if (val == 'delete') {
                  _confirmDelete(
                    title: pref.title,
                    onConfirm: () => ref.read(carePreferencesProvider.notifier).delete(pref.id),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesList(ThemeData theme, List<PersonalNote> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note_outlined, size: 56, color: AppColors.lavender),
              const SizedBox(height: 16),
              Text('No Personal Notes Yet', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Save gentle reminders, gift ideas, or thoughts voluntarily shared by your partner.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showAddNoteDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create a Note'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.sageSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        note.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sageDark,
                        ),
                      ),
                    ),
                    Text(
                      AppDateUtils.formatShortDate(note.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showAddNoteDialog(existing: note),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        title: note.title,
                        onConfirm: () => ref.read(personalNotesProvider.notifier).delete(note.id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

