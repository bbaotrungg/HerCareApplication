import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/symptoms/domain/models/daily_symptom_mood_estimate.dart';
import 'package:hercare/features/symptoms/domain/models/symptom_possibility.dart';

/// Pure, deterministic engine that estimates possible physical sensations and
/// emotional experiences based dynamically on specific cycle days and cycle timing.
///
/// Communicates uncertainty transparently in English and Vietnamese.
/// Content varies across individual cycle days throughout the entire menstrual
/// cycle, avoiding repetitive predictions on consecutive days.
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

    // Compute effective day index for day-specific progression
    final effectiveDay = _computeEffectiveDay(cycleEstimate, day, phase);

    switch (effectiveDay) {
      case 1:
        // Day 1: Period onset, peak prostaglandins, acute cramping, energy drop
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Đau tức bụng kinh' : 'Abdominal Cramps',
          naturalExplanation: isVi
              ? 'Tử cung co bóp để đẩy niêm mạc; các cơn đau tức thường rõ rệt nhất vào ngày đầu tiên.'
              : 'Gentle uterine contractions to shed lining can cause pelvic cramping or aching.',
          icon: Icons.waves,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Ngày 1 chu kỳ kinh' : 'Day 1 of menstruation',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Năng lượng thấp hoặc mệt mỏi' : 'Lower Energy or Fatigue',
          naturalExplanation: isVi
              ? 'Nội tiết tố ở mức cơ bản; thể lực sụt giảm nhanh khi cơ thể bắt đầu chu kỳ mới.'
              : 'Hormone levels reach baseline; physical stamina drops as the body initiates the cycle.',
          icon: Icons.battery_2_bar_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thường thấy ở những ngày đầu chu kỳ' : 'Often noticed in early cycle days',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Căng mỏi thắt lưng' : 'Lower Back Discomfort',
          naturalExplanation: isVi
              ? 'Căng tức vùng chậu có thể lan ra các dây chằng lưng dưới.'
              : 'Pelvic tension can occasionally radiate toward the lower back ligaments.',
          icon: Icons.accessibility_new_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Phổ biến khi bắt đầu hành kinh' : 'Common on period onset',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Nhu cầu nghỉ ngơi nhiều hơn' : 'Wanting Extra Rest',
          naturalExplanation: isVi
              ? 'Khuynh hướng sinh học tự nhiên muốn chậm lại và phục hồi năng lượng thể chất.'
              : 'A natural biological inclination to slow down and restore physical reserves.',
          icon: Icons.bedtime_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Cần nghỉ ngơi sâu ngày đầu' : 'Deep rest prioritized on day 1',
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
        break;

      case 2:
        // Day 2: Peak menstrual flow, cramps, fatigue, lower back discomfort
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

      case 3:
        // Day 3: Bleeding tapering, milder cramps, lingering mild fatigue
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Đau tức bụng giảm dần' : 'Cramping Easing to Mild Ache',
          naturalExplanation: isVi
              ? 'Lượng kinh giảm bớt, cơn co thắt tử cung dịu đi thành cảm giác nặng nhẹ vùng chậu.'
              : 'As flow begins tapering, acute cramping subsides into a milder, manageable sensation.',
          icon: Icons.spa_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Ngày 3 kỳ kinh' : 'Day 3 of menstruation',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Còn mệt mỏi nhẹ' : 'Lingering Mild Fatigue',
          naturalExplanation: isVi
              ? 'Cơ thể vẫn đang tiêu hao năng lượng trong kỳ kinh, thể lực cần thêm thời gian để nạp lại.'
              : 'The body is still actively shedding, so energy remains somewhat reserved.',
          icon: Icons.battery_3_bar_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Đang hồi phục dần' : 'Gradual recovery phase',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Vùng thắt lưng dễ chịu hơn' : 'Lower Back Loosening',
          naturalExplanation: isVi
              ? 'Cơ lưng dưới dần thả lỏng khi áp lực vùng chậu giảm đi.'
              : 'Lower back muscles begin relaxing as pelvic pressure lessens.',
          icon: Icons.check_circle_outline,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Giảm bớt căng thẳng cơ thể' : 'Tension dissipating',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Tâm trạng êm dịu, thích sự yên bình' : 'Calm Mindset & Craving Comfort',
          naturalExplanation: isVi
              ? 'Sau những ngày đầu mệt mỏi, tinh thần cô ấy dần trở nên nhẹ nhõm và an yên hơn.'
              : 'After the initial strain, emotional baseline stabilizes into cozy, peaceful contentment.',
          icon: Icons.nightlight_round,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Tâm trạng thư thái hơn' : 'More relaxed mindset',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Thích các hoạt động nhẹ nhàng' : 'Receptive to Low-Key Company',
          naturalExplanation: isVi
              ? 'Những bộ phim nhẹ nhàng hoặc đọc sách cùng nhau sẽ rất hợp vào lúc này.'
              : 'Low-key shared activities like watching a relaxing movie feel just right.',
          icon: Icons.favorite_border,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thích nhịp sống êm ả' : 'Prefers unhurried pace',
        ));
        break;

      case 4:
        // Day 4: Light flow, energy recovery, lower back loosening, steady comfort
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Kỳ kinh giảm dần, cơ thể nhẹ nhõm' : 'Flow Tapering & Light Body Feel',
          naturalExplanation: isVi
              ? 'Kỳ kinh bước vào giai đoạn nhẹ, cơ thể cảm thấy nhẹ nhàng và sảng khoái hơn nhiều.'
              : 'Flow is now light; pelvic lightness and physical comfort noticeably improve.',
          icon: Icons.wb_twilight,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Cuối kỳ kinh' : 'Late menstruation',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Năng lượng bước đầu hồi phục' : 'Initial Energy Rebound',
          naturalExplanation: isVi
              ? 'Cảm giác uể oải tan biến, năng lượng bắt đầu hồi phục để chuẩn bị bước vào giai đoạn mới.'
              : 'Physical sluggishness fades as estrogen starts its subtle post-period rise.',
          icon: Icons.battery_charging_full_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thể lực đang đi lên' : 'Energy trending upward',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cơ thể thoải mái, ổn định' : 'Steady Comfort',
          naturalExplanation: isVi
              ? 'Rất ít hoặc hầu như không còn cảm giác đau tức khó chịu.'
              : 'Minimal or no cycle-related physical discomfort remains.',
          icon: Icons.sentiment_satisfied_alt_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Cảm giác thoải mái trở lại' : 'Comfort restored',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Tâm trạng nhẹ nhõm & vui tươi' : 'Cheerfully Relieved & Easygoing',
          naturalExplanation: isVi
              ? 'Sự nhẹ nhõm khi kỳ kinh sắp kết thúc mang lại tinh thần tươi tắn, cởi mở.'
              : 'Relief from menstrual heaviness brings a natural lift in spirits and ease.',
          icon: Icons.sentiment_very_satisfied,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Tâm trạng tích cực' : 'Positive mood shift',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Hào hứng trò chuyện gần gũi' : 'Welcoming Casual Conversation',
          naturalExplanation: isVi
              ? 'Năng lượng giao tiếp bắt đầu tăng trở lại sau những ngày hướng nội.'
              : 'Social energy begins rebounding after inward-focused bleeding days.',
          icon: Icons.chat_bubble_outline,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Sẵn sàng kết nối' : 'Open to connection',
        ));
        break;

      case 5:
        // Day 5: End of period, clean refreshed feeling, renewed stamina
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Kết thúc kỳ kinh, cơ thể sảng khoái' : 'Period Concluding & Refreshed Feel',
          naturalExplanation: isVi
              ? 'Kỳ kinh kết thúc; cảm giác nặng nề biến mất hoàn toàn, cơ thể trở nên sảng khoái.'
              : 'Bleeding ends; pelvic heaviness completely lifts, leaving a fresh physical sensation.',
          icon: Icons.sentiment_very_satisfied_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Ngày cuối kỳ kinh' : 'Final day of period',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Sức bền thể lực hồi sinh' : 'Renewed Physical Stamina',
          naturalExplanation: isVi
              ? 'Nồng độ estrogen bắt đầu tăng lên, hỗ trợ sự linh hoạt và hoạt bát trong ngày.'
              : 'Estrogen begins its steady ascent, fueling physical resilience and mobility.',
          icon: Icons.bolt,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thể lực hồi sinh' : 'Stamina renewed',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Lạc quan, sẵn sàng cho tuần mới' : 'Optimistic & Ready for the Week',
          naturalExplanation: isVi
              ? 'Tâm trạng hào hứng bước vào chu kỳ mới với nhiều năng lượng và sự tươi mới.'
              : 'Buoyant outlook as the cycle resets with renewed enthusiasm and focus.',
          icon: Icons.wb_sunny_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Tinh thần phấn chấn' : 'High optimism baseline',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Hào hứng kết nối trở lại' : 'Energized Social Baseline',
          naturalExplanation: isVi
              ? 'Sẵn sàng cho các buổi đi chơi, gặp gỡ bạn bè hay tận hưởng các hoạt động chung.'
              : 'Eager for shared outings, lively conversations, and social activities.',
          icon: Icons.groups_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thích ra ngoài & giao tiếp' : 'Outward energy returning',
        ));
        break;

      case 6:
        // Day 6: Early Follicular Awakening
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Sinh lực hồi phục sau kỳ kinh' : 'Post-Period Vitality Lift',
          naturalExplanation: isVi
              ? 'Giai đoạn nang trứng chính thức bắt đầu, thể lực dồi dào và các cơ bắp linh hoạt hơn.'
              : 'Early follicular phase begins; physical lightness and stamina naturally expand.',
          icon: Icons.directions_walk_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Đầu giai đoạn nang trứng' : 'Early follicular phase',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Tinh thần minh mẫn & tập trung' : 'Clear Head & Focus',
          naturalExplanation: isVi
              ? 'Sau khi hết kinh, sự tập trung và sảng khoái tinh thần tăng cao rõ rệt.'
              : 'Post-bleeding days often bring renewed clarity and lower physical strain.',
          icon: Icons.lightbulb_outline,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Đầu óc minh mẫn' : 'Mental sharpness',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Tâm trạng tò mò & tích cực' : 'Curious & Upbeat Outlook',
          naturalExplanation: isVi
              ? 'Estrogen tăng dần kích thích sự hào hứng với các ý tưởng mới và thói quen tích cực.'
              : 'Rising estrogen sparks curiosity, mental openness, and proactive ideas.',
          icon: Icons.explore_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thích khám phá điều mới' : 'Enthusiastic mindset',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Cảm xúc cân bằng, lạc quan' : 'Emotionally Balanced',
          naturalExplanation: isVi
              ? 'Nội tiết tố ổn định hỗ trợ tâm trạng tích cực, kiên nhẫn và thoải mái.'
              : 'Balanced hormones support an upbeat, patient, and grounded outlook.',
          icon: Icons.mood_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Tâm trạng tốt' : 'Frequent positive baseline',
        ));
        break;

      case 7:
        // Day 7: Follicular Momentum
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Thể lực tăng trưởng & năng lượng tươi mới' : 'Climbing Stamina & Fresh Vitality',
          naturalExplanation: isVi
              ? 'Các nang buồng trứng phát triển tiết estrogen, thúc đẩy sức bền và độ dẻo dai cơ thể.'
              : 'Developing follicles produce estrogen, enhancing endurance and physical agility.',
          icon: Icons.fitness_center_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Sức bền đang lên' : 'Endurance climbing',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cơ thể thoải mái, ổn định' : 'Steady Comfort',
          naturalExplanation: isVi
              ? 'Không có triệu chứng khó chịu; cơ thể ở trạng thái dễ chịu nhất trong chu kỳ.'
              : 'Minimal or no cycle-related physical discomfort; a very comfortable phase.',
          icon: Icons.sentiment_satisfied_alt_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Giai đoạn thoải mái' : 'Comfortable window',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Cởi mở, thích giao tiếp & chia sẻ' : 'Sociable & Expressive Mindset',
          naturalExplanation: isVi
              ? 'Rất thích hợp để chia sẻ cảm xúc, lên kế hoạch tương lai và trò chuyện sâu sắc.'
              : 'Great time for expressive conversations, collaborative plans, and shared laughter.',
          icon: Icons.record_voice_over_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Cởi mở giao tiếp' : 'High sociability',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Tự tin và kiên nhẫn' : 'Emotionally Resilient & Confident',
          naturalExplanation: isVi
              ? 'Khả năng ứng phó với áp lực công việc và cuộc sống rất tốt trong những ngày này.'
              : 'High resilience against daily stressors with calm self-confidence.',
          icon: Icons.psychology_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Vững vàng cảm xúc' : 'Steady confidence',
        ));
        break;

      case 8:
        // Day 8: Mid-Follicular Peak Focus (Required by existing test)
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

      case 9:
        // Day 9: High Follicular Productivity
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Sự tập trung cao độ & thể lực dồi dào' : 'Peak Cognitive Focus & High Stamina',
          naturalExplanation: isVi
              ? 'Estrogen tăng cao kích thích dẫn truyền dopamine, nâng cao khả năng tập trung và làm việc hiệu quả.'
              : 'High estrogen promotes focus and high energy, supporting productive pursuits.',
          icon: Icons.trending_up,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Năng suất thể chất cao' : 'High productivity window',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Làn da rạng rỡ, cơ thể nhẹ nhõm' : 'Vibrant Skin & Radiant Physical Feel',
          naturalExplanation: isVi
              ? 'Lượng estrogen cao giúp da giữ ẩm tốt và cơ thể cảm thấy nhẹ nhàng, tươi tắn.'
              : 'Peak hydration and collagen support often give skin a healthy, radiant feel.',
          icon: Icons.auto_awesome,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Sắc vóc tươi tắn' : 'Natural radiant glow',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Tự tin, quyết đoán & giàu cảm hứng' : 'Self-Assured & Goal-Oriented',
          naturalExplanation: isVi
              ? 'Sự quyết tâm và cảm hứng sáng tạo thường rất dồi dào trong giai đoạn này.'
              : 'Motivation and creative momentum are naturally pronounced today.',
          icon: Icons.star_outline,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Giàu động lực' : 'Strong internal motivation',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Ấm áp & cuốn hút trong giao tiếp' : 'Warm & Engaging Presence',
          naturalExplanation: isVi
              ? 'Phong thái tự nhiên, ấm áp và rất cuốn hút khi trò chuyện cùng người yêu thương.'
              : 'Effortlessly engaging, warm, and magnetic in personal communication.',
          icon: Icons.favorite,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Gắn kết thân mật' : 'Interpersonal warmth',
        ));
        break;

      case 10:
        // Day 10: Approaching Estrogen Surge
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Sức bền đỉnh cao & năng lượng bùng nổ' : 'Physical Resilience & Energy Surge',
          naturalExplanation: isVi
              ? 'Estrogen tiến sát mức đỉnh; cơ bắp hồi phục nhanh và sức bền đạt điểm tối ưu.'
              : 'Estrogen nears its pre-ovulatory peak; muscle recovery is fast and energy surges.',
          icon: Icons.flash_on_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Năng lượng đỉnh cao' : 'Approaching peak vitality',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cơ bắp dẻo dai, ít mệt mỏi' : 'Natural Muscle Tone & Low Fatigue',
          naturalExplanation: isVi
              ? 'Cơ thể ít có cảm giác mệt mỏi ngay cả sau một ngày dài năng động.'
              : 'Physical fatigue remains low even during busy, demanding days.',
          icon: Icons.health_and_safety_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Dẻo dai năng động' : 'High stamina baseline',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Dí dỏm, yêu đời & giàu tình cảm' : 'Playful, Dynamic & Affectionate',
          naturalExplanation: isVi
              ? 'Tâm trạng vui vẻ, yêu thích những khoảnh khắc vui đùa dí dỏm cùng bạn đời.'
              : 'Playful spirit with high emotional generosity and warmth.',
          icon: Icons.mood,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Tâm trạng yêu đời' : 'Playful emotional tone',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Hào hứng với những kế hoạch chung' : 'Eager for Joint Adventures',
          naturalExplanation: isVi
              ? 'Rất hào hứng chuẩn bị cho các chuyến đi chơi hoặc trải nghiệm những điều mới lạ.'
              : 'Enthusiastic about making plans, dates, or trying shared novelties together.',
          icon: Icons.celebration_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thích phiêu lưu cùng nhau' : 'Adventurous social mood',
        ));
        break;

      case 11:
        // Day 11: Late Follicular Radiance
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Rạng rỡ trước ngày rụng trứng' : 'Pre-Ovulation Glow & Agility',
          naturalExplanation: isVi
              ? 'Nồng độ estrogen ở mức rất cao, mang lại vẻ ngoài rạng rỡ và sự nhanh nhẹn thể chất.'
              : 'Peak estrogen fosters radiant energy, quick reflexes, and great physical comfort.',
          icon: Icons.wb_sunny,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Sát ngày rụng trứng' : 'Late follicular window',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Các giác quan nhạy bén' : 'Heightened Sensory Sharpness',
          naturalExplanation: isVi
              ? 'Khứu giác, thị giác và cảm nhận vị giác thường tinh tế và phong phú hơn.'
              : 'Senses of smell, taste, and sensory awareness are subtly elevated.',
          icon: Icons.remove_red_eye_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Cảm quan nhạy bén' : 'Sensory elevation',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Dịu dàng, gắn kết & đầy sức hút' : 'Affectionate & Socially Magnetic',
          naturalExplanation: isVi
              ? 'Sự cởi mở và dịu dàng trong tình cảm tạo nên sự gắn kết sâu sắc và quyến rũ.'
              : 'Deep warmth, emotional openness, and genuine relationship connection.',
          icon: Icons.favorite_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Sức hút tình cảm' : 'Magnetic emotional tone',
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

      case 12:
        // Day 12: Ovulation Window Entrance (LH Surge Window)
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
          label: isVi ? 'Cảm giác ấm nhẹ vùng chậu' : 'Subtle Pelvic Warmth',
          naturalExplanation: isVi
              ? 'Lượng máu lưu thông đến vùng chậu tăng cao trước thời điểm rụng trứng.'
              : 'Increased pelvic blood circulation often feels like a gentle inner warmth.',
          icon: Icons.flare_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thời điểm rụng trứng' : 'Ovulation surge timing',
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
          label: isVi ? 'Khao khát gần gũi & sẻ chia' : 'Desire for Closeness & Connection',
          naturalExplanation: isVi
              ? 'Bản năng gắn kết tình cảm tự nhiên thúc đẩy sự thân mật và thấu hiểu.'
              : 'Biological peaks foster genuine desire for closeness, affection, and emotional intimacy.',
          icon: Icons.favorite,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Gắn bó tình cảm sâu sắc' : 'Intimacy peak',
        ));
        break;

      case 13:
      case 14:
        // Day 13-14: Ovulation Day / Mittelschmerz (Satisfies ovulatory test)
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

      case 15:
        // Day 15: Post-Ovulation Transition
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Chuyển giao chuyển hóa sau rụng trứng' : 'Post-Ovulatory Transition',
          naturalExplanation: isVi
              ? 'Estrogen hạ nhẹ trong khi progesterone bắt đầu hình thành; nhiệt độ cơ thể nhích nhẹ.'
              : 'Estrogen dips slightly as progesterone begins rising; basal body temperature shifts upward.',
          icon: Icons.thermostat_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Sau khi rụng trứng' : 'Post-ovulatory shift',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cơ thể chuyển sang trạng thái êm dịu' : 'Calm Physical Settling',
          naturalExplanation: isVi
              ? 'Cơ thể từ trạng thái năng lượng bùng nổ chuyển sang nhịp điệu êm ả và ổn định.'
              : 'The body transitions smoothly from peak outward drive to calm metabolic equilibrium.',
          icon: Icons.spa_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Chuyển nhịp êm ả' : 'Equilibrium shift',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Chuyển từ hướng ngoại sang bình yên nội tâm' : 'Transition to Inner Peace',
          naturalExplanation: isVi
              ? 'Nhu cầu giao tiếp rộng giảm nhẹ, thay vào đó là mong muốn có những phút giây tĩnh lặng.'
              : 'Social bandwidth softens toward a quiet, deeply centered appreciation of peace.',
          icon: Icons.self_improvement,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Tâm hồn tĩnh lặng' : 'Centering transition',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Thanh thản, trầm tĩnh & hài lòng' : 'Serene, Grounded & Content',
          naturalExplanation: isVi
              ? 'Cảm xúc thư thái, đón nhận cuộc sống với sự hài lòng và điềm đạm.'
              : 'Serene emotional baseline with comfortable satisfaction in everyday life.',
          icon: Icons.sentiment_satisfied_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Tâm thế bình an' : 'Grounded contentment',
        ));
        break;

      case 16:
        // Day 16: Early Luteal Harmony
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
          label: isVi ? 'Thân nhiệt ấm áp, cơ bắp thư thái' : 'Warm Baseline & Relaxed Muscles',
          naturalExplanation: isVi
              ? 'Progesterone giữ thân nhiệt ấm nhẹ, cơ bắp thả lỏng và dễ chịu.'
              : 'Progesterone keeps the body pleasantly warm and musculature relaxed.',
          icon: Icons.wb_sunny_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thân nhiệt ấm áp' : 'Warm metabolic tone',
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
        break;

      case 17:
        // Day 17: Progesterone Foundation
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
          label: isVi ? 'Hài lòng với nếp sống quen thuộc' : 'Contentment with Familiar Routines',
          naturalExplanation: isVi
              ? 'Thích cảm giác ấm cúng của tổ ấm và những bữa cơm gia đình thân thuộc.'
              : 'Appreciating the grounding rhythm of home cooking and calm familiar environments.',
          icon: Icons.home_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Yêu thích sự ấm cúng' : 'Cozy home preference',
        ));
        break;

      case 18:
        // Day 18: Mid-Luteal Comfort Plateau
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Thể lực ổn định, khẩu vị tốt' : 'Steady Stamina & Healthy Appetite',
          naturalExplanation: isVi
              ? 'Mức progesterone đạt đỉnh vững chắc, quá trình trao đổi chất tăng nhẹ khiến khẩu vị tốt hơn.'
              : 'Progesterone plateau slightly increases basal metabolic rate, encouraging a healthy appetite.',
          icon: Icons.restaurant_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Giữa giai đoạn hoàng thể' : 'Mid-luteal plateau',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cơ thể thư giãn, ngủ sâu hơn' : 'Deep Sleep & Body Relaxation',
          naturalExplanation: isVi
              ? 'Tác động làm dịu của progesterone hỗ trợ giấc ngủ đêm sâu và ngon giấc hơn.'
              : 'Progesterone naturally interacts with GABA receptors to support restorative sleep.',
          icon: Icons.bedtime_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Hỗ trợ giấc ngủ' : 'Restorative sleep quality',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Kiên nhẫn, điềm tĩnh & dễ chịu' : 'Patient, Calm & Easygoing',
          naturalExplanation: isVi
              ? 'Tâm trạng ổn định, nhẹ nhàng và kiên nhẫn trong mọi hoạt động hàng ngày.'
              : 'A steady, patient baseline with minimal emotional friction or tension.',
          icon: Icons.sentiment_satisfied,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Trạng thái ổn định' : 'Steady emotional balance',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Thích sự đồng hành bình yên' : 'Enjoying Quiet Parallel Company',
          naturalExplanation: isVi
              ? 'Cảm thấy hạnh phúc khi cùng ngồi bên nhau, mỗi người làm một việc trong không gian yên tĩnh.'
              : 'Happy relaxing side-by-side in comfortable, unspoken mutual understanding.',
          icon: Icons.favorite_border_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Gắn kết bình yên' : 'Comfortable companionship',
        ));
        break;

      case 19:
        // Day 19: Deep Luteal Equanimity
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Nhịp sinh học êm đềm, cơ thể ổn định' : 'Comfortable Internal Rhythm',
          naturalExplanation: isVi
              ? 'Cơ thể duy trì trạng thái êm ả, thói quen sinh hoạt đều đặn mang lại cảm giác an toàn.'
              : 'Biological pace remains steady; predictable daily rhythms feel especially comforting.',
          icon: Icons.access_time_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Nhịp sinh học đều đặn' : 'Predictable physical rhythm',
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
          label: isVi ? 'Chu đáo, sâu lắng & quan tâm' : 'Nurturing & Thoughtful',
          naturalExplanation: isVi
              ? 'Tâm thế giàu tình cảm, chú trọng chăm sóc gia đình và người thân yêu.'
              : 'Gentle, nurturing thoughts with attentiveness toward loved ones.',
          icon: Icons.volunteer_activism_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Chu đáo sâu lắng' : 'Nurturing mindset',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Chuộng những buổi tối êm ả' : 'Appreciating Low-Stimulation Evenings',
          naturalExplanation: isVi
              ? 'Ánh đèn dịu, không gian ấm áp ở nhà được yêu thích hơn những nơi đông người.'
              : 'Prefers soft lighting, quiet music, and cozy home evenings over crowded venues.',
          icon: Icons.nights_stay_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thích buổi tối êm đềm' : 'Low-stimulation preference',
        ));
        break;

      case 20:
        // Day 20: Early Premenstrual Transition
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Tín hiệu giảm nhịp độ gắng sức' : 'Natural Cue to Pace Physical Demands',
          naturalExplanation: isVi
              ? 'Nội tiết tố bắt đầu có sự điều chỉnh nhẹ; cơ thể muốn làm việc với tốc độ vừa phải.'
              : 'Hormonal crest slowly plateaus; subtle biological cue to pace daily workloads.',
          icon: Icons.slow_motion_video_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Bắt đầu giảm nhịp' : 'Pacing transition',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Chuyển hóa hoạt động tích cực' : 'Subtle Metabolic Elevation',
          naturalExplanation: isVi
              ? 'Nhiệt độ cơ thể cao hơn một chút, cần bổ sung đủ nước và ăn uống đầy đủ chất.'
              : 'Slightly higher core temperature makes good hydration especially refreshing.',
          icon: Icons.local_drink_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Cần bổ sung nước' : 'Hydration beneficial',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Thích sự an tâm & dịu dàng' : 'Desiring Predictability & Gentle Tone',
          naturalExplanation: isVi
              ? 'Giọng điệu ấm áp và thái độ kiên nhẫn từ bạn đời mang lại cảm giác được nâng niu.'
              : 'A warm, steady tone from her partner feels deeply reassuring and safe.',
          icon: Icons.shield_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Cần sự tin cậy' : 'Reassurance welcomed',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Tâm trạng ổn định, nhẹ nhàng' : 'Calm & Centered Baseline',
          naturalExplanation: isVi
              ? 'Duy trì trạng thái cân bằng nội tâm, tận hưởng sự an yên của hiện tại.'
              : 'Grounded emotional center with appreciation for peaceful simplicity.',
          icon: Icons.self_improvement,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thanh thản nội tâm' : 'Centered mindset',
        ));
        break;

      case 21:
        // Day 21: Threshold of Late Luteal
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Chớm giữ nước nhẹ & nhạy cảm' : 'Subtle Fluid Shift & Early Sensitivity',
          naturalExplanation: isVi
              ? 'Progesterone bắt đầu dao động, cơ thể có thể hơi có cảm giác tức nhẹ hoặc đầy bụng.'
              : 'Beginning of late luteal hormonal shift; early mild water retention may occur.',
          icon: Icons.opacity_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Giai đoạn chuyển tiếp hoàng thể' : 'Late luteal threshold',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Dễ mỏi mệt sớm hơn về chiều tối' : 'Earlier Evening Tiredness',
          naturalExplanation: isVi
              ? 'Năng lượng cạn nhanh hơn vào cuối ngày; muốn được nghỉ ngơi sớm.'
              : 'Physical battery winds down a bit earlier in the evening; early sleep is welcoming.',
          icon: Icons.battery_3_bar,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Mệt mỏi chiều tối' : 'Evening fatigue marker',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Năng lượng giao tiếp thu hẹp lại' : 'Smaller Social Battery',
          naturalExplanation: isVi
              ? 'Cô ấy có thể cảm thấy ngại gặp gỡ nhiều người và muốn ở trong vòng tay quen thuộc.'
              : 'Social energy contracts naturally; prefers the comfort of immediate loved ones.',
          icon: Icons.person_outline,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Thu mình lại' : 'Cozy inward turn',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Thích sự hiện diện ấm áp' : 'Welcoming Warm Presence',
          naturalExplanation: isVi
              ? 'Không cần nói quá nhiều, chỉ cần sự đồng hành kề bên là đủ mang lại bình an.'
              : 'Quiet physical presence and unspoken support speak louder than long discussions.',
          icon: Icons.favorite,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Hiện diện ân cần' : 'Supportive presence',
        ));
        break;

      case 22:
        // Day 22: Late Luteal Onset / Cravings
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Giữ nước nhẹ & thèm đồ ngọt/mặn' : 'Mild Water Retention & Cravings',
          naturalExplanation: isVi
              ? 'Sự sụt giảm nhẹ của nội tiết tố có thể kích thích cảm giác thèm món ăn ngọt hoặc đậm vị.'
              : 'Hormonal adjustments can trigger cravings for chocolate, comforting carbs, or savory bites.',
          icon: Icons.cookie_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Thèm ăn trước kỳ kinh' : 'Premenstrual cravings',
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
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Dễ mẫn cảm với áp lực' : 'Vulnerability to Daily Stress',
          naturalExplanation: isVi
              ? 'Những áp lực nhỏ nhặt trong công việc có thể tạo cảm giác nặng nề hơn bình thường.'
              : 'Daily stressors can feel slightly heavier than usual as resilience dips.',
          icon: Icons.psychology_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Cần sự cảm thông' : 'Deserves empathy',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Cần sự vỗ về và bảo bọc' : 'Seeking Warm Emotional Reassurance',
          naturalExplanation: isVi
              ? 'Những cử chỉ ân cần, cái ôm ấm áp sẽ giúp cô ấy cảm thấy an toàn và thoải mái.'
              : 'A warm hug and tender reassurance help her feel safe and deeply cared for.',
          icon: Icons.favorite_outline,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Vỗ về nhẹ nhàng' : 'Reassurance appreciated',
        ));
        break;

      case 23:
        // Day 23: Late Luteal Fluid Fullness
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
          label: isVi ? 'Cảm giác nặng nề ở chân & bụng' : 'Slight Heaviness in Legs & Abdomen',
          naturalExplanation: isVi
              ? 'Lưu thông tuần hoàn chậm lại khiến đôi chân hoặc bụng dưới có cảm giác nặng hơn.'
              : 'Circulation shifts can manifest as a subtle heaviness in lower limbs and pelvis.',
          icon: Icons.accessibility_new_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Cơ thể nặng nề' : 'Heaviness sensation',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Nhạy cảm khi nghe giọng điệu vội vã' : 'Sensitive to Hurried Communication',
          naturalExplanation: isVi
              ? 'Hệ thần kinh nhạy cảm hơn; thái độ kiên nhẫn, điềm đạm là liều thuốc xoa dịu tốt nhất.'
              : 'The nervous system is sensitive; calm, unhurried communication prevents overwhelm.',
          icon: Icons.hearing_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Cần giao tiếp chậm rãi' : 'Gentle pacing helps',
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
        break;

      case 24:
      case 25:
        // Day 24-25: Late Luteal Premenstrual Tension Peak (Satisfies Day 25 test)
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
        break;

      case 26:
        // Day 26: Premenstrual Wind-Down / Supplies Approaching
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Căng tức vùng chậu trước kỳ kinh' : 'Pelvic Fullness & Pre-Period Heaviness',
          naturalExplanation: isVi
              ? 'Máu dồn về vùng chậu chuẩn bị cho kỳ kinh có thể tạo cảm giác nặng hoặc căng tức nhẹ.'
              : 'Pelvic vascular congestion before bleeding manifests as a full or heavy pelvic sensation.',
          icon: Icons.waves,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Kỳ kinh sắp đến' : 'Period approaching in 2-3 days',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Mệt mỏi hoặc mỏi lưng dưới' : 'Fatigue or Lower Back Tension',
          naturalExplanation: isVi
              ? 'Dây chằng vùng chậu chịu áp lực, cơ lưng dưới có thể thấy mỏi mệt.'
              : 'Pelvic ligaments under tension can translate into dull lower-back tiredness.',
          icon: Icons.accessibility_new_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Dấu hiệu sắp đến kỳ kinh' : 'Common pre-period symptom',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Đầy hơi hoặc giữ nước' : 'Bloating or Fullness',
          naturalExplanation: isVi
              ? 'Giữ nước đạt mức cao trước khi kỳ kinh bắt đầu giải tỏa cơ thể.'
              : 'Water retention is often most noticeable in the final few days before menstruation.',
          icon: Icons.opacity_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Phổ biến trước kỳ kinh' : 'Common pre-menstrual pattern',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Dễ xúc động hoặc mủi lòng' : 'Heightened Emotional Vulnerability',
          naturalExplanation: isVi
              ? 'Sự sụt giảm mạnh của cả estrogen và progesterone khiến cảm xúc trở nên nhạy cảm hơn.'
              : 'Sharp drops in estrogen and progesterone heighten emotional tenderness.',
          icon: Icons.favorite_border,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Cần sự dịu dàng tối đa' : 'Gentle care essential',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Chuộng buổi tối không áp lực' : 'Preference for Low-Demand Evenings',
          naturalExplanation: isVi
              ? 'Một buổi tối thảnh thơi, không phải suy nghĩ hay làm việc nhà là món quà lớn nhất.'
              : 'Zero domestic or social expectations allow her nervous system to rest peacefully.',
          icon: Icons.bedtime_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Mong muốn nghỉ ngơi' : 'Low demand preferred',
        ));
        break;

      case 27:
        // Day 27: Imminent Period Countdown
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cơn tức lâm râm báo hiệu kỳ kinh' : 'Pre-Menstrual Twinges & Dull Pelvic Ache',
          naturalExplanation: isVi
              ? 'Tử cung bắt đầu có những cơn co thắt nhẹ khởi động; kỳ kinh có thể đến trong vòng 24-48 giờ.'
              : 'Subtle uterine contractions begin gearing up; bleeding may start within 24-48 hours.',
          icon: Icons.notifications_active_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Khoảng 1-2 ngày trước kỳ kinh' : '1-2 days before period',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Uể oải thể chất & cơ thể cần hơi ấm' : 'Physical Lethargy & Need for Warmth',
          naturalExplanation: isVi
              ? 'Cơ thể cần được giữ ấm và nghỉ ngơi nhiều để sẵn sàng cho chu kỳ mới.'
              : 'The body strongly seeks warmth, cozy blankets, and unhurried stillness.',
          icon: Icons.hot_tub_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Cần giữ ấm cơ thể' : 'Warmth sought by body',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Bản năng muốn thu mình nghỉ ngơi' : 'Nesting Instinct & Desiring Sanctuary',
          naturalExplanation: isVi
              ? 'Mong muốn ở nhà, cuộn tròn trong chăn ấm và cảm nhận sự an toàn tuyệt đối.'
              : 'Natural inclination to stay home, wrap up in comfort, and feel entirely protected.',
          icon: Icons.home_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Tâm thế cần bình an' : 'Sanctuary seeking',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Trân trọng sự im lặng ân cần' : 'Appreciating Patient Silent Company',
          naturalExplanation: isVi
              ? 'Sự có mặt thầm lặng, chu đáo và không phán xét giúp cô ấy cảm thấy rất được yêu thương.'
              : 'Quiet, unhurried companionship without probing questions feels deeply supportive.',
          icon: Icons.favorite,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Hiện diện không lời' : 'Quiet companionship',
        ));
        break;

      default:
        // Day 28+ (or late luteal threshold): Expected Period Day / Impending Reset
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Cơn đau tức lâm râm báo hiệu kinh nguyệt' : 'Pre-Menstrual or Impending Period Cramps',
          naturalExplanation: isVi
              ? 'Kỳ kinh dự kiến bắt đầu hôm nay hoặc trong vài ngày tới; cảm giác căng tức vùng chậu rõ rệt.'
              : 'The estimated period window is reached; pelvic heaviness and cramp-like sensations are likely.',
          icon: Icons.waves,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Ngày dự kiến đến kỳ kinh' : 'Expected period threshold',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Nặng vùng chậu & mỏi lưng dưới' : 'Pelvic Heaviness & Back Discomfort',
          naturalExplanation: isVi
              ? 'Lưng dưới và vùng chậu có cảm giác nặng nề, cơ thể chuẩn bị bước vào kỳ kinh.'
              : 'Lower back and pelvis feel weighty as the body prepares to initiate bleeding.',
          icon: Icons.accessibility_new_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Ngưỡng chuyển giao chu kỳ' : 'Cycle reset threshold',
        ));
        physicalList.add(SymptomPossibility(
          label: isVi ? 'Năng lượng thể chất ở mức thấp' : 'Low Physical Energy Battery',
          naturalExplanation: isVi
              ? 'Nội tiết tố ở mức thấp nhất trước khi chu kỳ kinh mới bắt đầu.'
              : 'Hormones drop to cycle baselines; stamina is reserved for natural physiological shedding.',
          icon: Icons.battery_1_bar_outlined,
          type: PossibilityType.physical,
          likelihoodContext: isVi ? 'Năng lượng thấp' : 'Low energy baseline',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Sẵn sàng đón chu kỳ mới' : 'Ready for the Cycle to Reset',
          naturalExplanation: isVi
              ? 'Cảm giác sẵn sàng đón kỳ kinh để giải tỏa sự căng tức và nặng nề tích tụ nhiều ngày qua.'
              : 'Feeling ready for the period to arrive and release days of accumulated premenstrual tension.',
          icon: Icons.refresh_outlined,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Chờ đón kỳ kinh' : 'Anticipating period start',
        ));
        emotionalList.add(SymptomPossibility(
          label: isVi ? 'Cần sự vỗ về ấm áp & không áp lực' : 'Welcoming Reassurance & Zero Pressure',
          naturalExplanation: isVi
              ? 'Sự kiên nhẫn, cốc nước ấm và một ngày không áp lực sẽ làm cô ấy cảm kích vô cùng.'
              : 'Patient presence, a warm beverage, and zero pressure mean the world today.',
          icon: Icons.favorite_outline,
          type: PossibilityType.emotional,
          likelihoodContext: isVi ? 'Hoàn toàn không áp lực' : 'Zero pressure environment',
        ));
        break;
    }

    final String transparentNotice;
    if (isVi) {
      if (reliability == EstimateReliability.limitedInformation) {
        transparentNotice =
            'Ước tính cho ngày $day chu kỳ theo lịch sử 1 lần ghi nhận và chu kỳ mẫu 28 ngày. '
            'Đây là các khả năng mang tính tham khảo, không phải sự thật đã xác nhận. Cơ thể mỗi người luôn có sự khác biệt tự nhiên.';
      } else if (reliability == EstimateReliability.variableCycle) {
        transparentNotice =
            'Ước tính cho ngày $day chu kỳ theo lịch sử đã ghi nhận (có dao động tự nhiên). '
            'Các dự đoán là gợi ý để bạn quan tâm chu đáo, tuyệt đối không phải định kiến.';
      } else {
        transparentNotice =
            'Ước tính theo ngày $day của chu kỳ. Phản ánh các khả năng thường gặp ở thời điểm này, '
            'không khẳng định chính xác cảm nhận của cô ấy hôm nay.';
      }
    } else {
      if (reliability == EstimateReliability.limitedInformation) {
        transparentNotice =
            'Estimated for cycle day $day from 1 recorded period start date and a general 28-day baseline. '
            'These are day-specific possibilities, not confirmed facts. Individual experiences vary.';
      } else if (reliability == EstimateReliability.variableCycle) {
        transparentNotice =
            'Estimated for cycle day $day from her recorded cycle history (variable intervals observed). '
            'Possibilities are prompts for thoughtful check-ins, never assumptions.';
      } else {
        transparentNotice =
            'Estimated for cycle day $day. These reflect possibilities common to this point in the cycle, '
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

  /// Maps the raw [day] and [phase] into a normalized effective day (1..28+)
  /// ensuring adaptive scaling for varying cycle lengths.
  int _computeEffectiveDay(CycleEstimate estimate, int day, CyclePhase phase) {
    if (phase == CyclePhase.menstrual) {
      return day.clamp(1, 5);
    }

    final daysUntil = estimate.daysUntilEstimatedPeriod;

    // Late luteal approaching window (countdown to expected period)
    if (phase == CyclePhase.luteal && daysUntil != null && daysUntil <= 7) {
      if (daysUntil <= 0) return 28;
      if (daysUntil == 1) return 27;
      if (daysUntil == 2) return 26;
      if (daysUntil == 3) return 25;
      if (daysUntil == 4) return 24;
      if (daysUntil == 5) return 23;
      if (daysUntil <= 7) return 22;
    }

    if (phase == CyclePhase.ovulatory) {
      return day.clamp(12, 15);
    }

    if (phase == CyclePhase.follicular) {
      return day.clamp(6, 11);
    }

    if (phase == CyclePhase.luteal) {
      return day.clamp(15, 28);
    }

    return day.clamp(1, 28);
  }
}
