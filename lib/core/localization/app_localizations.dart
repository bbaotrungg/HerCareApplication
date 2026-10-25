import 'app_language.dart';

/// Comprehensive localization container for HerCare.
///
/// Provides natural, human-centered English and Vietnamese translations for
/// navigation, buttons, labels, notifications, settings, cycle phases, and care suggestions.
class AppLocalizations {
  final AppLanguage language;

  const AppLocalizations(this.language);

  bool get isVietnamese => language == AppLanguage.vi;

  static AppLocalizations ofLanguage(AppLanguage language) {
    return AppLocalizations(language);
  }

  // --- Brand & General ---
  String get appTitle => 'HerCare';
  String get appTagline => isVietnamese
      ? 'Bạn đồng hành chăm sóc chu kỳ kinh nguyệt chu đáo cho phái mạnh'
      : 'A Thoughtful Menstrual Care Companion for Partners';
  String get offlinePrivateBadge =>
      isVietnamese ? '100% Ngoại tuyến & Riêng tư' : '100% Offline & Private';

  // --- Navigation ---
  String get navDashboard => isVietnamese ? 'Trang chủ' : 'Dashboard';
  String get navCalendar => isVietnamese ? 'Lịch' : 'Calendar';
  String get navCare => isVietnamese ? 'Chăm sóc' : 'Care';
  String get navNotes => isVietnamese ? 'Ghi chú' : 'Notes';
  String get tooltipReminders => isVietnamese ? 'Lời nhắc chăm sóc' : 'Care Reminders';
  String get tooltipSettings => isVietnamese ? 'Cài đặt & Quyền riêng tư' : 'Settings & Privacy';

  // --- Greetings ---
  String greetingMorning(String partnerName) {
    if (partnerName.trim().isNotEmpty) {
      return isVietnamese
          ? 'Chào buổi sáng, đang chăm sóc cho ${partnerName.trim()}'
          : 'Good morning, caring for ${partnerName.trim()}';
    }
    return isVietnamese ? 'Chào buổi sáng, người thương' : 'Good morning, partner';
  }

  String greetingAfternoon(String partnerName) {
    if (partnerName.trim().isNotEmpty) {
      return isVietnamese
          ? 'Chào buổi chiều, đang chăm sóc cho ${partnerName.trim()}'
          : 'Good afternoon, caring for ${partnerName.trim()}';
    }
    return isVietnamese ? 'Chào buổi chiều, người thương' : 'Good afternoon, partner';
  }

  String greetingEvening(String partnerName) {
    if (partnerName.trim().isNotEmpty) {
      return isVietnamese
          ? 'Chào buổi tối, đang chăm sóc cho ${partnerName.trim()}'
          : 'Good evening, caring for ${partnerName.trim()}';
    }
    return isVietnamese ? 'Chào buổi tối, người thương' : 'Good evening, partner';
  }

  // --- Cycle Phase Names (The 4 core menstrual phases) ---
  String get phaseMenstrualName => isVietnamese ? 'Giai đoạn kinh nguyệt' : 'Menstrual Phase';
  String get phaseFollicularName => isVietnamese ? 'Giai đoạn nang trứng' : 'Follicular Phase';
  String get phaseOvulationName => isVietnamese ? 'Giai đoạn rụng trứng' : 'Ovulation Phase';
  String get phaseLutealName => isVietnamese ? 'Giai đoạn hoàng thể' : 'Luteal Phase';
  String get phaseUncertainName => isVietnamese ? 'Chưa xác định / Chờ dữ liệu' : 'Awaiting Data';

  // --- Cycle Phase Descriptions ---
  String get phaseMenstrualDesc => isVietnamese
      ? 'Trong kỳ kinh nguyệt, niêm mạc tử cung bong ra. Các biểu hiện thường gặp bao gồm đau bụng kinh, mệt mỏi hoặc giảm thể lực.'
      : 'During menstruation, the uterine lining sheds. Common experiences can include cramps, fatigue, or lower stamina, though every person feels differently.';

  String get phaseFollicularDesc => isVietnamese
      ? 'Nồng độ estrogen tăng dần. Mức năng lượng, sự tập trung và sự thoải mái tổng thể thường cải thiện trong giai đoạn này.'
      : 'Estrogen levels gradually rise. Energy, focus, and overall physical comfort often increase during this phase.';

