import 'package:flutter/material.dart';

/// HerCare Custom Design System Color Palette.
/// Designed with muted lavender, soft rose, warm ivory, muted sage,
/// and soft neutral tones for a calm, respectful, mature feel.
class AppColors {
  AppColors._();

  // Primary & Secondary Accents (Muted Lavender & Soft Rose)
  static const Color lavender = Color(0xFF7E72A2);
  static const Color lavenderLight = Color(0xFFABA1CA);
  static const Color lavenderDark = Color(0xFF564B7A);
  static const Color lavenderSurface = Color(0xFFF3F0F9);

  static const Color softRose = Color(0xFFD47A88);
  static const Color softRoseLight = Color(0xFFF3BDC5);
  static const Color softRoseDark = Color(0xFFA54E5C);
  static const Color softRoseSurface = Color(0xFFFDF2F4);

  // Muted Sage (Wellness, Follicular & Calming indicators)
  static const Color sage = Color(0xFF6B8E7D);
  static const Color sageLight = Color(0xFFB2CCC0);
  static const Color sageDark = Color(0xFF436555);
  static const Color sageSurface = Color(0xFFEEF5F1);

  // Warm Amber / Sunbeam (Luteal / Ovulatory window hints)
  static const Color warmAmber = Color(0xFFC78B43);
  static const Color warmAmberSurface = Color(0xFFFBF4EA);

  // Warm Ivory & Neutral Backgrounds (Light mode)
  static const Color warmIvory = Color(0xFFFAF7F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFCFAF7);
  static const Color textPrimaryLight = Color(0xFF2D2A32);
  static const Color textSecondaryLight = Color(0xFF6B6773);
  static const Color dividerLight = Color(0xFFE9E5DE);

  // Dark Theme Palette
  static const Color backgroundDark = Color(0xFF19171C);
  static const Color surfaceDark = Color(0xFF221F27);
  static const Color cardDark = Color(0xFF2B2732);
  static const Color textPrimaryDark = Color(0xFFF4F1F8);
  static const Color textSecondaryDark = Color(0xFFAFA9BA);
  static const Color dividerDark = Color(0xFF383342);

  // Cycle Phase Specific Colors
  static const Color menstrual = Color(0xFFD47A88);      // Soft Rose
  static const Color follicular = Color(0xFF6B8E7D);     // Muted Sage
  static const Color ovulatory = Color(0xFFC78B43);      // Warm Amber
  static const Color luteal = Color(0xFF7E72A2);         // Muted Lavender
  static const Color uncertain = Color(0xFF8C8894);      // Neutral Slate
}

