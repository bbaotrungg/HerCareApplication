import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/core/widgets/hercare_logo.dart';

void main() {
  group('HerCareLogo Widget Tests', () {
    testWidgets('renders CustomPaint with HerCareLogoPainter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HerCareLogo(size: 32),
            ),
          ),
        ),
      );

      expect(find.byType(HerCareLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.bySemanticsLabel('HerCare Logo'), findsOneWidget);

      final customPaintFinder = find.descendant(
        of: find.byType(HerCareLogo),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(customPaintFinder);
      expect(customPaint.painter, isA<HerCareLogoPainter>());
      expect(customPaint.size, const Size(32, 32));
    });

    testWidgets('renders with container decoration when withContainer is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HerCareLogo(
                size: 48,
                withContainer: true,
                containerColor: Colors.white,
                containerPadding: 12,
                containerRadius: 16,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(HerCareLogo), findsOneWidget);
      final containerFinder = find.descendant(
        of: find.byType(HerCareLogo),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    test('HerCareLogoPainter shouldRepaint returns false', () {
      const painter = HerCareLogoPainter();
      expect(painter.shouldRepaint(const HerCareLogoPainter()), isFalse);
    });

    test('Brand colors match SVG hex values', () {
      expect(HerCareLogo.partnerBlue.toARGB32(), const Color(0xFF0960D5).toARGB32());
      expect(HerCareLogo.herRose.toARGB32(), const Color(0xFFFF007F).toARGB32());
    });
  });
}