  String get phaseOvulationDesc => isVietnamese
      ? 'Giai đoạn giữa chu kỳ. Sức sống và tinh thần thường đạt mức cao nhất. Lưu ý: Đây chỉ là ước tính, không dùng để tránh thai hay thụ thai.'
      : 'Estimated mid-cycle transition. Vitality and sociability often peak. Note: This is strictly an estimate, not a fertility indicator.';

  String get phaseLutealDesc => isVietnamese
      ? 'Progesterone tăng rồi giảm nếu không thụ thai. Nhu cầu nghỉ ngơi, sự nhạy cảm của cơ thể hoặc cảm xúc có thể rõ rệt hơn.'
      : 'Progesterone rises then drops if no pregnancy occurs. Rest needs, body sensitivity, or emotional shifts may become more pronounced.';

  String get phaseUncertainDesc => isVietnamese
      ? 'Cần thêm dữ liệu chu kỳ để đưa ra ước tính đáng tin cậy. Chu kỳ kinh nguyệt thay đổi tự nhiên theo từng tháng.'
      : 'More cycle history is needed to provide a reliable phase estimate. Cycles naturally vary from month to month.';

  // --- Cycle Day & Timing ---
  String cycleDay(int day) => isVietnamese ? 'Ngày $day của chu kỳ' : 'Day $day of current cycle';
  String cycleDayBadge(int day) => isVietnamese ? 'Ngày chu kỳ: $day' : 'Cycle Day: $day';
  String get awaitingFirstPeriod =>
      isVietnamese ? 'Đang chờ ngày đầu kỳ kinh' : 'Awaiting first period date';
  String periodStartsToday() => isVietnamese
      ? 'Khoảng chu kỳ dự kiến bắt đầu khoảng hôm nay'
      : 'Estimated cycle window begins around today';
  String periodInDays(int days) => isVietnamese
      ? 'Kỳ kinh dự kiến tiếp theo sau ~$days ngày'
      : 'Next estimated period in ~$days days';
  String periodOverdue(int days) => isVietnamese
      ? 'Khoảng dự kiến cách đây ~$days ngày (chu kỳ thay đổi tự nhiên)'
      : 'Estimated window was ~$days days ago (cycles vary naturally)';

  // --- Reliability Badges ---
  String get badgeBaseline => isVietnamese ? 'Chu kỳ mẫu (28 ngày)' : 'General Baseline';
  String get badgePreliminary => isVietnamese ? 'Ước tính sơ bộ (1 chu kỳ)' : 'Preliminary Estimate';
  String get badgeInformed => isVietnamese ? 'Theo dõi chu kỳ' : 'Cycle-Informed';
  String get badgeVariable => isVietnamese ? 'Chu kỳ dao động' : 'Variable Cycle';
  String get badgeAwaiting => isVietnamese ? 'Chờ dữ liệu' : 'Awaiting Data';

  // --- Estimation Disclaimers ---
  String get estimateNoticeHeadline =>
      isVietnamese ? 'Ước tính theo chu kỳ' : 'Estimated Phase';
  String get estimateNoticeDescription => isVietnamese
      ? 'Dự đoán giai đoạn là ước tính dựa trên dữ liệu chu kỳ hiện có và sinh học tự nhiên. Cơ thể mỗi người luôn có sự thay đổi khác nhau.'
      : 'Cycle phase predictions are estimates based on available cycle information and natural biology. Individual bodies vary.';
  String get estimateNoticeEmptyState => isVietnamese
      ? 'Hãy bắt đầu bằng việc ghi nhận ngày đầu tiên của kỳ kinh gần nhất. HerCare sẽ tự động ước tính giai đoạn chu kỳ và các trải nghiệm có thể xuất hiện.'
      : 'Start by recording the first day of her most recent period. HerCare will then automatically estimate her cycle phase and possible experiences.';

  // --- Possible Symptoms & Mood Section ---
  String get symptomsSectionTitle => isVietnamese
      ? 'Triệu chứng & Tâm trạng có thể xuất hiện hôm nay'
      : 'Possible Symptoms & Mood Today';
  String get physicalSensationsHeading =>
      isVietnamese ? 'Cảm giác cơ thể' : 'Physical Sensations';
  String get emotionalStateHeading =>
      isVietnamese ? 'Tâm trạng & Năng lượng' : 'Emotional State & Energy';
  String get symptomsTransparentNotice => isVietnamese
      ? 'Các khả năng này được ước tính theo thời điểm chu kỳ, không phải sự thật đã xác nhận. Cảm nhận thực tế của cô ấy có thể hoàn toàn khác.'
      : 'These possibilities are estimated from cycle timing, not confirmed facts. Her actual experience may be completely different.';

