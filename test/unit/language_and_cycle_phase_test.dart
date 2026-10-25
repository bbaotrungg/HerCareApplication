import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/core/localization/app_language.dart';
import 'package:hercare/core/localization/app_localizations.dart';
import 'package:hercare/core/providers/app_providers.dart';
import 'package:hercare/features/care/domain/services/recommendation_engine.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_record.dart';
import 'package:hercare/features/cycle_tracking/domain/services/cycle_calculation_engine.dart';
import 'package:hercare/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hercare/features/settings/domain/models/app_settings.dart';
import 'package:hercare/features/settings/presentation/settings_screen.dart';
import 'package:hercare/features/symptoms/domain/services/symptom_mood_estimation_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Language Settings & Localization Unit Tests', () {
    test('AppLanguage default and code mapping', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.en);
      expect(AppLanguage.fromCode('vi'), AppLanguage.vi);
      expect(AppLanguage.fromCode('unknown'), AppLanguage.en);
      expect(AppLanguage.fromCode(null), AppLanguage.en);

      expect(AppLanguage.en.code, 'en');
      expect(AppLanguage.vi.code, 'vi');
      expect(AppLanguage.en.nativeName, 'English');
      expect(AppLanguage.vi.nativeName, 'Tiếng Việt');
    });

    test('AppLocalizations provides complete translations in both EN and VI', () {
      final en = AppLocalizations.ofLanguage(AppLanguage.en);
      final vi = AppLocalizations.ofLanguage(AppLanguage.vi);

      // Verify 4 phase names in English
      expect(en.phaseMenstrualName, 'Menstrual Phase');
      expect(en.phaseFollicularName, 'Follicular Phase');
      expect(en.phaseOvulationName, 'Ovulation Phase');
      expect(en.phaseLutealName, 'Luteal Phase');

      // Verify 4 phase names in Vietnamese
      expect(vi.phaseMenstrualName, 'Giai đoạn kinh nguyệt');
      expect(vi.phaseFollicularName, 'Giai đoạn nang trứng');
      expect(vi.phaseOvulationName, 'Giai đoạn rụng trứng');
      expect(vi.phaseLutealName, 'Giai đoạn hoàng thể');

      // Descriptions
      expect(en.phaseMenstrualDesc, contains('menstruation'));
      expect(vi.phaseMenstrualDesc, contains('kinh nguyệt'));
      expect(en.phaseFollicularDesc, contains('Estrogen'));
      expect(vi.phaseFollicularDesc, contains('estrogen'));
      expect(en.phaseOvulationDesc, contains('mid-cycle'));
      expect(vi.phaseOvulationDesc, contains('giữa chu kỳ'));
      expect(en.phaseLutealDesc, contains('Progesterone'));
      expect(vi.phaseLutealDesc, contains('Progesterone'));

      // Navigation
      expect(en.navDashboard, 'Dashboard');
      expect(vi.navDashboard, 'Trang chủ');
      expect(en.navCalendar, 'Calendar');
      expect(vi.navCalendar, 'Lịch');
      expect(en.navCare, 'Care');
      expect(vi.navCare, 'Chăm sóc');
      expect(en.navNotes, 'Notes');
      expect(vi.navNotes, 'Ghi chú');

      // Cycle day formatting
      expect(en.cycleDay(5), 'Day 5 of current cycle');
      expect(vi.cycleDay(5), 'Ngày 5 của chu kỳ');
      expect(en.cycleDayBadge(5), 'Cycle Day: 5');
      expect(vi.cycleDayBadge(5), 'Ngày chu kỳ: 5');

      // Estimation notices
      expect(en.estimateNoticeHeadline, 'Estimated Phase');
      expect(vi.estimateNoticeHeadline, 'Ước tính theo chu kỳ');
      expect(en.estimateNoticeDescription, contains('estimates'));
      expect(vi.estimateNoticeDescription, contains('ước tính'));
    });
  });

  group('Cycle Phase Calculation & Multi-Language Support Tests', () {
    const engine = CycleCalculationEngine();
    final today = DateTime(2026, 10, 25);

    test('calculates Menstrual Phase for day 1-5', () {
      final records = [
        CycleRecord(id: '1', startDate: today.subtract(const Duration(days: 2))), // Day 3
      ];
      final estimate = engine.calculate(records: records, referenceDate: today);

      expect(estimate.currentEstimatedPhase, CyclePhase.menstrual);
      expect(estimate.dayOfCycle, 3);
      expect(estimate.currentEstimatedPhase.localizedName(AppLanguage.en), 'Menstrual Phase');
      expect(estimate.currentEstimatedPhase.localizedName(AppLanguage.vi), 'Giai đoạn kinh nguyệt');
      expect(estimate.currentEstimatedPhase.localizedExplanation(AppLanguage.en), contains('uterine'));
      expect(estimate.currentEstimatedPhase.localizedExplanation(AppLanguage.vi), contains('tử cung'));
    });

    test('calculates Follicular Phase after menstruation (e.g. day 8)', () {
      final records = [
        CycleRecord(id: '1', startDate: today.subtract(const Duration(days: 7))), // Day 8
      ];
      final estimate = engine.calculate(records: records, referenceDate: today);

      expect(estimate.currentEstimatedPhase, CyclePhase.follicular);
      expect(estimate.dayOfCycle, 8);
      expect(estimate.currentEstimatedPhase.localizedName(AppLanguage.en), 'Follicular Phase');
      expect(estimate.currentEstimatedPhase.localizedName(AppLanguage.vi), 'Giai đoạn nang trứng');
      expect(estimate.currentEstimatedPhase.localizedExplanation(AppLanguage.en), contains('Estrogen'));
      expect(estimate.currentEstimatedPhase.localizedExplanation(AppLanguage.vi), contains('estrogen'));
    });

    test('calculates Ovulation Phase for mid-cycle (e.g. day 14)', () {
      final records = [
        CycleRecord(id: '1', startDate: today.subtract(const Duration(days: 13))), // Day 14
      ];
      final estimate = engine.calculate(records: records, referenceDate: today);

      expect(estimate.currentEstimatedPhase, CyclePhase.ovulatory);
      expect(estimate.dayOfCycle, 14);
      expect(estimate.currentEstimatedPhase.localizedName(AppLanguage.en), 'Ovulation Phase');
      expect(estimate.currentEstimatedPhase.localizedName(AppLanguage.vi), 'Giai đoạn rụng trứng');
      expect(estimate.currentEstimatedPhase.localizedExplanation(AppLanguage.en), contains('mid-cycle'));
      expect(estimate.currentEstimatedPhase.localizedExplanation(AppLanguage.vi), contains('giữa chu kỳ'));
    });

    test('calculates Luteal Phase for late cycle (e.g. day 22)', () {
      final records = [
        CycleRecord(id: '1', startDate: today.subtract(const Duration(days: 21))), // Day 22
      ];
      final estimate = engine.calculate(records: records, referenceDate: today);

      expect(estimate.currentEstimatedPhase, CyclePhase.luteal);
      expect(estimate.dayOfCycle, 22);
      expect(estimate.currentEstimatedPhase.localizedName(AppLanguage.en), 'Luteal Phase');
      expect(estimate.currentEstimatedPhase.localizedName(AppLanguage.vi), 'Giai đoạn hoàng thể');
      expect(estimate.currentEstimatedPhase.localizedExplanation(AppLanguage.en), contains('Progesterone'));
      expect(estimate.currentEstimatedPhase.localizedExplanation(AppLanguage.vi), contains('Progesterone'));
    });

    test('indicates estimates and limited information when 1 record exists', () {
      final records = [
        CycleRecord(id: '1', startDate: today.subtract(const Duration(days: 2))),
      ];
      final estimate = engine.calculate(records: records, referenceDate: today);

      expect(estimate.reliability, EstimateReliability.limitedInformation);
      expect(estimate.isLimitedHistory, isTrue);
      expect(estimate.reliability.localizedBadgeLabel(AppLanguage.en), 'General Baseline');
      expect(estimate.reliability.localizedBadgeLabel(AppLanguage.vi), 'Chu kỳ mẫu (28 ngày)');
      expect(estimate.localizedExplanationMessage(AppLanguage.en), contains('baseline'));
      expect(estimate.localizedExplanationMessage(AppLanguage.vi), contains('chu kỳ mẫu'));
    });
  });

  group('Symptom & Recommendation Engines Multi-Language Output', () {
    const symptomEngine = SymptomMoodEstimationEngine();
    const recEngine = RecommendationEngine();

    test('generates Vietnamese symptoms & mood possibilities', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.cycleInformed,
        averageCycleLength: 28,
        variabilityDays: 2,
        currentEstimatedPhase: CyclePhase.menstrual,
        dayOfCycle: 2,
        recordedCyclesCount: 3,
        statusTitle: 'Cycle-Informed',
        explanationMessage: 'Valid',
      );

      final viEstimate = symptomEngine.estimate(cycleEstimate: estimate, language: AppLanguage.vi);
      expect(viEstimate.physicalPossibilities.first.label, 'Đau tức bụng kinh');
      expect(viEstimate.physicalPossibilities.first.naturalExplanation, contains('Tử cung co bóp'));
      expect(viEstimate.confidenceBadge, 'Theo dõi chu kỳ');
      expect(viEstimate.transparentNotice, contains('Ước tính'));
    });

    test('generates Vietnamese care recommendations matching estimated context', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.cycleInformed,
        averageCycleLength: 28,
        variabilityDays: 2,
        currentEstimatedPhase: CyclePhase.menstrual,
        dayOfCycle: 2,
        recordedCyclesCount: 3,
        statusTitle: 'Cycle-Informed',
        explanationMessage: 'Valid',
      );

      final viSymptom = symptomEngine.estimate(cycleEstimate: estimate, language: AppLanguage.vi);
      final recs = recEngine.generateRecommendations(
        symptomMoodEstimate: viSymptom,
        cycleEstimate: estimate,
        language: AppLanguage.vi,
      );

      final heatRec = recs.firstWhere((r) => r.id == 'care_cramps_heat');
      expect(heatRec.naturalThought, contains('túi chườm'));
      expect(heatRec.gentleContext, contains('Nhiệt ấm'));
      expect(heatRec.contextBasis, 'Có thể đau tức bụng hôm nay');
    });
  });

  group('Widget Tests: Language Switching & Phase Card Display', () {
    testWidgets('Settings Screen displays Language option with English and Vietnamese',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Language Settings section is displayed
      expect(find.text('Language Settings'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Tiếng Việt'), findsOneWidget);

      // Tap Tiếng Việt to switch language
      await tester.tap(find.text('Tiếng Việt'));
      await tester.pumpAndSettle();

      // Verify interface updates immediately to Vietnamese
      expect(find.text('Cài đặt & Quyền riêng tư'), findsOneWidget);
      expect(find.text('Cài đặt ngôn ngữ'), findsOneWidget);
      expect(find.text('Giao diện & Hiển thị'), findsOneWidget);
      expect(find.text('Cá nhân hóa'), findsOneWidget);
    });

    testWidgets('Dashboard renders cycle phase name, cycle day, and description in Vietnamese',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'setting_language_code': 'vi',
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith(() => MockViSettingsNotifier()),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Vietnamese headers and phase card
      expect(find.text('Triệu chứng & Tâm trạng có thể xuất hiện hôm nay'), findsOneWidget);
      expect(find.text('Gợi ý chăm sóc hôm nay'), findsOneWidget);
      expect(find.text('Chờ dữ liệu'), findsNWidgets(2)); // Phase title & reliability badge

      final quickInput = find.text('Ghi nhận nhanh chu kỳ');
      await tester.scrollUntilVisible(quickInput, 100);
      expect(quickInput, findsOneWidget);
    });
  });
}

class MockViSettingsNotifier extends AppSettingsNotifier {
  @override
  AppSettings build() {
    return const AppSettings(
      language: AppLanguage.vi,
      partnerName: 'Mai',
    );
  }
}
