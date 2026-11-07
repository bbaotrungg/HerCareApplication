import 'package:flutter/material.dart';

enum TipCategory {
  cycleUnderstanding,
  physicalComfort,
  emotionalSupport,
  respectfulCommunication,
  practicalEssentials,
  predictionUncertainty;

  String get displayName {
    switch (this) {
      case TipCategory.cycleUnderstanding:
        return 'Understanding the Cycle';
      case TipCategory.physicalComfort:
        return 'Physical Comfort';
      case TipCategory.emotionalSupport:
        return 'Emotional Support';
      case TipCategory.respectfulCommunication:
        return 'Respectful Communication';
      case TipCategory.practicalEssentials:
        return 'Practical Essentials';
      case TipCategory.predictionUncertainty:
        return 'Cycle Uncertainty';
    }
  }

  String localizedName(bool isVi) {
    if (isVi) {
      switch (this) {
        case TipCategory.cycleUnderstanding:
          return 'Hiểu về chu kỳ';
        case TipCategory.physicalComfort:
          return 'Giảm đau & Tạo thoải mái';
        case TipCategory.emotionalSupport:
          return 'Giao tiếp & Thấu cảm';
        case TipCategory.respectfulCommunication:
          return 'Giao tiếp tinh tế';
        case TipCategory.practicalEssentials:
          return 'Đồ dùng thiết yếu';
        case TipCategory.predictionUncertainty:
          return 'Dao động tự nhiên';
      }
    }
    return displayName;
  }

  IconData get icon {
    switch (this) {
      case TipCategory.cycleUnderstanding:
        return Icons.auto_stories_outlined;
      case TipCategory.physicalComfort:
        return Icons.spa_outlined;
      case TipCategory.emotionalSupport:
        return Icons.favorite_outline;
      case TipCategory.respectfulCommunication:
        return Icons.record_voice_over_outlined;
      case TipCategory.practicalEssentials:
        return Icons.shopping_bag_outlined;
      case TipCategory.predictionUncertainty:
        return Icons.hourglass_empty_outlined;
    }
  }
}

class EducationalTip {
  final String id;
  final String title;
  final String summary;
  final String fullContent;
  final TipCategory category;
  final List<String> actionablePoints;
  final String? titleVi;
  final String? summaryVi;
  final String? fullContentVi;
  final List<String>? actionablePointsVi;

  const EducationalTip({
    required this.id,
    required this.title,
    required this.summary,
    required this.fullContent,
    required this.category,
    this.actionablePoints = const [],
    this.titleVi,
    this.summaryVi,
    this.fullContentVi,
    this.actionablePointsVi,
  });

  String localizedTitle(bool isVi) => (isVi && titleVi != null) ? titleVi! : title;
  String localizedSummary(bool isVi) => (isVi && summaryVi != null) ? summaryVi! : summary;
  String localizedContent(bool isVi) => (isVi && fullContentVi != null) ? fullContentVi! : fullContent;
  List<String> localizedActionablePoints(bool isVi) =>
      (isVi && actionablePointsVi != null) ? actionablePointsVi! : actionablePoints;
}

