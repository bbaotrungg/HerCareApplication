import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The official HerCare brand logo.
///
/// Features the two iconic companion dots:
/// - Left dot: Blue (#0960D5) representing the caring partner.
/// - Right dot: Vibrant rose (#FF007F) representing her.
///
/// Preserves the exact cubic Bézier geometry, colors, and aspect ratio of
/// `hercare-logo.svg`. Renders as an ultra-crisp, resolution-independent vector
/// with semantic accessibility support.
class HerCareLogo extends StatelessWidget {
  /// The diameter of the square bounding box containing the logo.
  final double size;

  /// Optional container styling for avatar/badge presentations.
  final bool withContainer;

  /// Optional background color when [withContainer] is true.
  final Color? containerColor;

  /// Optional padding around the logo when [withContainer] is true.
  final double? containerPadding;

  /// Optional border radius when [withContainer] is true.
  final double? containerRadius;

  /// Semantic label for screen readers.
  final String semanticLabel;

  const HerCareLogo({
    super.key,
    this.size = 24,
    this.withContainer = false,
    this.containerColor,
    this.containerPadding,
    this.containerRadius,
    this.semanticLabel = 'HerCare Logo',
  });

  /// The official logo colors for brand consistency.
  static const Color partnerBlue = Color(0xFF0960D5);
  static const Color herRose = Color(0xFFFF007F);

  @override
  Widget build(BuildContext context) {
    Widget logo = Semantics(
      label: semanticLabel,
      image: true,
      child: CustomPaint(
        size: Size(size, size),
        painter: const HerCareLogoPainter(),
      ),
    );

    if (withContainer) {
      final padding = containerPadding ?? (size * 0.25);
      final radius = containerRadius ?? (size * 0.4);
      final bgColor = containerColor ??
          Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

      logo = Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: logo,
      );
    }

    return logo;
  }
}

/// Custom painter that renders the exact mathematical curves of `hercare-logo.svg`.
class HerCareLogoPainter extends CustomPainter {
  const HerCareLogoPainter();

  // Intrinsic dimensions from SVG path data
  static const double _svgWidth = 46.8292683;
  static const double _svgHeight = 20.3418803;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _svgWidth, size.height / _svgHeight);
    final drawWidth = _svgWidth * scale;
    final drawHeight = _svgHeight * scale;
    final offsetX = (size.width - drawWidth) / 2.0;
    final offsetY = (size.height - drawHeight) / 2.0;

    double pX(double x) => offsetX + (x * scale);
    double pY(double y) => offsetY + (y * scale);

    // 1. Blue Circle (Left dot - Partner / Care)
    final bluePaint = Paint()
      ..color = HerCareLogo.partnerBlue
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bluePath = Path()
      ..moveTo(pX(20.6294395), pY(10.1695828))
      ..cubicTo(
        pX(20.6294395),
        pY(15.7864719),
        pX(16.0145249),
        pY(20.3418803),
        pX(10.3092127),
        pY(20.3418803),
      )
      ..cubicTo(
        pX(4.61216113),
        pY(20.3418803),
        pX(0),
        pY(15.7864719),
        pX(0),
        pY(10.1695828),
      )
      ..cubicTo(
        pX(0),
        pY(4.55540841),
        pX(4.61216113),
        pY(0),
        pX(10.3092127),
        pY(0),
      )
      ..cubicTo(
        pX(16.0145249),
        pY(0),
        pX(20.6294395),
        pY(4.55540841),
        pX(20.6294395),
        pY(10.1695828),
      )
      ..close();

    canvas.drawPath(bluePath, bluePaint);

    // 2. Pink/Rose Circle (Right dot - Her / Loved One)
    final pinkPaint = Paint()
      ..color = HerCareLogo.herRose
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final pinkPath = Path()
      ..moveTo(pX(46.8292683), pY(10.1695828))
      ..cubicTo(
        pX(46.8292683),
        pY(15.7864719),
        pX(42.2171072),
        pY(20.3418803),
        pX(36.5173021),
        pY(20.3418803),
      )
      ..cubicTo(
        pX(30.8119899),
        pY(20.3418803),
        pX(26.1970752),
        pY(15.7864719),
        pX(26.1970752),
        pY(10.1695828),
      )
      ..cubicTo(
        pX(26.1970752),
        pY(4.55540841),
        pX(30.8119899),
        pY(0),
        pX(36.5173021),
        pY(0),
      )
      ..cubicTo(
        pX(42.2171072),
        pY(0),
        pX(46.8292683),
        pY(4.55540841),
        pX(46.8292683),
        pY(10.1695828),
      )
      ..close();

    canvas.drawPath(pinkPath, pinkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