  // --- Confidence Badges ---
  String get confidenceCommon =>
      isVietnamese ? 'Thường gặp trong giai đoạn này' : 'Common during this phase';
  String get confidencePossible =>
      isVietnamese ? 'Có thể xuất hiện hôm nay' : 'Possible today';
  String get confidenceBaseline =>
      isVietnamese ? 'Khả năng theo chu kỳ mẫu' : 'Baseline possibility';

  // --- Care Suggestions Section ---
  String get careSectionTitle =>
      isVietnamese ? 'Gợi ý chăm sóc hôm nay' : 'Today\'s Care Suggestions';
  String get careExploreMore => isVietnamese ? 'Xem thêm' : 'Explore More';
  String get careEmptyMessage => isVietnamese
      ? 'Hãy quay lại sau khi ghi nhận kỳ kinh để nhận gợi ý chăm sóc chu đáo.'
      : 'Check back once period history is recorded for caring ideas.';
  String get careSaveToNotes => isVietnamese ? 'Lưu vào ghi chú' : 'Save to Notes';
  String get careSavedToNotes => isVietnamese ? 'Đã lưu vào ghi chú' : 'Saved to Notes';

  // --- Quick Cycle Input Bar ---
  String get quickActionsTitle => isVietnamese ? 'Ghi nhận nhanh chu kỳ' : 'Quick Cycle Input';
  String get btnRecordPeriodStart =>
      isVietnamese ? 'Ghi nhận ngày đầu kỳ kinh' : 'Record Period Start';
  String get btnNote => isVietnamese ? 'Ghi chú' : 'Note';
  String get btnOptionalManualLog =>
      isVietnamese ? 'Ghi nhận tùy chọn' : 'Optional manual log';

  // --- Settings Screen ---
  String get settingsTitle => isVietnamese ? 'Cài đặt & Quyền riêng tư' : 'Settings & Privacy';
  String get settingsLanguageSection => isVietnamese ? 'Cài đặt ngôn ngữ' : 'Language Settings';
  String get settingsLanguageSubtitle =>
      isVietnamese ? 'Chọn ngôn ngữ hiển thị cho ứng dụng' : 'Choose application language';
  String get settingsLangEnglish => 'English';
  String get settingsLangEnglishSub =>
      isVietnamese ? 'Ngôn ngữ mặc định' : 'Default application language';
  String get settingsLangVietnamese => 'Tiếng Việt';
  String get settingsLangVietnameseSub =>
      isVietnamese ? 'Giao diện và gợi ý bằng tiếng Việt' : 'Vietnamese interface & suggestions';

  String get settingsThemeSection => isVietnamese ? 'Giao diện & Hiển thị' : 'Theme & Appearance';
  String get themeSystem => isVietnamese ? 'Theo hệ thống' : 'System Default';
  String get themeSystemSub =>
      isVietnamese ? 'Phù hợp với cài đặt thiết bị của bạn' : 'Matches your Android device settings';
  String get themeLight => isVietnamese ? 'Chế độ sáng' : 'Light Mode';
  String get themeLightSub =>
      isVietnamese ? 'Tông màu ngà ấm áp & hoa oải hương' : 'Warm ivory & lavender tones';
  String get themeDark => isVietnamese ? 'Chế độ tối' : 'Dark Mode';
  String get themeDarkSub =>
      isVietnamese ? 'Bảng màu tối nhẹ dịu, độ tương phản vừa phải' : 'Gentle, low-contrast dark palette';

  String get settingsPartnerSection => isVietnamese ? 'Cá nhân hóa' : 'Partner Personalization';
  String get partnerNameLabel =>
      isVietnamese ? 'Tên hoặc biệt danh của cô ấy' : 'Her Name or Nickname';
  String get partnerNameHint =>
      isVietnamese ? 'Ví dụ: Lan, Mai, Em yêu' : 'e.g. Sarah, Emma, Sweetheart';

