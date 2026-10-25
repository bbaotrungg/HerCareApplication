import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/symptoms/domain/models/daily_symptom_mood_estimate.dart';
import 'package:hercare/features/symptoms/domain/models/symptom_possibility.dart';

/// Pure, deterministic engine that estimates possible physical sensations and
/// emotional experiences based strictly on estimated cycle timing.
///
/// Communicates uncertainty transparently in English and Vietnamese.
/// Never claims to know how she actually feels, nor does it store inferred states
/// as confirmed historical data.
class SymptomMoodEstimationEngine {
  const SymptomMoodEstimationEngine();

  DailySymptomMoodEstimate estimate({
    required CycleEstimate cycleEstimate,
    AppLanguage language = AppLanguage.en,
  }) {
    final phase = cycleEstimate.currentEstimatedPhase;
    final day = cycleEstimate.dayOfCycle;
    final reliability = cycleEstimate.reliability;
    final isVi = language == AppLanguage.vi;

    if (reliability == EstimateReliability.insufficient || day == null) {
      return DailySymptomMoodEstimate(
        currentPhase: CyclePhase.uncertain,
        dayOfCycle: null,
        physicalPossibilities: const [],
        emotionalPossibilities: const [],
        reliability: reliability,
        confidenceBadge: reliability.localizedBadgeLabel(language),
        transparentNotice: isVi
            ? 'Hãy ghi nhận ngày bắt đầu kỳ kinh gần nhất để xem ước tính các biểu hiện thể chất và cảm xúc.'
            : 'Record the start date of her most recent period to see estimated physical and emotional possibilities.',
      );
    }

    final physicalList = <SymptomPossibility>[];
    final emotionalList = <SymptomPossibility>[];

    switch (phase) {
      case CyclePhase.menstrual:
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Đau tức bụng kinh' : 'Abdominal Cramps',
          naturalExplanation: isVi
              ? 'Tử cung co bóp nhẹ nhàng để đẩy niêm mạc có thể gây đau tức hoặc nhói nhẹ vùng bụng dưới.'
              : 'Gentle uterine contractions to shed lining can cause pelvic cramping or aching.',
          icon: Icons.waves,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thường gặp trong kỳ kinh' : 'Common during menstruation',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Năng lượng thấp hoặc mệt mỏi' : 'Lower Energy or Fatigue',
          naturalExplanation: isVi
              ? 'Nội tiết tố ở mức cơ bản; thể lực và sức bền tự nhiên có phần giảm sút.'
              : 'Hormone levels are at baseline; physical stamina is often naturally reduced.',
          icon: Icons.battery_2_bar_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thường thấy ở những ngày đầu chu kỳ' : 'Often noticed in early cycle days',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Căng mỏi thắt lưng' : 'Lower Back Discomfort',
          naturalExplanation: isVi
              ? 'Căng tức vùng chậu đôi khi có thể lan ra các dây chằng lưng dưới.'
              : 'Pelvic tension can occasionally radiate toward the lower back ligaments.',
          icon: Icons.accessibility_new_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Có thể xuất hiện khi hành kinh' : 'Possible during bleeding days',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cảm giác thoải mái, ít khó chịu' : 'Little or No Discomfort',
          naturalExplanation: isVi
              ? 'Nhiều người chỉ cảm thấy hơi nhẹ hoặc hoàn toàn bình thường.'
              : 'Many people experience only minor sensations or feel physically fine.',
          icon: Icons.check_circle_outline,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Trải nghiệm cá nhân khác nhau' : 'Individual experiences vary',
        ));

        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Nhu cầu nghỉ ngơi nhiều hơn' : 'Wanting Extra Rest',
          naturalExplanation: isVi
              ? 'Khuynh hướng sinh học tự nhiên muốn chậm lại và phục hồi năng lượng thể chất.'
              : 'A natural biological inclination to slow down and restore physical reserves.',
          icon: Icons.bedtime_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Nhu cầu phổ biến trong kỳ kinh' : 'Common need during menstruation',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Cần sự ân cần & sẻ chia' : 'Appreciating Comfort & Support',
          naturalExplanation: isVi
              ? 'Sự đồng hành nhẹ nhàng, tách trà nóng và bầu không khí thoải mái mang lại cảm giác an tâm.'
              : 'Gentle presence, hot tea, and low-pressure company often feel especially reassuring.',
          icon: Icons.favorite_outline,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Sẽ rất thích sự quan tâm nhẹ nhàng' : 'May welcome gentle care',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Cảm xúc ổn định' : 'Emotionally Steady',
          naturalExplanation: isVi
              ? 'Cô ấy có thể cảm thấy hoàn toàn cân bằng và vui vẻ.'
              : 'She may feel completely balanced and in good spirits.',
          icon: Icons.sentiment_satisfied_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Trải nghiệm cá nhân khác nhau' : 'Varied personal experience',
        ));
        break;

      case CyclePhase.follicular:
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Thể lực & năng lượng tăng' : 'Rising Energy & Lightness',
          naturalExplanation: isVi
              ? 'Nồng độ estrogen tăng dần thúc đẩy mức năng lượng và sức bền thể chất.'
              : 'Gradually increasing estrogen tends to boost energy and physical resilience.',
          icon: Icons.bolt_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Điển hình cho giai đoạn nang trứng' : 'Typical follicular phase lift',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Tinh thần minh mẫn & tập trung' : 'Clear Head & Focus',
          naturalExplanation: isVi
              ? 'Sau khi hết kinh, sự tập trung và sảng khoái tinh thần thường tăng cao.'
              : 'Post-bleeding days often bring renewed clarity and lower physical strain.',
          icon: Icons.lightbulb_outline,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thường thấy vào giữa chu kỳ' : 'Common mid-cycle pattern',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cơ thể thoải mái, ổn định' : 'Steady Comfort',
          naturalExplanation: isVi
              ? 'Rất ít hoặc không có triệu chứng khó chịu; một giai đoạn dễ chịu trong chu kỳ.'
              : 'Minimal or no cycle-related physical discomfort; a comfortable phase.',
          icon: Icons.sentiment_satisfied_alt_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Giai đoạn thoải mái nhất' : 'Usually a comfortable window',
        ));

        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Cảm xúc cân bằng, lạc quan' : 'Emotionally Balanced',
          naturalExplanation: isVi
              ? 'Nội tiết tố ổn định hỗ trợ tâm trạng tích cực, kiên nhẫn và thoải mái.'
              : 'Balanced hormones support an upbeat, patient, and grounded outlook.',
          icon: Icons.mood_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thường có tâm trạng tốt' : 'Frequent positive baseline',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Vui vẻ, hào hứng kết nối' : 'Upbeat & Sociable',
          naturalExplanation: isVi
              ? 'Thời điểm lý tưởng để trò chuyện, lên kế hoạch cho các buổi đi chơi hoặc hoạt động chung.'
              : 'Often a pleasant time for engaging conversations and shared activities.',
          icon: Icons.groups_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Rất thích hợp cho các hoạt động chung' : 'Great time for shared plans',
        ));
        break;

      case CyclePhase.ovulatory:
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Năng lượng & sức sống đỉnh cao' : 'Peak Vitality & Energy',
          naturalExplanation: isVi
              ? 'Estrogen đạt đỉnh vào khoảng giữa chu kỳ, thường mang lại sự hoạt bát và tươi mới.'
              : 'Estrogen peaks around mid-cycle, often accompanied by high vitality and freshness.',
          icon: Icons.wb_sunny_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Khoảng giữa chu kỳ' : 'Mid-cycle transition window',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cảm giác lâm râm vùng bụng dưới' : 'Mild Mid-Cycle Sensation',
          naturalExplanation: isVi
              ? 'Một số phụ nữ cảm thấy nhói nhẹ hoặc căng thoáng qua ở vùng chậu (mittelschmerz).'
              : 'Some experience a brief, gentle twinge or awareness on one pelvic side.',
          icon: Icons.adjust_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Khả năng xuất hiện khi rụng trứng' : 'Possible ovulatory sensation',
        ));

        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Tinh thần phấn chấn, cởi mở' : 'High Sociability & Expressiveness',
          naturalExplanation: isVi
              ? 'Sự tự tin và hào hứng giao tiếp thường ở mức cao nhất.'
              : 'Confidence and warmth in communication are frequently elevated.',
          icon: Icons.sentiment_very_satisfied_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thường thấy ở đỉnh nội tiết' : 'Common hormone peak mood',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Tự tin & giao tiếp tích cực' : 'Communicative & Confident',
          naturalExplanation: isVi
              ? 'Thường hào hứng chia sẻ, kết nối và khám phá những ý tưởng mới.'
              : 'Often eager to connect, express thoughts, and enjoy shared moments.',
          icon: Icons.record_voice_over_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Dấu hiệu giao tiếp tích cực' : 'Positive communication marker',
        ));
        break;

      case CyclePhase.luteal:
        final cycleLength = cycleEstimate.averageCycleLength ?? 28.0;
        final isLateLuteal = day > (cycleLength - 7);

        if (isLateLuteal) {
          physicalList.add(SymptomPossibility(
            label: isVi ? 'Đầy hơi hoặc giữ nước' : 'Bloating or Fullness',
            naturalExplanation: isVi
              ? 'Nội tiết tố progesterone chuẩn bị cho kỳ kinh có thể gây cảm giác tức hoặc chướng bụng.'
              : 'Progesterone fluctuations before menstruation can cause mild water retention.',
            icon: Icons.opacity_outlined,
            type: PossibilityType.physical,
            likelihoodContext: isVi ? 'Phổ biến trước kỳ kinh' : 'Common pre-menstrual pattern',
          ));
          physicalList.add(SymptomPossibility(
            label: isVi ? 'Căng tức ngực hoặc cơ thể' : 'Mild Breast Tenderness',
            naturalExplanation: isVi
              ? 'Mô tuyến vú và cơ thể có thể trở nên nhạy cảm hơn khi kỳ kinh đến gần.'
              : 'Breast tissue and body sensitivity can become heightened as bleeding nears.',
            icon: Icons.spa_outlined,
            type: PossibilityType.physical,
            likelihoodContext: isVi ? 'Có thể gặp vài ngày trước kỳ kinh' : 'Possible a few days before period',
          ));
          physicalList.add(SymptomPossibility(
            label: isVi ? 'Dễ mệt mỏi hoặc thiếu năng lượng' : 'Fatigue or Low Energy',
            naturalExplanation: isVi
              ? 'Nồng độ progesterone giảm dần có thể khiến cơ thể muốn nghỉ ngơi nhiều hơn.'
              : 'Dropping progesterone can signal a natural biological slowdown.',
            icon: Icons.battery_alert_outlined,
            type: PossibilityType.physical,
            likelihoodContext: isVi ? 'Dấu hiệu cơ thể sắp đến kỳ kinh' : 'Frequent pre-period indicator',
          ));

          emotionalList.add(SymptomPossibility(
            label: isVi ? 'Dễ nhạy cảm với căng thẳng' : 'Sensitive to Stress & Overwhelm',
            naturalExplanation: isVi
              ? 'Áp lực thường ngày có thể tạo cảm giác nặng nề hơn. Lắng nghe kiên nhẫn là cách giúp đỡ tuyệt vời nhất.'
              : 'Daily stressors may feel heavier. Patient listening without quick advice helps most.',
            icon: Icons.psychology_outlined,
            type: PossibilityType.emotional,
            likelihoodContext: isVi ? 'Cần sự cảm thông, không phán xét' : 'Deserves empathy, not judgment',
          ));
          emotionalList.add(SymptomPossibility(
            label: isVi ? 'Thích không gian yên tĩnh, riêng tư' : 'Preferring Quiet & Space',
            naturalExplanation: isVi
              ? 'Có thể thích các hoạt động nhẹ nhàng ở nhà hơn là các buổi tụ tập đông người.'
              : 'She might appreciate low-demand evenings over packed social calendars.',
            icon: Icons.nights_stay_outlined,
            type: PossibilityType.emotional,
            likelihoodContext: isVi ? 'Tôn trọng không gian riêng' : 'Respectful space appreciated',
          ));
        } else {
          physicalList.add(SymptomPossibility(
            label: isVi ? 'Năng lượng & sự thoải mái ổn định' : 'Steady Energy & Comfort',
            naturalExplanation: isVi
              ? 'Progesterone duy trì trạng thái êm dịu và tương đối dễ chịu trong những ngày đầu hoàng thể.'
              : 'Progesterone promotes a calm, relatively comfortable post-ovulation baseline.',
            icon: Icons.health_and_safety_outlined,
            type: PossibilityType.physical,
            likelihoodContext: isVi ? 'Đầu giai đoạn hoàng thể' : 'Early luteal phase',
          ));
          physicalList.add(SymptomPossibility(
            label: isVi ? 'Chuyển dần sang nhịp nghỉ ngơi' : 'Gradual Shift Toward Rest',
            naturalExplanation: isVi
              ? 'Tín hiệu nhẹ nhàng để tận hưởng nhịp sống nhàn nhã hơn là gắng sức quá nhiều.'
              : 'A subtle cue to enjoy comfortable, paced routines rather than intense exertion.',
            icon: Icons.battery_charging_full_outlined,
            type: PossibilityType.physical,
            likelihoodContext: isVi ? 'Những ngày sau rụng trứng' : 'Post-ovulation days',
          ));

          emotionalList.add(SymptomPossibility(
            label: isVi ? 'Bình tĩnh, trầm lặng & chu đáo' : 'Grounded & Reflective',
            naturalExplanation: isVi
              ? 'Thư thái, tập trung và hài lòng với những buổi tối bình yên bên những thói quen quen thuộc.'
              : 'Calm, focused, and content with low-key evenings and familiar routines.',
            icon: Icons.self_improvement_outlined,
            type: PossibilityType.emotional,
            likelihoodContext: isVi ? 'Tâm trạng đầu hoàng thể điển hình' : 'Typical early luteal mood',
          ));
          emotionalList.add(SymptomPossibility(
            label: isVi ? 'Cảm xúc ổn định, hài hòa' : 'Emotionally Stable',
            naturalExplanation: isVi
              ? 'Cân bằng cảm xúc dễ chịu, ít có biến động tâm trạng.'
              : 'Comfortable emotional balance with minimal mood swings.',
            icon: Icons.sentiment_satisfied_outlined,
            type: PossibilityType.emotional,
            likelihoodContext: isVi ? 'Trải nghiệm cá nhân khác nhau' : 'Varied personal experience',
          ));
        }
        break;

      case CyclePhase.uncertain:
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Biểu hiện cơ thể đa dạng' : 'Varied Physical Sensations',
          naturalExplanation: isVi
              ? 'Thời điểm chu kỳ hiện chưa rõ ràng. Các triệu chứng có thể thay đổi tự nhiên.'
              : 'Cycle timing is currently uncertain. Symptoms can vary naturally across any given week.',
          icon: Icons.help_outline,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Đang chờ thêm dữ liệu chu kỳ' : 'Awaiting more cycle entries',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Cảm xúc mang tính cá nhân' : 'Individual Emotional Experience',
          naturalExplanation: isVi
              ? 'Cảm xúc phụ thuộc vào giấc ngủ, áp lực công việc và cuộc sống hàng ngày hơn là chỉ riêng chu kỳ.'
              : 'Emotions depend on sleep, stress, and daily life rather than predictable cycle phases alone.',
          icon: Icons.sentiment_neutral_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Sẵn sàng lắng nghe & chia sẻ' : 'Open to communication',
        ));
        break;
    }

    final String transparentNotice;
    if (isVi) {
      if (reliability == EstimateReliability.limitedInformation) {
        transparentNotice =
            'Ước tính từ 1 ngày kinh đã ghi nhận theo chu kỳ mẫu 28 ngày. '
            'Đây là các khả năng chung, không phải sự thật đã xác nhận. Cơ thể mỗi người luôn khác nhau.';
      } else if (reliability == EstimateReliability.variableCycle) {
        transparentNotice =
            'Ước tính theo lịch sử chu kỳ (có dao động tự nhiên). '
            'Các dự đoán là gợi ý để bạn hỏi thăm ân cần, tuyệt đối không phải định kiến.';
      } else {
        transparentNotice =
            'Ước tính theo thời điểm chu kỳ. Phản ánh các khả năng thường gặp trong giai đoạn này, '
            'không khẳng định chính xác cảm nhận của cô ấy hôm nay.';
      }
    } else {
      if (reliability == EstimateReliability.limitedInformation) {
        transparentNotice =
            'Estimated from 1 recorded period start date and a general 28-day baseline. '
            'These are general possibilities, not confirmed facts. Individual experiences vary.';
      } else if (reliability == EstimateReliability.variableCycle) {
        transparentNotice =
            'Estimated from her recorded cycle history (variable intervals observed). '
            'Possibilities are prompts for thoughtful check-ins, never assumptions.';
      } else {
        transparentNotice =
            'Estimated from cycle timing. These reflect possibilities common to this phase, '
            'not confirmed facts about how she feels today.';
      }
    }

    return DailySymptomMoodEstimate(
      currentPhase: phase,
      dayOfCycle: day,
      physicalPossibilities: physicalList,
      emotionalPossibilities: emotionalList,
      reliability: reliability,
      confidenceBadge: reliability.localizedBadgeLabel(language),
      transparentNotice: transparentNotice,
    );
  }
}
