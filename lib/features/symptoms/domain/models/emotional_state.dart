import 'package:flutter/material.dart';

enum EmotionalState {
  comfortable,
  tired,
  stressed,
  sad,
  irritable,
  anxious,
  wantsRest,
  wantsCompany;

  String get displayName {
    switch (this) {
      case EmotionalState.comfortable:
        return 'Feeling comfortable / okay';
      case EmotionalState.tired:
        return 'Feeling tired / low energy';
      case EmotionalState.stressed:
        return 'Feeling stressed';
      case EmotionalState.sad:
        return 'Feeling sad';
      case EmotionalState.irritable:
        return 'Feeling irritable / overwhelmed';
      case EmotionalState.anxious:
        return 'Feeling anxious';
      case EmotionalState.wantsRest:
        return 'Wanting quiet time / rest';
      case EmotionalState.wantsCompany:
        return 'Wanting company / emotional support';
    }
  }

  IconData get icon {
    switch (this) {
      case EmotionalState.comfortable:
        return Icons.sentiment_satisfied_alt;
      case EmotionalState.tired:
        return Icons.nights_stay_outlined;
      case EmotionalState.stressed:
        return Icons.thunderstorm_outlined;
      case EmotionalState.sad:
        return Icons.cloud_outlined;
      case EmotionalState.irritable:
        return Icons.sentiment_neutral_outlined;
      case EmotionalState.anxious:
        return Icons.air_outlined;
      case EmotionalState.wantsRest:
        return Icons.self_improvement_outlined;
      case EmotionalState.wantsCompany:
        return Icons.favorite_outline;
    }
  }
}

