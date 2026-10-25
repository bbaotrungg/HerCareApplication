import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import 'package:hercare/features/care/domain/models/care_recommendation.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/notes/domain/models/care_preference.dart';
import 'package:hercare/features/symptoms/domain/models/daily_symptom_mood_estimate.dart';

/// Pure, deterministic care recommendation engine.
///
/// Generates warm, conversational, friend-to-friend care suggestions derived
/// directly from the same estimated symptom and mood context shown on the Dashboard.
/// Completely avoids robotic task-management language or checklists.
class RecommendationEngine {
  const RecommendationEngine();

  List<CareRecommendation> generateRecommendations({
    required DailySymptomMoodEstimate symptomMoodEstimate,
    required CycleEstimate cycleEstimate,
    List<CarePreference> preferences = const [],
    AppLanguage language = AppLanguage.en,
  }) {
    final list = <CareRecommendation>[];
    final phase = cycleEstimate.currentEstimatedPhase;
    final daysUntil = cycleEstimate.daysUntilEstimatedPeriod;
    final isVi = language == AppLanguage.vi;

    // 1. Approaching period window check (within 3 days)
    if (cycleEstimate.hasPrediction && daysUntil != null && daysUntil >= 0 && daysUntil <= 3) {
      list.add(CareRecommendation(
        id: 'prep_supplies',
        naturalThought: isVi
            ? 'Kỳ kinh dự kiến sắp đến, bạn có thể kín đáo kiểm tra tủ phòng tắm xem băng vệ sinh hoặc đồ dùng cô ấy thích có cần mua thêm trước khi cô ấy phải hỏi không.'
            : 'Maybe take a quiet look at the bathroom cabinet to see if her preferred pads, tampons, or comfort supplies need restocking before she has to ask.',
        gentleContext: isVi
            ? 'Chủ động chuẩn bị chu đáo những vật dụng cần thiết là hành động quan tâm rất tinh tế.'
            : 'Quietly anticipating practical needs is a tangible act of thoughtful care.',
        contextBasis: isVi
            ? 'Kỳ kinh dự kiến sắp đến'
            : 'Estimated period window approaching',
        category: RecommendationCategory.preparation,
        icon: Icons.inventory_2_outlined,
      ));
    }

    // 2. Physical possibilities integration
    for (final possibility in symptomMoodEstimate.physicalPossibilities) {
      final label = possibility.label.toLowerCase();

      if (label.contains('cramp') || label.contains('đau tức bụng')) {
        list.add(CareRecommendation(
          id: 'care_cramps_heat',
          naturalThought: isVi
              ? 'Nếu cô ấy nhắc đến việc đau bụng hoặc căng tức, bạn có thể chủ động làm ấm túi chườm hoặc chuẩn bị một bình nước nóng.'
              : 'If she mentions any cramping or pelvic tension, you could offer to warm up a heating pad or prepare a hot water bottle.',
          gentleContext: isVi
              ? 'Nhiệt ấm tự nhiên giúp thư giãn các cơ vùng chậu và mang lại sự xoa dịu dễ chịu.'
              : 'Heat naturally relaxes pelvic smooth muscle tissue and provides comforting relief.',
          contextBasis: isVi ? 'Có thể đau tức bụng hôm nay' : 'Possible cramps today',
          category: RecommendationCategory.comfort,
          icon: Icons.hot_tub_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_cramps_tea',
          naturalThought: isVi
              ? 'Hãy đề nghị pha cho cô ấy một tách trà hoa cúc, bạc hà hoặc trà gừng ấm áp.'
              : 'Offer to brew a cup of soothing warm chamomile, peppermint, or ginger tea.',
          gentleContext: isVi
              ? 'Đồ uống ấm không chứa caffeine giúp làm ấm cơ thể và tạo cảm giác thư giãn.'
              : 'Warm, caffeine-free hydration soothes the stomach and invites relaxation.',
          contextBasis: isVi ? 'Có thể đau tức hoặc khó chịu' : 'Possible cramps or discomfort',
          category: RecommendationCategory.comfort,
          icon: Icons.coffee_outlined,
        ));
      } else if (label.contains('fatigue') ||
          label.contains('lower energy') ||
          label.contains('mệt mỏi') ||
          label.contains('năng lượng thấp')) {
        list.add(CareRecommendation(
          id: 'care_fatigue_chores',
          naturalThought: isVi
              ? 'Nếu cô ấy có vẻ mệt mỏi hôm nay, hãy chủ động lo bữa tối, rửa bát hoặc đi chợ để chia sẻ gánh nặng cùng cô ấy.'
              : 'If she seems a bit worn out today, offering to take care of dinner, do the dishes, or run errands can take a real weight off her shoulders.',
          gentleContext: isVi
              ? 'Sự giúp đỡ thiết thực giúp cô ấy tiết kiệm sức lực và yên tâm nghỉ ngơi.'
              : 'Practical help frees up her energy and allows guilt-free rest.',
          contextBasis: isVi ? 'Có thể mệt mỏi hôm nay' : 'Possible lower energy today',
          category: RecommendationCategory.practicalHelp,
          icon: Icons.cleaning_services_outlined,
        ));
      } else if (label.contains('back') || label.contains('thắt lưng') || label.contains('lưng')) {
        list.add(CareRecommendation(
          id: 'care_back_support',
          naturalThought: isVi
              ? 'Nếu lưng dưới của cô ấy bị căng mỏi, bạn có thể lấy thêm gối tựa hoặc nhẹ nhàng mát-xa lưng cho cô ấy.'
              : 'If her lower back feels tight, you could offer an extra supportive cushion or ask if a gentle lower-back rub would feel soothing.',
          gentleContext: isVi
              ? 'Gối tựa êm ái giúp giảm bớt áp lực lên vùng thắt lưng.'
              : 'Supportive pillows ease pressure on pelvic ligaments.',
          contextBasis: isVi ? 'Có thể mỏi lưng dưới' : 'Possible back discomfort',
          category: RecommendationCategory.comfort,
          icon: Icons.airline_seat_recline_normal_outlined,
        ));
      } else if (label.contains('bloating') || label.contains('đầy hơi')) {
        list.add(CareRecommendation(
          id: 'care_bloating_meal',
          naturalThought: isVi
              ? 'Nếu cô ấy cảm thấy đầy hơi hoặc tức bụng, hãy gợi ý những món ăn thanh đạm như súp ấm, cơm mềm hay trái cây tươi thay vì đồ ăn nhiều dầu mỡ.'
              : 'If she mentions feeling bloated or full, suggest light and comforting meals like warm soup, rice, or fresh fruit over heavy, salty takeout.',
          gentleContext: isVi
              ? 'Thực phẩm dễ tiêu hóa giúp giảm tải cho dạ dày trong những ngày này.'
              : 'Easily digestible foods ease digestive workload during hormonal shifts.',
          contextBasis: isVi ? 'Có thể đầy hơi hôm nay' : 'Possible bloating today',
          category: RecommendationCategory.comfort,
          icon: Icons.restaurant_outlined,
        ));
      } else if (label.contains('headache') ||
          label.contains('tenderness') ||
          label.contains('căng tức ngực')) {
        list.add(CareRecommendation(
          id: 'care_headache_calm',
          naturalThought: isVi
              ? 'Nếu cô ấy cảm thấy đau đầu hoặc nhạy cảm, hãy chỉnh ánh sáng trong phòng dịu lại, giảm âm lượng và mang cho cô ấy một cốc nước mát.'
              : 'If she mentions a headache or sensitivity, try dimming bright room lights, lowering screen volume, and bringing a tall glass of cool water.',
          gentleContext: isVi
              ? 'Giảm bớt kích thích từ môi trường giúp xoa dịu cơn đau đầu căng thẳng.'
              : 'Minimizing sensory stimulation helps ease tension headaches.',
          contextBasis: isVi ? 'Có thể nhạy cảm về thể chất' : 'Possible physical sensitivity',
          category: RecommendationCategory.comfort,
          icon: Icons.lightbulb_outline,
        ));
      } else if (label.contains('little or no') ||
          label.contains('comfort') ||
          label.contains('thoải mái')) {
        list.add(CareRecommendation(
          id: 'care_normal_day',
          naturalThought: isVi
              ? 'Nếu hôm nay cô ấy cảm thấy thoải mái và tràn đầy năng lượng, không cần làm gì quá đặc biệt về chu kỳ. Hãy cứ tận hưởng trọn vẹn thời gian bên nhau.'
              : 'If she feels comfortable and energetic today, there is no need to do anything special regarding her cycle. Simply enjoy your time together.',
          gentleContext: isVi
              ? 'Tôn trọng nhịp sống bình thường của cô ấy cũng quan trọng như việc chăm sóc khi cô ấy không khỏe.'
              : 'Respecting her normal flow is just as important as offering care when she is uncomfortable.',
          contextBasis: isVi ? 'Giai đoạn thoải mái' : 'Comfortable phase timing',
          category: RecommendationCategory.connection,
          icon: Icons.spa_outlined,
        ));
      }
    }

    // 3. Emotional possibilities integration
    for (final possibility in symptomMoodEstimate.emotionalPossibilities) {
      final label = possibility.label.toLowerCase();

      if (label.contains('rest') ||
          label.contains('quiet') ||
          label.contains('nghỉ ngơi') ||
          label.contains('yên tĩnh')) {
        list.add(CareRecommendation(
          id: 'care_quiet_space',
          naturalThought: isVi
              ? 'Hãy tạo cho cô ấy không gian riêng để đọc sách, nghỉ ngơi hoặc nạp lại năng lượng mà không cảm thấy khó chịu khi cô ấy muốn yên tĩnh.'
              : 'Give her dedicated space to read, rest, or recharge without taking her desire for quiet time personally.',
          gentleContext: isVi
              ? 'Khoảng thời gian một mình yên tĩnh giúp hệ thần kinh được thư giãn sâu.'
              : 'Solitary downtime allows her nervous system to rest peacefully.',
          contextBasis: isVi ? 'Có thể cần không gian yên tĩnh' : 'Possible need for quiet time',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.bedtime_outlined,
        ));
      } else if (label.contains('stress') ||
          label.contains('overwhelm') ||
          label.contains('căng thẳng')) {
        list.add(CareRecommendation(
          id: 'care_listen_patiently',
          naturalThought: isVi
              ? 'Đôi khi chỉ cần lắng nghe kiên nhẫn mà không vội vàng giải quyết vấn đề là sự hỗ trợ tốt nhất. Hãy hỏi: "Em muốn anh lắng nghe hay muốn anh góp ý?"'
              : 'Sometimes just listening without immediately trying to solve every problem is the best support. Ask: "Would you like advice, or just a listening ear?"',
          gentleContext: isVi
              ? 'Cảm giác được lắng nghe và an toàn về mặt cảm xúc thường là điều cô ấy cần nhất.'
              : 'Feeling heard and emotionally safe is often what she needs most.',
          contextBasis: isVi ? 'Có thể nhạy cảm với căng thẳng' : 'Possible sensitivity to stress',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.hearing_outlined,
        ));
      } else if (label.contains('reassurance') ||
          label.contains('support') ||
          label.contains('sẻ chia')) {
        list.add(CareRecommendation(
          id: 'care_reassurance',
          naturalThought: isVi
              ? 'Một lời hỏi thăm dịu dàng, không vội vã hoặc một cái ôm ấm áp sẽ giúp cô ấy cảm thấy được che chở.'
              : 'A gentle, unhurried check-in or a warm hug can go a long way. Let her tell you what she needs without pressing.',
          gentleContext: isVi
              ? 'Sự vỗ về củng cố niềm tin và sự gắn kết tình cảm.'
              : 'Reassurance reinforces trust and emotional intimacy.',
          contextBasis: isVi ? 'Có thể cần sự an ủi nhẹ nhàng' : 'May welcome gentle reassurance',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.favorite_outline,
        ));
      } else if (label.contains('sociable') ||
          label.contains('connected') ||
          label.contains('kết nối') ||
          label.contains('vui vẻ')) {
        list.add(CareRecommendation(
          id: 'care_shared_plans',
          naturalThought: isVi
              ? 'Năng lượng và tinh thần của cô ấy hôm nay rất tích cực—thời điểm tuyệt vời để cùng nhau dạo phố, nấu ăn hoặc lên kế hoạch đi chơi.'
              : 'Energy and social bandwidth seem high today—a wonderful day for an outdoor stroll together, cooking a fun meal, or planning an outing.',
          gentleContext: isVi
              ? 'Cùng nhau tham gia các hoạt động vui vẻ rất phù hợp với những ngày giàu năng lượng.'
              : 'Sharing uplifting activities matches high-vitality days.',
          contextBasis: isVi ? 'Thời điểm năng lượng tích cực' : 'Sociable follicular or mid-cycle timing',
          category: RecommendationCategory.connection,
          icon: Icons.people_outline,
        ));
      }
    }

    // 4. Saved preferences integration
    for (final pref in preferences) {
      if (pref.category.toLowerCase().contains('snack') ||
          pref.category.toLowerCase().contains('comfort')) {
        list.add(CareRecommendation(
          id: 'pref_${pref.id}',
          naturalThought: isVi
              ? 'Tạo bất ngờ cho cô ấy với món đồ cô ấy thích: ${pref.title}.${pref.description.isNotEmpty ? " (${pref.description})" : ""}'
              : 'Surprise her with her favorite comfort: ${pref.title}.${pref.description.isNotEmpty ? " (${pref.description})" : ""}',
          gentleContext: isVi
              ? 'Sự chu đáo trong từng chi tiết nhỏ thể hiện tình cảm chân thành của bạn.'
              : 'Thoughtful personal touches reflect attentiveness and genuine affection.',
          contextBasis: isVi ? 'Từ sở thích đã lưu của cô ấy' : 'From saved partner preferences',
          category: RecommendationCategory.comfort,
          icon: Icons.card_giftcard_outlined,
        ));
        break; // Display top preference
      }
    }

    // 5. Fallback suggestions if list is sparse or history is minimal
    if (list.length < 2) {
      if (phase == CyclePhase.menstrual) {
        list.add(CareRecommendation(
          id: 'general_menstrual_checkin',
          naturalThought: isVi
              ? 'Hãy hỏi thăm cô ấy thật nhẹ nhàng: "Hôm nay em cảm thấy thế nào? Anh có thể lấy nước hoặc làm gì cho em thoải mái hơn không?"'
              : 'Maybe check in with her gently and ask: "How are you feeling today? Can I bring you some water or make you comfortable?"',
          gentleContext: isVi
              ? 'Những câu hỏi không tạo áp lực giúp cô ấy dễ dàng chia sẻ điều mình cần.'
              : 'Low-pressure inquiries let her express what feels right.',
          contextBasis: isVi ? 'Giai đoạn kinh nguyệt dự kiến' : 'Estimated Menstrual Phase',
          category: RecommendationCategory.comfort,
          icon: Icons.favorite_border,
        ));
      } else {
        list.add(CareRecommendation(
          id: 'general_gentle_checkin',
          naturalThought: isVi
              ? 'Hãy hỏi thăm cô ấy bằng một câu hỏi cởi mở, ấm áp: "Hôm nay của em thế nào rồi?"'
              : 'Maybe check in with her with a warm, open-ended question: "How has your day been so far?"',
          gentleContext: isVi
              ? 'Một câu hỏi đơn giản, chân thành cho thấy bạn luôn hiện diện và quan tâm.'
              : 'A simple, unhurried question shows you are present and attentive.',
          contextBasis: isVi ? 'Kết nối chu đáo hàng ngày' : 'Thoughtful daily connection',
          category: RecommendationCategory.connection,
          icon: Icons.chat_bubble_outline,
        ));
      }
      list.add(CareRecommendation(
        id: 'general_water_drink',
        naturalThought: isVi
            ? 'Bạn có thể mang cho cô ấy một cốc nước ấm hoặc món đồ uống cô ấy yêu thích cùng nụ cười ấm áp.'
            : 'You could bring her a fresh glass of water or her favorite beverage with a warm smile.',
        gentleContext: isVi
            ? 'Uống đủ nước giúp duy trì sức khỏe tốt trong mọi giai đoạn chu kỳ.'
            : 'Hydration supports daily well-being across all cycle phases.',
        contextBasis: isVi ? 'Hành động chu đáo hàng ngày' : 'Thoughtful daily gesture',
        category: RecommendationCategory.comfort,
        icon: Icons.local_drink_outlined,
      ));
    }

    // Deduplicate recommendations by id
    final seen = <String>{};
    final uniqueList = <CareRecommendation>[];
    for (final r in list) {
      if (seen.add(r.id)) {
        uniqueList.add(r);
      }
    }

    return uniqueList;
  }
}
