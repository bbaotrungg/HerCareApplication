import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_language.dart';

enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
  uncertain;

  String localizedName(AppLanguage language) {
    if (language == AppLanguage.vi) {
      switch (this) {
        case CyclePhase.menstrual:
          return 'Giai đoạn kinh nguyệt';
        case CyclePhase.follicular:
          return 'Giai đoạn nang trứng';
        case CyclePhase.ovulatory:
          return 'Giai đoạn rụng trứng';
        case CyclePhase.luteal:
          return 'Giai đoạn hoàng thể';
        case CyclePhase.uncertain:
          return 'Chờ dữ liệu';
      }
    }
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulatory:
        return 'Ovulation Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
      case CyclePhase.uncertain:
        return 'Awaiting Data';
    }
  }

  String get displayName => localizedName(AppLanguage.en);

  String get shortName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulatory:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
      case CyclePhase.uncertain:
        return 'Observing';
    }
  }

  String localizedExplanation(AppLanguage language) {
    if (language == AppLanguage.vi) {
      switch (this) {
        case CyclePhase.menstrual:
          return 'Trong kỳ kinh nguyệt, niêm mạc tử cung bong ra. Các biểu hiện thường gặp bao gồm đau tức bụng dưới, mệt mỏi hoặc giảm thể lực.';
        case CyclePhase.follicular:
          return 'Nồng độ estrogen tăng dần. Mức năng lượng, sự tập trung và sự thoải mái tổng thể thường cải thiện trong giai đoạn này.';
        case CyclePhase.ovulatory:
          return 'Giai đoạn giữa chu kỳ. Sức sống và tinh thần thường đạt mức cao nhất. Lưu ý: Đây chỉ là ước tính, không dùng để tránh thai hay thụ thai.';
        case CyclePhase.luteal:
          return 'Progesterone tăng rồi giảm nếu không thụ thai. Nhu cầu nghỉ ngơi, sự nhạy cảm của cơ thể hoặc cảm xúc có thể rõ rệt hơn.';
        case CyclePhase.uncertain:
          return 'Cần thêm dữ liệu chu kỳ để đưa ra ước tính đáng tin cậy. Chu kỳ kinh nguyệt thay đổi tự nhiên theo từng tháng.';
      }
    }
    switch (this) {
      case CyclePhase.menstrual:
        return 'During menstruation, uterine lining sheds. Common experiences can include cramps, fatigue, or low stamina, though every person feels differently.';
      case CyclePhase.follicular:
        return 'Estrogen levels gradually rise. Energy, focus, and overall physical comfort often increase during this phase.';
      case CyclePhase.ovulatory:
        return 'Estimated mid-cycle transition. Vitality and sociability often peak, though physical sensations can vary. Note: This is strictly an estimate, not a fertility indicator.';
      case CyclePhase.luteal:
        return 'Progesterone rises then drops if no pregnancy occurs. Rest needs, body sensitivity, or emotional shifts may become more pronounced.';
      case CyclePhase.uncertain:
        return 'More cycle history is needed to provide a reliable phase estimate. Cycles naturally vary from month to month.';
    }
  }

  String get gentleExplanation => localizedExplanation(AppLanguage.en);

  Color get color {
    switch (this) {
      case CyclePhase.menstrual:
        return AppColors.menstrual;
      case CyclePhase.follicular:
        return AppColors.follicular;
      case CyclePhase.ovulatory:
        return AppColors.ovulatory;
      case CyclePhase.luteal:
        return AppColors.luteal;
      case CyclePhase.uncertain:
        return AppColors.uncertain;
    }
  }

  IconData get icon {
    switch (this) {
      case CyclePhase.menstrual:
        return Icons.water_drop_outlined;
      case CyclePhase.follicular:
        return Icons.spa_outlined;
      case CyclePhase.ovulatory:
        return Icons.wb_sunny_outlined;
      case CyclePhase.luteal:
        return Icons.bedtime_outlined;
      case CyclePhase.uncertain:
        return Icons.help_outline;
    }
  }
}