  String get settingsPrivacySection => isVietnamese ? 'Quyền riêng tư & Đạo đức' : 'Privacy & Ethics';
  String get privacyNoticeTile =>
      isVietnamese ? 'Thông báo Quyền riêng tư, Đồng thuận & An toàn' : 'Privacy, Consent & Safety Notice';
  String get privacyNoticeSub => isVietnamese
      ? 'Lưu trữ cục bộ, chia sẻ tự nguyện, không chẩn đoán y tế'
      : 'Local storage, voluntary sharing, no medical claims';
  String get exportDataTile => isVietnamese ? 'Xuất dữ liệu cục bộ' : 'Export Local Data';
  String get exportDataSub => isVietnamese
      ? 'Lưu hoặc kiểm tra dữ liệu SQLite dưới dạng JSON'
      : 'Save or inspect your SQLite records as JSON';

  String get settingsDataSection => isVietnamese ? 'Quản lý dữ liệu' : 'Data Management';
  String get clearDataTile =>
      isVietnamese ? 'Xóa toàn bộ dữ liệu ứng dụng' : 'Clear All Application Data';
  String get clearDataSub => isVietnamese
      ? 'Xóa tất cả các ngày chu kỳ, triệu chứng và ghi chú'
      : 'Erase all cycle dates, symptoms, and notes';

  // --- Common Dialog Actions ---
  String get actionCancel => isVietnamese ? 'Hủy' : 'Cancel';
  String get actionSave => isVietnamese ? 'Lưu' : 'Save';
  String get actionDelete => isVietnamese ? 'Xóa' : 'Delete';
  String get actionConfirm => isVietnamese ? 'Xác nhận' : 'Confirm';
  String get actionClose => isVietnamese ? 'Đóng' : 'Close';

  // --- Calendar Screen ---
  String get calendarConfirmedPeriod =>
      isVietnamese ? 'Kỳ kinh đã ghi nhận' : 'Confirmed Period';
  String get calendarEstimatedWindow =>
      isVietnamese ? 'Khoảng dự kiến' : 'Estimated Window';
  String get calendarToday => isVietnamese ? 'Hôm nay' : 'Today';
  String get calendarNotes => isVietnamese ? 'Ghi chú' : 'Notes';
  String get calendarNoRecords =>
      isVietnamese ? 'Không có bản ghi nào cho ngày này' : 'No records for this day';

  // --- Care Screen Tabs ---
  String get tabCareSuggestions =>
      isVietnamese ? 'Gợi ý chăm sóc' : 'Care Suggestions';
  String get tabEducationalLibrary =>
      isVietnamese ? 'Cẩm nang kiến thức' : 'Educational Library';
  String get topicAll => isVietnamese ? 'Tất cả' : 'All Topics';
  String get topicUnderstanding =>
      isVietnamese ? 'Hiểu về chu kỳ' : 'Understanding the Cycle';
  String get topicComfort =>
      isVietnamese ? 'Giảm đau & Tạo thoải mái' : 'Comfort & Pain Relief';
  String get topicCommunication =>
      isVietnamese ? 'Giao tiếp & Thấu cảm' : 'Communication & Emotional Support';

  // --- Notes Screen Tabs ---
  String get tabPreferences => isVietnamese ? 'Sở thích' : 'Preferences';
  String get tabPersonalNotes => isVietnamese ? 'Ghi chú cá nhân' : 'Personal Notes';
  String get btnAddPreference => isVietnamese ? 'Thêm sở thích' : 'Add Preference';
  String get btnAddNote => isVietnamese ? 'Thêm ghi chú' : 'Add Note';

  // --- Reminders Screen ---
  String get remindersTitle => isVietnamese ? 'Lời nhắc chăm sóc' : 'Care Reminders';
  String get btnAddReminder => isVietnamese ? 'Thêm lời nhắc' : 'Add Care Reminder';

  // --- Onboarding Screen ---
  String get onboardingWelcomeTitle =>
      isVietnamese ? 'Chào mừng đến với HerCare' : 'Welcome to HerCare';
  String get onboardingWelcomeDesc => isVietnamese
      ? 'Bạn đồng hành chăm sóc chu kỳ kinh nguyệt chu đáo dành cho phái mạnh, giúp bạn thấu hiểu, đồng hành và quan tâm người thương.'
      : 'A thoughtful menstrual care companion designed for partners who want to understand, support, and care for their loved one.';
  String get onboardingPrinciplesTitle =>
      isVietnamese ? 'Nguyên tắc cốt lõi' : 'Core Principles';
  String get onboardingSetupTitle =>
      isVietnamese ? 'Dấu ấn cá nhân' : 'Personal Touch';
  String get btnNext => isVietnamese ? 'Tiếp tục' : 'Next';
  String get btnGetStarted => isVietnamese ? 'Bắt đầu' : 'Get Started';
}

