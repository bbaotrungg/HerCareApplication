import '../domain/models/educational_tip.dart';

class CuratedTips {
  CuratedTips._();

  static const List<EducationalTip> allTips = [
    EducationalTip(
      id: 'tip_cycle_basics',
      title: 'The Menstrual Cycle is More Than Just the Period',
      titleVi: 'Chu kỳ kinh nguyệt bao gồm nhiều hơn chỉ những ngày hành kinh',
      summary: 'A monthly cycle involves four distinct physiological phases with shifting hormone levels.',
      summaryVi: 'Chu kỳ hàng tháng gồm bốn giai đoạn sinh lý rõ rệt với sự thay đổi của các hormone.',
      fullContent:
          'While the bleed (menstruation) is the most visible phase, a menstrual cycle spans four distinct phases: '
          'Menstrual (uterine lining sheds), Follicular (follicles develop, estrogen rises), '
          'Ovulation (egg release, brief mid-cycle window), and Luteal (progesterone rises then drops if no pregnancy occurs). '
          'Energy levels, metabolism, social appetite, and comfort naturally fluctuate across these phases. '
          'Understanding these rhythms allows partners to offer attentive, calibrated support.',
      fullContentVi:
          'Mặc dù giai đoạn hành kinh là dễ nhận biết nhất, một chu kỳ kinh nguyệt trải qua bốn giai đoạn sinh lý tự nhiên: '
          'Kinh nguyệt (niêm mạc tử cung bong ra), Nang trứng (các nang noãn phát triển, estrogen tăng dần), '
          'Rụng trứng (trứng rụng, khoảng thời gian ngắn giữa chu kỳ), và Hoàng thể (progesterone tăng rồi hạ nếu không thụ thai). '
          'Năng lượng, trao đổi chất, nhu cầu giao tiếp xã hội và sự thoải mái của cơ thể tự nhiên thay đổi qua từng giai đoạn này. '
          'Thấu hiểu nhịp điệu sinh học giúp người bạn đời chủ động đồng hành và chăm sóc tinh tế hơn.',
      category: TipCategory.cycleUnderstanding,
      actionablePoints: [
        'Notice that energy levels often rise post-period and drop in late luteal phase.',
        'Avoid treating cycle shifts as illnesses; they are healthy biological processes.',
        'Remember that each person experiences their cycle uniquely.',
      ],
      actionablePointsVi: [
        'Nhận biết mức năng lượng thường tăng sau kỳ kinh và giảm ở cuối giai đoạn hoàng thể.',
        'Tránh coi những thay đổi trong chu kỳ là bệnh lý; đó là quá trình sinh học tự nhiên và khỏe mạnh.',
        'Luôn nhớ rằng cơ thể mỗi người phụ nữ đều có trải nghiệm chu kỳ rất riêng biệt.',
      ],
    ),
    EducationalTip(
      id: 'tip_natural_variability',
      title: 'Why 28-Day Cycles Are a Textbook Average, Not a Rule',
      titleVi: 'Tại sao chu kỳ 28 ngày chỉ là con số trung bình trong sách giáo khoa',
      summary: 'Normal, healthy cycles can range from 21 to 38 days, and vary month-to-month.',
      summaryVi: 'Một chu kỳ bình thường và khỏe mạnh có thể dao động từ 21 đến 38 ngày và thay đổi theo từng tháng.',
      fullContent:
          'Pop culture often repeats that menstrual cycles are strictly 28 days long. In reality, medical research shows '
          'that healthy adult cycles normally range between 21 and 38 days, and can vary by several days between months. '
          'Illness, travel, stress, sleep disruption, and exercise can shift ovulation timing. '
          'This is why cycle tracking apps offer estimates rather than exact mathematical certainty.',
      fullContentVi:
          'Nhiều người thường mặc định rằng chu kỳ kinh nguyệt luôn chuẩn xác 28 ngày. Trên thực tế, nghiên cứu y khoa chỉ ra '
          'chu kỳ của phụ nữ trưởng thành khỏe mạnh thường dao động trong khoảng từ 21 đến 38 ngày và có thể chênh lệch vài ngày giữa các tháng. '
          'Cảm cúm, đi xa, căng thẳng, mất ngủ hoặc vận động nặng đều có thể thay đổi thời điểm rụng trứng. '
          'Đó là lý do mọi ứng dụng theo dõi chu kỳ chỉ đưa ra con số ước tính chứ không thể đảm bảo sự chuẩn xác tuyệt đối.',
      category: TipCategory.predictionUncertainty,
      actionablePoints: [
        'Do not worry or react with alarm if her period begins a few days early or late.',
        'Never treat cycle estimates as contraception or fertility guarantees.',
        'Recognize that apps predict probabilities, not calendar absolutes.',
      ],
      actionablePointsVi: [
        'Đừng quá lo lắng hay phản ứng hốt hoảng nếu kỳ kinh của cô ấy đến sớm hay muộn vài ngày.',
        'Tuyệt đối không sử dụng các ước tính chu kỳ để tránh thai hoặc bảo đảm thụ thai.',
        'Hiểu rằng ứng dụng chỉ dự báo xác suất sinh học chứ không phải lịch ấn định.',
      ],
    ),
    EducationalTip(
      id: 'tip_heat_therapy',
      title: 'The Calming Power of Heat Therapy for Cramps',
      titleVi: 'Liệu pháp chườm ấm: Cách xoa dịu cơn đau bụng kinh hiệu quả',
      summary: 'Heat relaxes smooth muscle tissue and brings genuine relief to abdominal tension.',
      summaryVi: 'Nhiệt độ ấm giúp thư giãn các cơ trơn tử cung và mang lại cảm giác dễ chịu rõ rệt.',
      fullContent:
          'Menstrual cramps (dysmenorrhea) are caused by prostaglandin hormones prompting uterine contractions to shed lining. '
          'Applying gentle topical heat—such as a hot water bottle, warm compress, or heating pad—causes vasodilation, '
          'increasing local blood flow and directly relaxing tight smooth muscle tissues. '
          'Studies show heat therapy can be as effective as mild over-the-counter pain relief for abdominal discomfort.',
      fullContentVi:
          'Đau bụng kinh (thống kinh) xuất phát từ hormone prostaglandin kích thích cơ tử cung co thắt để đào thải niêm mạc. '
          'Việc chườm ấm nhẹ nhàng vùng bụng dưới—bằng túi chườm nước nóng, miếng dán giữ nhiệt hoặc đệm sưởi—giúp giãn mạch máu, '
          'tăng lưu lượng máu cục bộ và trực tiếp thả lỏng các mô cơ trơn đang co rút. '
          'Nhiều nghiên cứu y học cho thấy chườm ấm có hiệu quả giảm đau tương đương với một số loại thuốc giảm đau nhẹ không kê đơn.',
      category: TipCategory.physicalComfort,
      actionablePoints: [
        'Offer a heated blanket, heating pad, or warm water bottle proactively.',
        'Ensure the temperature is warm and soothing without risking skin burns.',
        'Combine heat therapy with gentle lumbar pillow support.',
      ],
      actionablePointsVi: [
        'Chủ động chuẩn bị túi chườm ấm, đệm nhiệt hoặc bình nước nóng khi cô ấy thấy đau.',
        'Đảm bảo nhiệt độ vừa phải, dễ chịu, tránh quá nóng gây bỏng rát da.',
        'Kết hợp chườm ấm với một chiếc gối tựa êm ái cho vùng lưng dưới.',
      ],
    ),
    EducationalTip(
      id: 'tip_active_listening',
      title: 'Holding Space: Listening vs. Solving',
      titleVi: 'Lắng nghe chân thành: Hiện diện thay vì vội vã tìm giải pháp',
      summary: 'Often, the greatest emotional gift is listening patiently without rushing to fix.',
      summaryVi: 'Món quà tinh thần lớn nhất đôi khi chỉ là kiên nhẫn lắng nghe mà không vội vàng phán xét hay sửa chữa.',
      fullContent:
          'When your partner shares feelings of fatigue, emotional sensitivity, or frustration, an intuitive reflex '
          'for many partners is to immediately propose logical fixes. While well-intentioned, this can feel invalidating. '
          'More often, what is truly needed is emotional safety: feeling heard, respected, and comforted without judgment. '
          'A simple question like "Would you like me to listen, give advice, or just hold you?" works wonders.',
      fullContentVi:
          'Khi bạn gái hoặc vợ chia sẻ về cảm giác mệt mỏi, nhạy cảm hay căng thẳng, phản xạ tự nhiên của nhiều nam giới '
          'là lập tức đưa ra lời khuyên logic để giải quyết vấn đề. Dù xuất phát từ ý tốt, điều này đôi khi khiến cô ấy cảm thấy cảm xúc của mình không được thấu cảm. '
          'Trong hầu hết trường hợp, điều cô ấy cần là một không gian an toàn: được lắng nghe, được trân trọng và vỗ về mà không bị phán xét. '
          'Một câu hỏi đơn giản như "Em muốn anh lắng nghe, cho lời khuyên, hay chỉ cần một cái ôm?" sẽ mang lại sự ấm áp rất lớn.',
      category: TipCategory.emotionalSupport,
      actionablePoints: [
        'Ask: "Do you want comfort, solutions, or space?"',
        'Validate her feelings instead of debating their root cause.',
        'Never dismiss her experiences by attributing everything to hormones.',
      ],
      actionablePointsVi: [
        'Hỏi một cách chân thành: "Em muốn anh lắng nghe chia sẻ, tìm giải pháp, hay để em nghỉ ngơi yên tĩnh?"',
        'Thừa nhận và đồng cảm với cảm xúc của cô ấy thay vì tranh luận về nguyên nhân.',
        'Không bao giờ gạt phăng cảm xúc của cô ấy bằng cách quy chụp mọi thứ cho nội tiết tố.',
      ],
    ),
    EducationalTip(
      id: 'tip_respectful_language',
      title: 'Respectful Language & Avoiding Harmful Tropes',
      titleVi: 'Ngôn từ tôn trọng & Tránh những định kiến vô tâm',
      summary: 'Never dismiss her thoughts, boundaries, or emotions with "Is it that time of the month?"',
      summaryVi: 'Tuyệt đối không coi nhẹ suy nghĩ, ranh giới hay cảm xúc của cô ấy bằng câu nói "Lại đến ngày rồi à?".',
      fullContent:
          'Reducing a woman’s legitimate boundaries, anger, sadness, or fatigue to "hormones" or "PMS" can feel deeply '
          'dismissive and disrespectful. While hormonal fluctuations certainly affect physical and mental stamina, '
          'her feelings, thoughts, and opinions remain fully valid. Treat her with dignity, honor her communication, '
          'and never use cycle tracking to undermine her voice or autonomy.',
      fullContentVi:
          'Việc quy chụp những ranh giới chính đáng, sự giận dữ, nỗi buồn hay sự mệt mỏi của người phụ nữ thành "do đến tháng" hay "PMS" '
          'là hành vi thiếu tinh tế và dễ làm tổn thương. Dù sự biến động hormone ảnh hưởng đến thể lực và tâm trạng, '
          'mọi suy nghĩ, quan điểm và cảm xúc của cô ấy vẫn hoàn toàn có giá trị. Hãy đối xử với cô ấy bằng sự tôn trọng, '
          'lắng nghe nghiêm túc và không bao giờ dùng việc theo dõi chu kỳ để xem nhẹ tiếng nói của cô ấy.',
      category: TipCategory.respectfulCommunication,
      actionablePoints: [
        'Never weaponize cycle phases during disagreements or discussions.',
        'Respect her privacy: record only details she has voluntarily chosen to share.',
        'Acknowledge her emotional experiences as genuine and real.',
      ],
      actionablePointsVi: [
        'Không bao giờ lấy chu kỳ kinh nguyệt làm lý do công kích trong các cuộc tranh luận.',
        'Tôn trọng quyền riêng tư: chỉ ghi nhận những điều cô ấy tự nguyện chia sẻ.',
        'Luôn công nhận và trân trọng cảm xúc của cô ấy như những trải nghiệm chân thực.',
      ],
    ),
    EducationalTip(
      id: 'tip_supply_stocking',
      title: 'Building a Thoughtful Care Kit at Home and On-the-Go',
      titleVi: 'Chuẩn bị chu đáo bộ đồ dùng chăm sóc tại nhà và khi ra ngoài',
      summary: 'Anticipate practical essentials so she never faces an unexpected shortage.',
      summaryVi: 'Chủ động chuẩn bị trước những vật dụng thiết yếu để cô ấy không rơi vào thế bị động.',
      fullContent:
          'Knowing which specific pads, tampons, or menstrual cups she prefers—and having them readily stocked in '
          'your shared bathroom, car glove compartment, or travel bag—is one of the most practical and appreciated gestures '
          'a partner can make. Take note of brand preferences, absorbency levels, and whether she prefers unscented items.',
      fullContentVi:
          'Biết rõ loại băng vệ sinh, tampon hay cốc nguyệt san cô ấy quen dùng—và luôn có sẵn dự phòng trong '
          'tủ phòng tắm chung, ngăn để đồ trên xe ô tô hoặc túi du lịch—là một trong những hành động chu đáo và thiết thực nhất mà một người bạn đời có thể làm. '
          'Hãy để ý thương hiệu yêu thích, độ dày/mỏng, loại có cánh hay không cánh, và việc cô ấy thích loại không mùi để chuẩn bị chính xác.',
      category: TipCategory.practicalEssentials,
      actionablePoints: [
        'Save her preferred brands and absorbencies in the Notes section.',
        'Check the cabinet 2-3 days before the estimated period window.',
        'Keep spare supplies and pain-relief options discretely available in travel kits.',
      ],
      actionablePointsVi: [
        'Lưu lại loại và nhãn hiệu cô ấy tin dùng vào mục Ghi chú của HerCare.',
        'Kiểm tra tủ đồ dùng khoảng 2-3 ngày trước khoảng chu kỳ dự kiến.',
        'Giữ sẵn một túi dự phòng kín đáo kèm trà ấm hoặc đồ dùng cá nhân trong balo/xe.',
      ],
    ),
    EducationalTip(
      id: 'tip_medical_boundaries',
      title: 'When to Encourage Professional Medical Advice',
      titleVi: 'Khi nào cần khuyến khích cô ấy thăm khám bác sĩ',
      summary: 'HerCare is a companion tool, not a diagnostic or healthcare provider.',
      summaryVi: 'HerCare là người bạn đồng hành chu đáo, không thay thế cho chẩn đoán y khoa chuyên nghiệp.',
      fullContent:
          'While common symptoms like mild cramping, bloating, and fatigue are ordinary aspects of menstrual cycles, '
          'severe, debilitating pelvic pain, excessive bleeding, sudden fainting, or chronic severe depression (PMDD) '
          'are not things to simply "tough out". If she expresses feeling unusually severe pain or concern, '
          'calmly and gently encourage her to discuss her symptoms with a qualified physician or gynecologist.',
      fullContentVi:
          'Trong khi đau bụng nhẹ, đầy hơi và mệt mỏi là những biểu hiện tự nhiên của chu kỳ, những cơn đau quằn quại dữ dội, '
          'chảy máu kéo dài bất thường, chóng mặt ngất xỉu hoặc trầm cảm nghiêm trọng (PMDD) không phải là điều cô ấy phải cắn răng chịu đựng một mình. '
          'Nếu cô ấy chia sẻ những cơn đau dữ dội bất thường, hãy nhẹ nhàng, ân cần động viên cô ấy đi khám tại các cơ sở y tế hoặc bác sĩ phụ khoa uy tín.',
      category: TipCategory.physicalComfort,
      actionablePoints: [
        'Do not attempt to medically diagnose PMS, PMDD, or gynecological conditions.',
        'Support her in booking an appointment or attending a clinic visit if she desires.',
        'Offer unconditional emotional comfort while seeking proper medical care.',
      ],
      actionablePointsVi: [
        'Không tự ý chẩn đoán y tế về PMS, PMDD hay các bệnh lý phụ khoa.',
        'Hỗ trợ cô ấy đặt lịch hẹn khám hoặc đi cùng cô ấy nếu cô ấy mong muốn.',
        'Trao cho cô ấy sự an tâm và tình yêu thương vô điều kiện trong suốt quá trình chăm sóc sức khỏe.',
      ],
    ),
  ];
}
