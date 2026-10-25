import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/hercare_logo.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showPrivacyNotice(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.isVietnamese
                        ? 'Quyền riêng tư, Đồng thuận & An toàn'
                        : 'Privacy, Consent & Safety',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              _buildPrivacySection(
                context,
                title: l10n.isVietnamese
                    ? 'Lưu trữ hoàn toàn cục bộ trên thiết bị'
                    : 'Strictly Local-Only Storage',
                content: l10n.isVietnamese
                    ? 'HerCare lưu trữ 100% dữ liệu chu kỳ, triệu chứng, ghi chú và sở thích hoàn toàn trong cơ sở dữ liệu SQLite riêng tư của ứng dụng. Không có máy chủ từ xa, không đồng bộ đám mây, không theo dõi và không quảng cáo.'
                    : 'HerCare stores 100% of cycle dates, symptoms, notes, and preferences strictly on this device inside Android application-private SQLite storage. There are no remote servers, no cloud sync, no analytics trackers, and no advertisements.',
              ),
              _buildPrivacySection(
                context,
                title: l10n.isVietnamese
                    ? 'Nguyên tắc đồng thuận của người thương'
                    : 'Partner Consent Principle',
                content: l10n.isVietnamese
                    ? 'Ứng dụng này dành cho những người đồng hành chu đáo. Mọi thông tin chỉ được ghi nhận khi có sự chia sẻ tự nguyện từ người thương. HerCare nghiêm cấm việc theo dõi lén lút hoặc giám sát bí mật.'
                    : 'This application is created for thoughtful partners. Information must only be recorded when voluntarily shared by your partner or discussed with her comfort. HerCare strictly prohibits covert tracking or surveillance.',
              ),
              _buildPrivacySection(
                context,
                title: l10n.isVietnamese
                    ? 'Giới hạn y khoa & An toàn'
                    : 'Medical Safety & Limitations',
                content: l10n.isVietnamese
                    ? 'HerCare là người bạn đồng hành chăm sóc và công cụ giáo dục, KHÔNG phải thiết bị y tế. Ứng dụng không đưa ra chẩn đoán y khoa, không dự đoán mang thai, không dùng để tránh thai. Tất cả các dự đoán đều là ước tính. Hãy khuyến khích cô ấy tham khảo ý kiến bác sĩ khi có triệu chứng bất thường.'
                    : 'HerCare is a personal care companion and educational tool, NOT a medical device. It does not provide medical diagnosis, predict pregnancy, act as contraception, or guarantee cycle timing. All cycle phases and windows are rule-based estimates. If your partner experiences severe or concerning symptoms, always encourage consulting a qualified physician.',
              ),
              _buildPrivacySection(
                context,
                title: l10n.isVietnamese ? 'Quyền xóa dữ liệu' : 'Right to Erase',
                content: l10n.isVietnamese
                    ? 'Nếu người thương của bạn không muốn lưu trữ dữ liệu nữa, hãy sử dụng tính năng "Xóa toàn bộ dữ liệu ứng dụng" bên dưới để xóa vĩnh viễn mọi dữ liệu.'
                    : 'If your partner prefers that records no longer be kept, use the "Clear All Application Data" feature below to immediately and irreversibly delete all local database tables.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPrivacySection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lavender,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final db = ref.read(databaseProvider);
    final jsonString = await db.exportDataJson();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.isVietnamese ? 'Xuất dữ liệu cục bộ (JSON)' : 'Export Local Data (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionClose),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.isVietnamese ? 'Đã sao chép dữ liệu vào bộ nhớ tạm' : 'Data copied to clipboard',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: Text(l10n.isVietnamese ? 'Sao chép JSON' : 'Copy JSON'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.isVietnamese ? 'Xóa toàn bộ dữ liệu ứng dụng?' : 'Clear All Application Data?'),
        content: Text(
          l10n.isVietnamese
              ? 'Hành động này sẽ xóa vĩnh viễn tất cả các ngày chu kỳ đã ghi nhận, triệu chứng, ghi chú cá nhân và sở thích khỏi thiết bị này.\n\nThao tác này không thể hoàn tác.'
              : 'This action will permanently delete all recorded period dates, symptom observations, personal notes, and preferences from this device.\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(databaseProvider).clearAllData();
              await ref.read(cycleRecordsProvider.notifier).loadRecords();
              await ref.read(dailyObservationsProvider.notifier).loadObservations();
              await ref.read(personalNotesProvider.notifier).loadNotes();
              await ref.read(carePreferencesProvider.notifier).loadPreferences();
              await ref.read(remindersProvider.notifier).loadReminders();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.isVietnamese
                          ? 'Toàn bộ dữ liệu cục bộ đã được xóa vĩnh viễn.'
                          : 'All local data has been permanently cleared.',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.isVietnamese ? 'Xóa tất cả' : 'Yes, Erase Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final l10n = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Language Settings (English & Vietnamese)
          Text(l10n.settingsLanguageSection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                _buildLanguageTile(
                  context: context,
                  title: l10n.settingsLangEnglish,
                  subtitle: l10n.settingsLangEnglishSub,
                  value: AppLanguage.en,
                  groupValue: settings.language,
                  onChanged: (lang) => ref.read(appSettingsProvider.notifier).setLanguage(lang),
                ),
                const Divider(height: 1),
                _buildLanguageTile(
                  context: context,
                  title: l10n.settingsLangVietnamese,
                  subtitle: l10n.settingsLangVietnameseSub,
                  value: AppLanguage.vi,
                  groupValue: settings.language,
                  onChanged: (lang) => ref.read(appSettingsProvider.notifier).setLanguage(lang),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Theme Selection
          Text(l10n.settingsThemeSection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                _buildThemeTile(
                  context: context,
                  title: l10n.themeSystem,
                  subtitle: l10n.themeSystemSub,
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (mode) => ref.read(appSettingsProvider.notifier).setThemeMode(mode),
                ),
                const Divider(height: 1),
                _buildThemeTile(
                  context: context,
                  title: l10n.themeLight,
                  subtitle: l10n.themeLightSub,
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (mode) => ref.read(appSettingsProvider.notifier).setThemeMode(mode),
                ),
                const Divider(height: 1),
                _buildThemeTile(
                  context: context,
                  title: l10n.themeDark,
                  subtitle: l10n.themeDarkSub,
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (mode) => ref.read(appSettingsProvider.notifier).setThemeMode(mode),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Personalization
          Text(l10n.settingsPartnerSection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.partnerNameLabel,
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: settings.partnerName,
                  decoration: InputDecoration(
                    hintText: l10n.partnerNameHint,
                    prefixIcon: const Icon(Icons.favorite_outline),
                  ),
                  onChanged: (val) {
                    ref.read(appSettingsProvider.notifier).setPartnerName(val.trim());
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Privacy & Ethics
          Text(l10n.settingsPrivacySection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppColors.lavender),
                  title: Text(l10n.privacyNoticeTile),
                  subtitle: Text(l10n.privacyNoticeSub),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyNotice(context, l10n),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.sage),
                  title: Text(l10n.exportDataTile),
                  subtitle: Text(l10n.exportDataSub),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportData(context, ref, l10n),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. Data Management & Erase
          Text(l10n.settingsDataSection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
              title: Text(l10n.clearDataTile, style: const TextStyle(color: Colors.red)),
              subtitle: Text(l10n.clearDataSub),
              onTap: () => _confirmClearData(context, ref, l10n),
            ),
          ),

          const SizedBox(height: 32),

          // 6. About & App Version Info
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const HerCareLogo(size: 40),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.sageSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 14, color: AppColors.sageDark),
                      const SizedBox(width: 6),
                      Text(
                        l10n.offlinePrivateBadge,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sageDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'HerCare v1.0.0',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required AppLanguage value,
    required AppLanguage groupValue,
    required ValueChanged<AppLanguage> onChanged,
  }) {
    final isSelected = value == groupValue;
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.lavender)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () => onChanged(value),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode> onChanged,
  }) {
    final isSelected = value == groupValue;
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.lavender)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () => onChanged(value),
    );
  }
}
