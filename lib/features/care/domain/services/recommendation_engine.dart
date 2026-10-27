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
/// dynamically from individual cycle days, estimated phases, and symptoms.
/// Varies across individual days throughout the cycle to avoid repetitive advice
/// on consecutive days, while keeping a natural, empathetic human voice.
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
    final day = cycleEstimate.dayOfCycle;
    final daysUntil = cycleEstimate.daysUntilEstimatedPeriod;
    final isVi = language == AppLanguage.vi;

    // 1. Approaching period window supply check (within 3 days of expected start)
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

    // 2. Saved partner comfort preferences integration
    for (final pref in preferences) {
      if (pref.category.toLowerCase().contains('snack') ||
          pref.category.toLowerCase().contains('comfort') ||
          pref.category.toLowerCase().contains('favorite') ||
          pref.category.toLowerCase().contains('sở thích')) {
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
        break; // Show top preference
      }
    }

    // 3. Dynamic Day-by-Day Care Suggestions
    if (day != null) {
      final effectiveDay = _computeEffectiveDay(cycleEstimate, day, phase);
      _populateDaySpecificSuggestions(list, effectiveDay, isVi);
    }

    // 4. Ensure minimum 2 suggestions if list is sparse
    if (list.length < 2) {
      _addEmptyStateSuggestions(list, phase, isVi);
    }

    return _deduplicate(list);
  }

  void _populateDaySpecificSuggestions(
    List<CareRecommendation> list,
    int effectiveDay,
    bool isVi,
  ) {
    switch (effectiveDay) {
      case 1:
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
        list.add(CareRecommendation(
          id: 'care_day1_tea',
          naturalThought: isVi
              ? 'Pha cho cô ấy một tách trà gừng hoặc trà quế ấm nóng để làm dịu các cơn co thắt từ bên trong.'
              : 'Brew a cup of freshly steeped warm ginger or cinnamon tea to gently comfort her from the inside out.',
          gentleContext: isVi
              ? 'Gừng và thảo mộc ấm giúp hỗ trợ tuần hoàn và thư giãn cơ.'
              : 'Ginger naturally supports circulation and soothes acute pelvic tightness.',
          contextBasis: isVi ? 'Ngày đầu kỳ kinh' : 'Day 1 of menstruation',
          category: RecommendationCategory.comfort,
          icon: Icons.coffee_outlined,
        ));
        break;

      case 2:
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
        break;

      case 3:
        list.add(CareRecommendation(
          id: 'care_day3_chamomile',
          naturalThought: isVi
              ? 'Hãy đề nghị pha cho cô ấy một tách trà hoa cúc hoặc bạc hà ấm áp khi các cơn đau bắt đầu dịu dần.'
              : 'Offer to brew a soothing cup of chamomile or peppermint tea as cramps begin to lighten.',
          gentleContext: isVi
              ? 'Hoa cúc giúp xoa dịu hệ thần kinh và làm dịu nhẹ vùng chậu.'
              : 'Chamomile calms the nervous system and relaxes residual pelvic tightness.',
          contextBasis: isVi ? 'Ngày 3 kỳ kinh' : 'Day 3 menstrual easing',
          category: RecommendationCategory.comfort,
          icon: Icons.spa_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day3_movie',
          naturalThought: isVi
              ? 'Tối nay, hãy cùng cô ấy xem một bộ phim nhẹ nhàng hoặc cùng nhau đọc sách mà không cần vội vã.'
              : 'Plan a cozy, low-key movie or reading evening together without any social rushing.',
          gentleContext: isVi
              ? 'Không gian thư giãn nhẹ nhàng là món quà tuyệt vời khi năng lượng bắt đầu hồi sinh.'
              : 'Low-key shared downtime matches her stabilizing energy levels.',
          contextBasis: isVi ? 'Buổi tối thư thái' : 'Relaxing evening timing',
          category: RecommendationCategory.connection,
          icon: Icons.movie_outlined,
        ));
        break;

      case 4:
        list.add(CareRecommendation(
          id: 'care_day4_fruits',
          naturalThought: isVi
              ? 'Mang đến cho cô ấy một đĩa trái cây tươi cắt sẵn hoặc ly sinh tố thanh mát để bổ sung nước và vitamin.'
              : 'Bring her a plate of fresh sliced fruit or a hydrating smoothie to restore vitamins and hydration.',
          gentleContext: isVi
              ? 'Trái cây mọng nước và chất chống oxy hóa hỗ trợ cơ thể phục hồi thể lực.'
              : 'Hydrating fruits and antioxidants support physical vitality during post-flow recovery.',
          contextBasis: isVi ? 'Giai đoạn hồi phục năng lượng' : 'Energy recovery timing',
          category: RecommendationCategory.comfort,
          icon: Icons.apple_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day4_stroll',
          naturalThought: isVi
              ? 'Nếu cô ấy thấy khỏe hơn, hãy rủ cô ấy đi dạo hít thở không khí trong lành một cách thong thả.'
              : 'If she feels energized, invite her for an unhurried walk outdoors in the fresh air.',
          gentleContext: isVi
              ? 'Vận động nhẹ nhàng giúp kích thích lưu thông máu và nâng cao tâm trạng.'
              : 'Gentle movement stimulates circulation and naturally elevates mood.',
          contextBasis: isVi ? 'Cuối kỳ kinh nhẹ nhõm' : 'Tapering flow window',
          category: RecommendationCategory.connection,
          icon: Icons.directions_walk_outlined,
        ));
        break;

      case 5:
        list.add(CareRecommendation(
          id: 'care_day5_treat',
          naturalThought: isVi
              ? 'Tạo bất ngờ cho cô ấy bằng một ly cà phê, trà sữa hay món bánh ngọt cô ấy thích để cùng mừng kỳ kinh kết thúc.'
              : 'Surprise her with her favorite coffee, tea, or pastry to celebrate the end of her period.',
          gentleContext: isVi
              ? 'Một hành động kỷ niệm nhỏ bé mang lại nụ cười rạng rỡ và sự gắn kết.'
              : 'A small celebratory gesture marks the reset of her cycle with shared joy.',
          contextBasis: isVi ? 'Kết thúc kỳ kinh' : 'Period conclusion celebration',
          category: RecommendationCategory.comfort,
          icon: Icons.cake_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day5_plans',
          naturalThought: isVi
              ? 'Cùng nhau bàn về những kế hoạch cuối tuần thú vị khi năng lượng của cô ấy đang dồi dào trở lại.'
              : 'Talk together about exciting weekend plans or date ideas as her vitality bounds back.',
          gentleContext: isVi
              ? 'Lên kế hoạch chung tạo cảm giác háo hức và đồng điệu.'
              : 'Shared planning builds anticipatory excitement and intimacy.',
          contextBasis: isVi ? 'Năng lượng tươi mới' : 'Fresh cycle vitality',
          category: RecommendationCategory.connection,
          icon: Icons.calendar_today_outlined,
        ));
        break;

      case 6:
        list.add(CareRecommendation(
          id: 'care_day6_hobby',
          naturalThought: isVi
              ? 'Khích lệ và ủng hộ cô ấy dành thời gian cho sở thích hoặc dự án cá nhân mà cô ấy yêu thích.'
              : 'Encourage her to dive into a creative hobby or personal project she is passionate about.',
          gentleContext: isVi
              ? 'Đầu giai đoạn nang trứng là thời điểm tuyệt vời để khởi xướng các ý tưởng sáng tạo.'
              : 'Early follicular days naturally bring mental freshness and creative spark.',
          contextBasis: isVi ? 'Đầu giai đoạn nang trứng' : 'Early follicular awakening',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.brush_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day6_fresh_meal',
          naturalThought: isVi
              ? 'Cùng nhau chuẩn bị một bữa tối thanh đạm, nhiều màu sắc và dinh dưỡng để mở đầu tuần mới.'
              : 'Cook a vibrant, colorful, nutrient-rich dinner together to kickstart the new cycle phase.',
          gentleContext: isVi
              ? 'Bữa ăn lành mạnh kết hợp niềm vui nấu nướng chung làm tăng sự gắn kết.'
              : 'Nourishing food combined with collaborative cooking fosters closeness.',
          contextBasis: isVi ? 'Chăm sóc sức sống mới' : 'Nutritional support',
          category: RecommendationCategory.connection,
          icon: Icons.restaurant_outlined,
        ));
        break;

      case 7:
        list.add(CareRecommendation(
          id: 'care_day7_explore',
          naturalThought: isVi
              ? 'Thời điểm thể lực đang lên, hãy gợi ý cùng nhau đi dạo công viên hoặc ghé một quán cà phê mới.'
              : 'With her stamina rising, suggest checking out a new coffee shop, park, or neighborhood street.',
          gentleContext: isVi
              ? 'Khám phá không gian mới mang lại sự hào hứng và trải nghiệm thú vị.'
              : 'Novel environments spark shared joy during high-vitality days.',
          contextBasis: isVi ? 'Thể lực đang tăng trưởng' : 'Climbing stamina timing',
          category: RecommendationCategory.connection,
          icon: Icons.explore_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day7_conversation',
          naturalThought: isVi
              ? 'Lắng nghe và thảo luận say mê về những ý tưởng, suy nghĩ mới mà cô ấy muốn chia sẻ.'
              : 'Engage in lively, curious discussions about new ideas, books, or goals she is excited about.',
          gentleContext: isVi
              ? 'Sự đồng điệu về trí tuệ và cảm xúc làm sâu sắc thêm tình cảm lứa đôi.'
              : 'Intellectual and emotional resonance deepens your mutual bond.',
          contextBasis: isVi ? 'Tinh thần cởi mở' : 'Expressive mindset',
          category: RecommendationCategory.connection,
          icon: Icons.chat_bubble_outline,
        ));
        break;

      case 8:
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
        list.add(CareRecommendation(
          id: 'care_day8_goals',
          naturalThought: isVi
              ? 'Động viên và cổ vũ những mục tiêu công việc hoặc học tập của cô ấy với sự tin tưởng tuyệt đối.'
              : 'Affirm and cheer on her work ambitions or personal milestones with steady confidence.',
          gentleContext: isVi
              ? 'Sự ủng hộ chân thành từ người yêu là nguồn động lực to lớn nhất.'
              : 'Genuine encouragement from a partner is deeply empowering.',
          contextBasis: isVi ? 'Giai đoạn tập trung cao' : 'Mid-follicular focus',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.trending_up,
        ));
        break;

      case 9:
        list.add(CareRecommendation(
          id: 'care_day9_date',
          naturalThought: isVi
              ? 'Lên kế hoạch cho một buổi hẹn hò đặc biệt tại nhà hàng cô ấy thích hoặc cùng nhau đi xem kịch, triển lãm.'
              : 'Plan a special date night out at her favorite restaurant or a cultural event together.',
          gentleContext: isVi
              ? 'Tận dụng thời điểm năng lượng dồi dào để tạo thêm những kỷ niệm lãng mạn đáng nhớ.'
              : 'Capitalizing on high social energy fosters memorable romantic memories.',
          contextBasis: isVi ? 'Năng lượng dồi dào' : 'High energy & focus',
          category: RecommendationCategory.connection,
          icon: Icons.local_activity_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day9_teamwork',
          naturalThought: isVi
              ? 'Cùng nhau bắt tay hoàn thành một việc nhà vui vẻ hoặc sắp xếp lại góc phòng cho gọn gàng.'
              : 'Tackle a fun home rearrangement or joint project while collaborative energy is high.',
          gentleContext: isVi
              ? 'Sự phối hợp ăn ý trong công việc chung mang lại cảm giác gắn bó khăng khít.'
              : 'Smooth teamwork builds closeness and a sense of shared accomplishment.',
          contextBasis: isVi ? 'Tinh thần hợp tác' : 'Collaborative rhythm',
          category: RecommendationCategory.practicalHelp,
          icon: Icons.handshake_outlined,
        ));
        break;

      case 10:
        list.add(CareRecommendation(
          id: 'care_day10_workout',
          naturalThought: isVi
              ? 'Rủ cô ấy cùng tập thể dục, chạy bộ hoặc tập yoga để cùng nhau giải phóng năng lượng thể chất.'
              : 'Join her for a workout, outdoor run, or active fitness session with her peak stamina.',
          gentleContext: isVi
              ? 'Vận động cùng nhau không chỉ tốt cho sức khỏe mà còn tăng thêm niềm vui.'
              : 'Exercising together taps into high physical resilience and mutual joy.',
          contextBasis: isVi ? 'Thể lực sung mãn' : 'Peak physical resilience',
          category: RecommendationCategory.connection,
          icon: Icons.fitness_center_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day10_romance',
          naturalThought: isVi
              ? 'Dành tặng cô ấy một lời khen ngợi chân thành về sự rạng rỡ và nụ cười tươi tắn của cô ấy hôm nay.'
              : 'Offer a spontaneous, heartfelt compliment on her radiant glow and positive energy.',
          gentleContext: isVi
              ? 'Sự chú ý và lời khen tinh tế luôn sưởi ấm trái tim cô ấy.'
              : 'Attentive, specific compliments make her feel truly seen and cherished.',
          contextBasis: isVi ? 'Sắc vóc tươi tắn' : 'Radiant presence',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.favorite,
        ));
        break;

      case 11:
        list.add(CareRecommendation(
          id: 'care_day11_dinner_out',
          naturalThought: isVi
              ? 'Cùng nhau diện đồ đẹp và thưởng thức một bữa tối lãng mạn nhân lúc thần thái của cô ấy đang ở đỉnh cao.'
              : 'Dress up for a romantic candlelit dinner together while her sociability and glow are at their peak.',
          gentleContext: isVi
              ? 'Những khoảnh khắc lãng mạn giữa chu kỳ tạo điểm nhấn hạnh phúc trong tình yêu.'
              : 'Mid-cycle romantic dates create cherished relationship highlights.',
          contextBasis: isVi ? 'Đỉnh cao sắc thái' : 'Pre-ovulation radiance',
          category: RecommendationCategory.connection,
          icon: Icons.wine_bar_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day11_photos',
          naturalThought: isVi
              ? 'Chụp cho cô ấy những bức ảnh thật đẹp để lưu giữ vẻ rạng ngời và sự tự tin của cô ấy.'
              : 'Take a few lovely, candid photos of her looking confident, happy, and radiant.',
          gentleContext: isVi
              ? 'Lưu lại những khoảnh khắc đẹp là cách thể hiện sự trân trọng chân thành.'
              : 'Capturing candid moments celebrates her beauty and makes her smile.',
          contextBasis: isVi ? 'Tự tin & cuốn hút' : 'Confidence & magnetism',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.photo_camera_outlined,
        ));
        break;

      case 12:
        list.add(CareRecommendation(
          id: 'care_day12_connect',
          naturalThought: isVi
              ? 'Dành trọn vẹn buổi tối để tâm sự sâu lắng, lắng nghe những tâm tư và ước mơ của cô ấy mà không bị điện thoại làm phiền.'
              : 'Set aside undistracted evening time for deep, intimate conversation and heartfelt listening.',
          gentleContext: isVi
              ? 'Sự hiện diện 100% không xao nhãng là món quà tình cảm vô giá.'
              : 'Undivided presence and deep listening nurture emotional intimacy.',
          contextBasis: isVi ? 'Khao khát gần gũi' : 'Desire for deep connection',
          category: RecommendationCategory.connection,
          icon: Icons.favorite_border,
        ));
        list.add(CareRecommendation(
          id: 'care_day12_music',
          naturalThought: isVi
              ? 'Bật những bản nhạc cô ấy thích, tạo không gian ấm áp và cùng nhau khiêu vũ hoặc thư giãn nhẹ nhàng.'
              : 'Put on her favorite playlist and share a slow, affectionate moment or dance in the living room.',
          gentleContext: isVi
              ? 'Âm nhạc và sự tiếp xúc dịu dàng khơi gợi cảm xúc yêu thương nồng nàn.'
              : 'Music and gentle touch cultivate warmth and playful romance.',
          contextBasis: isVi ? 'Không gian ngọt ngào' : 'Romantic atmosphere',
          category: RecommendationCategory.connection,
          icon: Icons.music_note_outlined,
        ));
        break;

      case 13:
        list.add(CareRecommendation(
          id: 'care_day13_compliment',
          naturalThought: isVi
              ? 'Gửi cho cô ấy một tin nhắn ngọt ngào trong ngày hoặc ôm cô ấy thật chặt khi gặp nhau.'
              : 'Send her a sweet mid-day appreciation message or greet her with a warm, lingering hug.',
          gentleContext: isVi
              ? 'Những lời yêu thương bất ngờ luôn mang lại sự ấm áp trong lòng.'
              : 'Spontaneous affectionate words make her feel uniquely treasured.',
          contextBasis: isVi ? 'Giai đoạn rụng trứng' : 'Ovulatory surge window',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.favorite,
        ));
        list.add(CareRecommendation(
          id: 'care_day13_spontaneous',
          naturalThought: isVi
              ? 'Mang về một bông hoa nhỏ hoặc món quà ngọt ngào nho nhỏ không nhân dịp gì cả.'
              : 'Bring home a small surprise—like a fresh flower stem or her favorite sweet bite—just because.',
          gentleContext: isVi
              ? 'Bất ngờ nhỏ cho thấy bạn luôn nghĩ đến cô ấy mọi lúc mọi nơi.'
              : 'Unprompted little surprises show she is constantly on your mind.',
          contextBasis: isVi ? 'Gắn kết yêu thương' : 'Thoughtful surprise',
          category: RecommendationCategory.comfort,
          icon: Icons.card_giftcard_outlined,
        ));
        break;

      case 14:
        list.add(CareRecommendation(
          id: 'care_day14_mittelschmerz',
          naturalThought: isVi
              ? 'Nếu cô ấy cảm thấy nhói nhẹ vùng bụng dưới giữa chu kỳ, một động tác xoa bóp vai hoặc lưng nhẹ nhàng sẽ rất dễ chịu.'
              : 'If she notices brief mid-cycle pelvic twinges, a gentle shoulder or back rub feels wonderfully soothing.',
          gentleContext: isVi
              ? 'Cơn nhói nhẹ khi rụng trứng sẽ nhanh chóng qua đi khi được xoa dịu bằng cử chỉ ân cần.'
              : 'Mild ovulatory twinges pass quickly with gentle attention and physical warmth.',
          contextBasis: isVi ? 'Ngày rụng trứng giữa chu kỳ' : 'Ovulation midpoint timing',
          category: RecommendationCategory.comfort,
          icon: Icons.spa_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day14_shared_joy',
          naturalThought: isVi
              ? 'Tận hưởng trọn vẹn ngày hôm nay với những nụ cười, sự đồng hành ấm áp và kỷ niệm đẹp bên nhau.'
              : 'Celebrate today\'s high vitality by enjoying quality time and heartfelt laughs together.',
          gentleContext: isVi
              ? 'Giai đoạn rụng trứng là đỉnh cao của sự hòa hợp và hạnh phúc đôi lứa.'
              : 'Mid-cycle peaks are natural opportunities to celebrate your mutual happiness.',
          contextBasis: isVi ? 'Hòa hợp đỉnh cao' : 'High vitality celebration',
          category: RecommendationCategory.connection,
          icon: Icons.celebration_outlined,
        ));
        break;

      case 15:
        list.add(CareRecommendation(
          id: 'care_day15_unwind',
          naturalThought: isVi
              ? 'Bắt đầu nhịp sinh hoạt buổi tối thư thả, êm dịu khi cơ thể cô ấy chuyển dần sang giai đoạn hoàng thể.'
              : 'Ease into an unhurried, peaceful evening routine as her cycle transitions into the luteal phase.',
          gentleContext: isVi
              ? 'Sự chuyển nhịp nhẹ nhàng giúp cơ thể thích ứng êm ái với sự thay đổi nội tiết tố.'
              : 'A smooth transition supports her body as progesterone begins taking the lead.',
          contextBasis: isVi ? 'Chuyển giao sau rụng trứng' : 'Post-ovulatory transition',
          category: RecommendationCategory.comfort,
          icon: Icons.nightlight_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day15_water',
          naturalThought: isVi
              ? 'Chuẩn bị một bình nước lọc có vài lát dưa leo, chanh hoặc lá bạc hà mát lành cho cô ấy.'
              : 'Prepare a refreshing carafe of water infused with cucumber or lemon for her desk or bedside.',
          gentleContext: isVi
              ? 'Uống đủ nước giúp thanh lọc cơ thể và giữ năng lượng ổn định.'
              : 'Consistent hydration smooths out the metabolic shift into early luteal days.',
          contextBasis: isVi ? 'Bổ sung nước thanh lọc' : 'Hydration support',
          category: RecommendationCategory.comfort,
          icon: Icons.local_drink_outlined,
        ));
        break;

      case 16:
        list.add(CareRecommendation(
          id: 'care_day16_home_dinner',
          naturalThought: isVi
              ? 'Chuẩn bị một bữa cơm gia đình nóng hổi, đầm ấm với các món ăn thanh nhẹ, giàu dưỡng chất.'
              : 'Prepare a warm, wholesome home-cooked dinner featuring hearty vegetables and comfort proteins.',
          gentleContext: isVi
              ? 'Cơm nhà nóng sốt mang lại cảm giác bình yên và sự chăm sóc từ tận đáy lòng.'
              : 'Nourishing home cooking anchors the calm, grounded rhythm of early luteal days.',
          contextBasis: isVi ? 'Đầu giai đoạn hoàng thể' : 'Early luteal grounding',
          category: RecommendationCategory.practicalHelp,
          icon: Icons.soup_kitchen_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day16_ambient',
          naturalThought: isVi
              ? 'Thắp một ngọn nến thơm hoặc bật đèn ngủ màu vàng ấm để tạo không gian thư giãn tuyệt đối cho căn phòng.'
              : 'Light a calming candle or switch to warm amber lighting to create a tranquil sanctuary at home.',
          gentleContext: isVi
              ? 'Ánh sáng ấm cúng giúp xoa dịu hệ thần kinh và đưa giấc ngủ về tự nhiên.'
              : 'Gentle lighting signals safety and prompts natural evening relaxation.',
          contextBasis: isVi ? 'Không gian thư thái' : 'Peaceful home ambiance',
          category: RecommendationCategory.comfort,
          icon: Icons.lightbulb_outline,
        ));
        break;

      case 17:
        list.add(CareRecommendation(
          id: 'care_day17_listen',
          naturalThought: isVi
              ? 'Sau bữa tối, hãy ngồi lại trò chuyện và lắng nghe cô ấy kể về một ngày của mình với sự kiên nhẫn, không vội vã.'
              : 'Sit down together with warm tea and ask about her day with unhurried curiosity and quiet presence.',
          gentleContext: isVi
              ? 'Được lắng nghe chân thành là nhu cầu cảm xúc quý giá trong những ngày này.'
              : 'Attentive, unhurried listening fulfills an important emotional grounding need.',
          contextBasis: isVi ? 'Lắng nghe chân thành' : 'Grounded listening',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.hearing_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day17_cozy',
          naturalThought: isVi
              ? 'Lấy thêm một chiếc chăn mềm đắp lên chân cho cô ấy khi hai người cùng ngồi trò chuyện trên ghế sofa.'
              : 'Tuck a soft throw blanket around her legs while relaxing on the sofa together.',
          gentleContext: isVi
              ? 'Cử chỉ chăm sóc nho nhỏ mang lại cảm giác được chở che ấm áp.'
              : 'Simple physical tenderness communicates protection and unconditional care.',
          contextBasis: isVi ? 'Cử chỉ ân cần' : 'Comfort gesture',
          category: RecommendationCategory.comfort,
          icon: Icons.bedtime_outlined,
        ));
        break;

      case 18:
        list.add(CareRecommendation(
          id: 'care_day18_warm_dish',
          naturalThought: isVi
              ? 'Nấu món canh hầm hoặc món súp nóng bổ dưỡng phù hợp với khẩu vị thích đồ ấm của cô ấy.'
              : 'Cook a hearty warm stew, soup, or comfort bowl that satisfies her grounded appetite.',
          gentleContext: isVi
              ? 'Món ăn ấm nóng hỗ trợ tiêu hóa tốt và thỏa mãn vị giác của cô ấy.'
              : 'Warm, nutrient-dense foods satisfy elevated metabolic needs smoothly.',
          contextBasis: isVi ? 'Dinh dưỡng bổ sung' : 'Mid-luteal nutrition',
          category: RecommendationCategory.comfort,
          icon: Icons.restaurant_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day18_parallel',
          naturalThought: isVi
              ? 'Tận hưởng khoảng thời gian bên nhau trong yên bình, mỗi người một việc riêng nhưng vẫn cảm nhận sự ấm áp của người kia.'
              : 'Enjoy peaceful parallel downtime together—reading, drawing, or relaxing in each other\'s presence.',
          gentleContext: isVi
              ? 'Sự thấu hiểu không lời là biểu hiện cao nhất của sự hòa hợp lứa đôi.'
              : 'Comfortable companionable silence reflects deep emotional security.',
          contextBasis: isVi ? 'Đồng hành bình yên' : 'Companionable comfort',
          category: RecommendationCategory.connection,
          icon: Icons.self_improvement_outlined,
        ));
        break;

      case 19:
        list.add(CareRecommendation(
          id: 'care_day19_bedtime',
          naturalThought: isVi
              ? 'Giúp cô ấy chuẩn bị giường ngủ thơm tho, rót sẵn cốc nước ấm đầu giường để cô ấy có giấc ngủ thật ngon.'
              : 'Help set up a peaceful bedroom environment—fluffing pillows and placing fresh water on her nightstand.',
          gentleContext: isVi
              ? 'Chăm chút cho giấc ngủ của cô ấy là biểu hiện của tình yêu chu đáo.'
              : 'Thoughtful bedtime preparation supports restful restorative sleep.',
          contextBasis: isVi ? 'Chăm sóc giấc ngủ' : 'Restorative sleep support',
          category: RecommendationCategory.comfort,
          icon: Icons.bedtime_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day19_gratitude',
          naturalThought: isVi
              ? 'Chia sẻ với cô ấy 3 điều nhỏ bé bạn cảm kích nhất về cô ấy trong tuần qua.'
              : 'Share two or three specific little things you appreciated about her presence this week.',
          gentleContext: isVi
              ? 'Sự biết ơn chân thành củng cố niềm hạnh phúc và sự gắn kết gia đình.'
              : 'Specific appreciation builds deep emotional trust and warm fulfillment.',
          contextBasis: isVi ? 'Tri ân & gắn kết' : 'Gratitude sharing',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.volunteer_activism_outlined,
        ));
        break;

      case 20:
        list.add(CareRecommendation(
          id: 'care_day20_errands',
          naturalThought: isVi
              ? 'Chủ động hoàn thành các việc lặt vặt như đổ rác, phơi đồ sớm để buổi tối hoàn toàn thảnh thơi.'
              : 'Knock out household errands early so the evening remains completely open and restful for both of you.',
          gentleContext: isVi
              ? 'Giảm bớt gánh nặng việc nhà giúp cô ấy không phải bận tâm suy nghĩ.'
              : 'Clearing the to-do list prevents subtle premenstrual task overload.',
          contextBasis: isVi ? 'Giảm áp lực buổi tối' : 'Unburdening evening tasks',
          category: RecommendationCategory.practicalHelp,
          icon: Icons.cleaning_services_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day20_foot_rub',
          naturalThought: isVi
              ? 'Hỏi xem cô ấy có muốn bạn xoa bóp nhẹ lòng bàn chân hoặc bắp chân trước khi ngủ không.'
              : 'Ask gently if an unhurried foot or calf rub with lotion would feel relaxing before bed.',
          gentleContext: isVi
              ? 'Xoa bóp bàn chân giúp giải tỏa căng thẳng và cải thiện tuần hoàn máu.'
              : 'Foot massage encourages systemic parasympathetic relaxation and restful sleep.',
          contextBasis: isVi ? 'Thư giãn cơ thể' : 'Physical relaxation',
          category: RecommendationCategory.comfort,
          icon: Icons.spa_outlined,
        ));
        break;

      case 21:
        list.add(CareRecommendation(
          id: 'care_day21_dim_lights',
          naturalThought: isVi
              ? 'Giảm độ sáng màn hình tivi, chỉnh đèn phòng dịu mát và giữ không gian yên tĩnh vào buổi tối.'
              : 'Dim bright overhead lights early in the evening and keep media volume gentle to honor early luteal signals.',
          gentleContext: isVi
              ? 'Giảm kích thích ánh sáng giúp não bộ và hệ thần kinh cô ấy thư thái.'
              : 'Minimizing sensory stimuli allows her nervous system to settle gracefully.',
          contextBasis: isVi ? 'Chuyển tiếp hoàng thể muộn' : 'Late luteal threshold',
          category: RecommendationCategory.comfort,
          icon: Icons.nights_stay_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day21_herbal_tea',
          naturalThought: isVi
              ? 'Pha một ly trà thảo mộc không chứa caffeine như trà hoa cúc hoặc nước ấm mật ong dịu nhẹ.'
              : 'Brew a warm mug of caffeine-free rooibos, lavender, or honey-lemon water before bedtime.',
          gentleContext: isVi
              ? 'Đồ uống ấm áp giúp xoa dịu dạ dày và hỗ trợ cơ thể chuẩn bị nghỉ ngơi.'
              : 'Warm, soothing hydration keeps the digestive system calm as hormones begin fluctuating.',
          contextBasis: isVi ? 'Thảo mộc thư giãn' : 'Relaxing hydration',
          category: RecommendationCategory.comfort,
          icon: Icons.coffee_outlined,
        ));
        break;

      case 22:
        list.add(CareRecommendation(
          id: 'care_day22_treats',
          naturalThought: isVi
              ? 'Kín đáo mua sẵn món sô-cô-la đen, bánh ngọt hoặc món ăn vặt cô ấy thích và để trong bếp để cô ấy nhâm nhi.'
              : 'Quietly stock her favorite dark chocolate, pastry, or comfort snack in the pantry so it is there when cravings hit.',
          gentleContext: isVi
              ? 'Cơn thèm ăn trước kỳ kinh là sinh học tự nhiên; sự chu đáo kín đáo sẽ làm cô ấy rất vui.'
              : 'Premenstrual cravings are natural metabolic responses; having treats ready shows sweet thoughtfulness.',
          contextBasis: isVi ? 'Sở thích & khẩu vị' : 'Premenstrual cravings timing',
          category: RecommendationCategory.comfort,
          icon: Icons.cookie_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day22_hug',
          naturalThought: isVi
              ? 'Trao cho cô ấy một cái ôm ấm áp, dài lâu khi cô ấy đi làm về mà không cần vội hỏi dồn dập.'
              : 'Give her a long, comforting hug when she gets home without immediately demanding conversation.',
          gentleContext: isVi
              ? 'Cái ôm tiếp thêm sức mạnh tinh thần và sự chở che an tâm.'
              : 'Physical embrace releases oxytocin, reducing cortisol and providing reassurance.',
          contextBasis: isVi ? 'Vỗ về cảm xúc' : 'Emotional reassurance',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.favorite_outline,
        ));
        break;

      case 23:
        list.add(CareRecommendation(
          id: 'care_day23_light_dinner',
          naturalThought: isVi
              ? 'Nấu bữa tối thanh đạm, ít muối (canh củ quả, cá hấp) để giúp cơ thể cô ấy không bị nặng nề do giữ nước.'
              : 'Cook a light, low-sodium dinner (steamed fish, clear broth, fresh greens) to ease premenstrual fluid retention.',
          gentleContext: isVi
              ? 'Thức ăn ít muối giúp giảm tình trạng tích nước và sưng phù khó chịu.'
              : 'Lower sodium intake helps relieve water retention and heavy sensations naturally.',
          contextBasis: isVi ? 'Chăm sóc đầy hơi & giữ nước' : 'Fluid retention care',
          category: RecommendationCategory.comfort,
          icon: Icons.restaurant_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day23_tone',
          naturalThought: isVi
              ? 'Nói chuyện với giọng điệu nhẹ nhàng, ấm áp; tránh tranh luận những chuyện không cần thiết hôm nay.'
              : 'Speak with extra gentleness and patience; avoid starting stressful or non-urgent household debates today.',
          gentleContext: isVi
              ? 'Hệ thần kinh cô ấy đang nhạy cảm hơn; sự kiên nhẫn từ bạn là bến đỗ bình yên nhất.'
              : 'Hormonal fluctuations lower stress thresholds; gentle communication prevents friction.',
          contextBasis: isVi ? 'Giao tiếp kiên nhẫn' : 'Gentle communication',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.record_voice_over_outlined,
        ));
        break;

      case 24:
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
        break;

      case 25:
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
        break;

      case 26:
        list.add(CareRecommendation(
          id: 'care_day26_unburden',
          naturalThought: isVi
              ? 'Nhận hết các công việc nhà như dọn dẹp, rửa bát và giặt giũ tối nay để cô ấy được nghỉ ngơi thoải mái hoàn toàn.'
              : 'Quietly shoulder all dinner cleanup, dishes, and evening chores so she can rest completely guilt-free.',
          gentleContext: isVi
              ? 'Sự đỡ đần thiết thực là minh chứng rõ nhất cho tình yêu của bạn.'
              : 'Taking physical tasks off her hands provides tangible relief as premenstrual fatigue sets in.',
          contextBasis: isVi ? 'Giảm bớt áp lực trước kỳ kinh' : 'Premenstrual relief',
          category: RecommendationCategory.practicalHelp,
          icon: Icons.cleaning_services_outlined,
        ));
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
        break;

      case 27:
        list.add(CareRecommendation(
          id: 'care_day27_heat_ready',
          naturalThought: isVi
              ? 'Kiểm tra và để sẵn túi chườm ấm hoặc bình nước nóng ở vị trí dễ thấy để khi cần cô ấy có thể dùng ngay.'
              : 'Have the heating pad or hot water bottle clean and readily accessible in the bedroom.',
          gentleContext: isVi
              ? 'Sự chuẩn bị chu đáo trước giúp cô ấy luôn cảm thấy được bảo bọc.'
              : 'Proactive readiness communicates profound empathy before cramping strikes.',
          contextBasis: isVi ? 'Kỳ kinh có thể đến ngày mai' : 'Period expected in 24-48 hours',
          category: RecommendationCategory.preparation,
          icon: Icons.hot_tub_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day27_comfort_bed',
          naturalThought: isVi
              ? 'Chuẩn bị giường ngủ ấm cúng với gối êm, chăn ấm và nhắc cô ấy đi ngủ sớm để giữ sức.'
              : 'Fluff the pillows and prepare a warm, comforting bed to encourage an early, restorative night of sleep.',
          gentleContext: isVi
              ? 'Giấc ngủ ngon trước kỳ kinh giúp cơ thể có thêm sức đề kháng và giảm cảm giác đau.'
              : 'Ample sleep strengthens physical resilience right before menstruation begins.',
          contextBasis: isVi ? 'Nghỉ ngơi chuẩn bị chu kỳ' : 'Pre-period rest',
          category: RecommendationCategory.comfort,
          icon: Icons.bedtime_outlined,
        ));
        list.add(CareRecommendation(
          id: 'care_day27_reassurance',
          naturalThought: isVi
              ? 'Nói với cô ấy rằng bạn luôn ở đây bên cạnh, sẵn sàng làm bất cứ điều gì để cô ấy cảm thấy dễ chịu nhất.'
              : 'Reassure her with simple words: "I\'m right here if you need anything at all tonight."',
          gentleContext: isVi
              ? 'Lời khẳng định yêu thương mang lại cảm giác bình yên không gì sánh bằng.'
              : 'Quiet emotional certainty dissolves anxious pre-period vulnerability.',
          contextBasis: isVi ? 'Sự hiện diện yêu thương' : 'Reassuring presence',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.favorite,
        ));
        break;

      default:
        // Day 28+: Period Expected Today / Transition Threshold
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
        list.add(CareRecommendation(
          id: 'care_day28_patience',
          naturalThought: isVi
              ? 'Hôm nay hãy dành cho cô ấy sự kiên nhẫn tối đa, một không gian hoàn toàn không áp lực và cử chỉ chăm sóc nhẹ nhàng nhất.'
              : 'Treat today with extra patience, zero pressure, warm blankets, and affectionate quiet check-ins.',
          gentleContext: isVi
              ? 'Sự dịu dàng của bạn là liều thuốc xoa dịu ngọt ngào nhất khi chu kỳ chuẩn bị tái lập.'
              : 'Total patience and a low-demand atmosphere make the cycle reset smooth and comfortable.',
          contextBasis: isVi ? 'Ngày chu kỳ chuyển tiếp' : 'Cycle threshold day',
          category: RecommendationCategory.emotionalSupport,
          icon: Icons.favorite_outline,
        ));
        break;
    }
  }

  void _addEmptyStateSuggestions(
    List<CareRecommendation> list,
    CyclePhase phase,
    bool isVi,
  ) {
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

  int _computeEffectiveDay(CycleEstimate estimate, int day, CyclePhase phase) {
    if (phase == CyclePhase.menstrual) {
      return day.clamp(1, 5);
    }

    final daysUntil = estimate.daysUntilEstimatedPeriod;

    // Late luteal countdown
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

  List<CareRecommendation> _deduplicate(List<CareRecommendation> list) {
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
