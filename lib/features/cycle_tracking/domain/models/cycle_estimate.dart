import 'package:flutter/foundation.dart';
import '../../../../core/localization/app_language.dart';
import 'cycle_phase.dart';

enum EstimateReliability {
  insufficient,
  limitedInformation,
  preliminary,
  cycleInformed,
  variableCycle;

  String get label {
    switch (this) {
      case EstimateReliability.insufficient:
        return 'No History Yet';
      case EstimateReliability.limitedInformation:
        return 'Limited Information (General Baseline)';
      case EstimateReliability.preliminary:
        return 'General Estimate (1 Observed Cycle)';
      case EstimateReliability.cycleInformed:
        return 'Cycle-Informed Estimate';
      case EstimateReliability.variableCycle:
        return 'Variable Cycle Pattern';
    }
  }

  String get badgeLabel => localizedBadgeLabel(AppLanguage.en);

  String localizedBadgeLabel(AppLanguage language) {
    if (language == AppLanguage.vi) {
      switch (this) {
        case EstimateReliability.insufficient:
          return 'Chờ dữ liệu';
        case EstimateReliability.limitedInformation:
          return 'Chu kỳ mẫu (28 ngày)';
        case EstimateReliability.preliminary:
          return 'Ước tính sơ bộ';
        case EstimateReliability.cycleInformed:
          return 'Theo dõi chu kỳ';
        case EstimateReliability.variableCycle:
          return 'Chu kỳ dao động';
      }
    }
    switch (this) {
      case EstimateReliability.insufficient:
        return 'Awaiting Period Date';
      case EstimateReliability.limitedInformation:
        return 'General Baseline';
      case EstimateReliability.preliminary:
        return 'Early Estimate';
      case EstimateReliability.cycleInformed:
        return 'Cycle-Informed';
      case EstimateReliability.variableCycle:
        return 'Variable Cycle';
    }
  }
}

@immutable
class CycleEstimate {
  final EstimateReliability reliability;
  final double? averageCycleLength;
  final int variabilityDays;
  final double? averagePeriodDuration;
  final DateTime? nextEstimatedPeriodStart;
  final DateTime? estimatedPeriodWindowStart;
  final DateTime? estimatedPeriodWindowEnd;
  final int? daysUntilEstimatedPeriod;
  final CyclePhase currentEstimatedPhase;
  final int? dayOfCycle;
  final int recordedCyclesCount;
  final String statusTitle;
  final String explanationMessage;

  const CycleEstimate({
    required this.reliability,
    this.averageCycleLength,
    this.variabilityDays = 2,
    this.averagePeriodDuration,
    this.nextEstimatedPeriodStart,
    this.estimatedPeriodWindowStart,
    this.estimatedPeriodWindowEnd,
    this.daysUntilEstimatedPeriod,
    required this.currentEstimatedPhase,
    this.dayOfCycle,
    required this.recordedCyclesCount,
    required this.statusTitle,
    required this.explanationMessage,
  });

  bool get hasPrediction =>
      nextEstimatedPeriodStart != null &&
      reliability != EstimateReliability.insufficient;

  bool get isLimitedHistory =>
      reliability == EstimateReliability.insufficient ||
      reliability == EstimateReliability.limitedInformation ||
      reliability == EstimateReliability.preliminary;

  /// Returns user-friendly summary of estimated period timing
  String get timingHeadline => localizedTimingHeadline(AppLanguage.en);

  String localizedTimingHeadline(AppLanguage language) {
    final isVi = language == AppLanguage.vi;

    if (daysUntilEstimatedPeriod == null) {
      if (dayOfCycle != null) {
        return isVi ? 'Ngày $dayOfCycle của chu kỳ hiện tại' : 'Day $dayOfCycle of current cycle';
      }
      return isVi ? 'Awaiting first period date' : 'Awaiting first period date';
    }

    if (daysUntilEstimatedPeriod! == 0) {
      return isVi
          ? 'Khoảng chu kỳ dự kiến bắt đầu khoảng hôm nay'
          : 'Estimated cycle window begins around today';
    } else if (daysUntilEstimatedPeriod! > 0) {
      return isVi
          ? 'Kỳ kinh dự kiến tiếp theo sau ~$daysUntilEstimatedPeriod ngày'
          : 'Next estimated period in ~$daysUntilEstimatedPeriod days';
    } else {
      final overdueBy = daysUntilEstimatedPeriod!.abs();
      return isVi
          ? 'Khoảng dự kiến cách đây ~$overdueBy ngày (chu kỳ thay đổi tự nhiên)'
          : 'Estimated window was ~$overdueBy days ago (cycles vary naturally)';
    }
  }

  String localizedExplanationMessage(AppLanguage language) {
    if (language == AppLanguage.vi) {
      if (reliability == EstimateReliability.insufficient) {
        return 'Hãy bắt đầu bằng việc ghi nhận ngày đầu tiên của kỳ kinh gần nhất. HerCare sẽ tự động ước tính giai đoạn chu kỳ và các trải nghiệm có thể xuất hiện.';
      } else if (reliability == EstimateReliability.limitedInformation) {
        return 'Ước tính theo chu kỳ mẫu 28 ngày tiêu chuẩn từ 1 ngày kinh đã ghi nhận. Cần ghi nhận từ 2-3 chu kỳ để cá nhân hóa chính xác hơn.';
      } else if (reliability == EstimateReliability.preliminary) {
        return 'Dựa trên 1 khoảng chu kỳ đã ghi nhận (${averageCycleLength?.round() ?? 28} ngày). Nên theo dõi thêm để có dự đoán chuẩn xác hơn.';
      } else if (reliability == EstimateReliability.variableCycle) {
        return 'Chu kỳ trung bình khoảng ${averageCycleLength?.toStringAsFixed(1) ?? '28'} ngày với độ dao động tự nhiên (±$variabilityDays ngày).';
      } else {
        return 'Dựa trên chu kỳ quan sát trung bình ${averageCycleLength?.toStringAsFixed(1) ?? '28'} ngày (dao động ±$variabilityDays ngày).';
      }
    }
    return explanationMessage;
  }
}
