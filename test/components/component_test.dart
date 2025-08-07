import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowxml/flowxml.dart';

void main() {
  group('Component Tests', () {
    testWidgets('TextComponent should render text content',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Hello World',
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextComponent(props: props),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('CardComponent should render with title',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Card content',
        attributes: {'title': 'Test Card'},
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardComponent(props: props),
          ),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });
  });
}
