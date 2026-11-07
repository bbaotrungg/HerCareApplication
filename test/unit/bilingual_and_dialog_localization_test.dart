import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/core/localization/app_language.dart';
import 'package:hercare/core/localization/app_localizations.dart';
import 'package:hercare/features/education/data/curated_tips.dart';
import 'package:hercare/features/education/domain/models/educational_tip.dart';

void main() {
  group('Bilingual Curated Educational Tips Tests', () {
    test('all curated tips contain both English and Vietnamese title, summary, and content', () {
      expect(CuratedTips.allTips.length, greaterThanOrEqualTo(7));

      for (final tip in CuratedTips.allTips) {
        // English
        expect(tip.localizedTitle(false), isNotEmpty);
        expect(tip.localizedSummary(false), isNotEmpty);
        expect(tip.localizedContent(false), isNotEmpty);
        expect(tip.localizedActionablePoints(false), isNotEmpty);

        // Vietnamese
        expect(tip.localizedTitle(true), isNotEmpty);
        expect(tip.localizedSummary(true), isNotEmpty);
        expect(tip.localizedContent(true), isNotEmpty);
        expect(tip.localizedActionablePoints(true), isNotEmpty);

        // Titles should differ between languages
        expect(tip.localizedTitle(true), isNot(equals(tip.localizedTitle(false))));
        expect(tip.localizedSummary(true), isNot(equals(tip.localizedSummary(false))));
      }
    });

    test('TipCategory provides localized category names for English and Vietnamese', () {
      for (final cat in TipCategory.values) {
        final enName = cat.localizedName(false);
        final viName = cat.localizedName(true);

        expect(enName, isNotEmpty);
        expect(viName, isNotEmpty);
        expect(enName, isNot(equals(viName)));
      }
    });
  });

  group('PeriodEntryDialog & Observation Localization Keys Parity', () {
    const l10nEn = AppLocalizations(AppLanguage.en);
    const l10nVi = AppLocalizations(AppLanguage.vi);

    test('PeriodEntryDialog has complete English and Vietnamese strings', () {
      expect(l10nEn.periodDialogTitleRecord, 'Record Actual Period');
      expect(l10nVi.periodDialogTitleRecord, 'Ghi nhận ngày đầu kỳ kinh');

      expect(l10nEn.periodDialogTitleEdit, 'Edit Period Record');
      expect(l10nVi.periodDialogTitleEdit, 'Chỉnh sửa kỳ kinh');

      expect(l10nEn.periodDialogStartDate, 'Period Start Date');
      expect(l10nVi.periodDialogStartDate, 'Ngày bắt đầu kỳ kinh');

      expect(l10nEn.periodDialogEndDate, 'Period End Date');
      expect(l10nVi.periodDialogEndDate, 'Ngày kết thúc kỳ kinh');

      expect(l10nEn.periodDialogOngoing, contains('ongoing'));
      expect(l10nVi.periodDialogOngoing, contains('đang diễn ra'));

      expect(l10nEn.periodDialogSaveRecord, 'Save Record');
      expect(l10nVi.periodDialogSaveRecord, 'Lưu bản ghi');
    });

    test('Observation sheet has complete English and Vietnamese strings', () {
      expect(l10nEn.obsSheetTitle, 'Log Symptoms & Mood');
      expect(l10nVi.obsSheetTitle, 'Ghi nhận triệu chứng & tâm trạng');

      expect(l10nEn.obsSheetSharedByHer, 'Shared by her');
      expect(l10nVi.obsSheetSharedByHer, 'Cô ấy chia sẻ');

      expect(l10nEn.obsSheetSevereWarning, contains('medical advice'));
      expect(l10nVi.obsSheetSevereWarning, contains('bác sĩ'));

      expect(l10nEn.obsSheetSave, 'Save Log');
      expect(l10nVi.obsSheetSave, 'Lưu ghi nhận');
    });

    test('Notes & preferences dialogs have complete English and Vietnamese strings', () {
      expect(l10nEn.prefDialogAddTitle, 'Add Care Preference');
      expect(l10nVi.prefDialogAddTitle, 'Thêm sở thích chăm sóc');

      expect(l10nEn.noteDialogAddTitle, 'Add Personal Note');
      expect(l10nVi.noteDialogAddTitle, 'Thêm ghi chú cá nhân');

      expect(l10nEn.emptyPreferencesTitle, 'No Care Preferences Yet');
      expect(l10nVi.emptyPreferencesTitle, 'Chưa có sở thích nào được lưu');
    });
  });
}
