import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_news_app/views/widgets/publisher_logo.dart';

void main() {
  group('PublisherLogo Tests', () {
    testWidgets('renders CNN badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PublisherLogo(newsSite: 'CNN Indonesia'),
          ),
        ),
      );

      expect(find.text('CNN'), findsOneWidget);
    });

    testWidgets('renders NASA badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PublisherLogo(newsSite: 'NASA'),
          ),
        ),
      );

      expect(find.text('NASA'), findsOneWidget);
    });

    testWidgets('renders NSF badge for NASASpaceflight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PublisherLogo(newsSite: 'NASASpaceflight'),
          ),
        ),
      );

      expect(find.text('NSF'), findsOneWidget);
    });
  });
}
