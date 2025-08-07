import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowxml/flowxml.dart';

void main() {
  group('Component Widget Tests', () {
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

    testWidgets('CardComponent should render with title and content',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Card content here',
        attributes: {'title': 'Test Card', 'subtitle': 'Test Subtitle'},
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
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.text('Card content here'), findsOneWidget);
    });

    testWidgets('ButtonComponent should render with text',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Click Me',
        attributes: {'action': 'test_action'},
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ButtonComponent(props: props),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('ProgressComponent should render linear progress',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: '50% Complete',
        attributes: {
          'type': 'linear',
          'value': '50',
          'max': '100',
        },
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressComponent(props: props),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('50% Complete'), findsOneWidget);
    });

    testWidgets('ProgressComponent should render circular progress',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Loading...',
        attributes: {
          'type': 'circular',
          'value': '75',
          'max': '100',
        },
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressComponent(props: props),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoaderComponent should render loading indicator',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Loading content...',
        attributes: {
          'type': 'circular',
          'size': 'medium',
        },
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoaderComponent(props: props),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading content...'), findsOneWidget);
    });

    testWidgets('FallbackComponent should render content',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Unknown component content',
        attributes: {'originalType': 'UnknownComponent'},
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FallbackComponent(props: props),
          ),
        ),
      );

      expect(find.text('Unknown component content'), findsOneWidget);
    });

    testWidgets('ImageComponent should render placeholder content',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Sample image',
        attributes: {
          'src': 'https://example.com/image.jpg',
          'width': '300',
          'height': '200',
        },
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageComponent(props: props),
          ),
        ),
      );

      // Image component should render something
      expect(find.text('Sample image'), findsOneWidget);
    });

    testWidgets('ListComponent should render ordered list',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Item 1,Item 2,Item 3',
        attributes: {
          'type': 'ordered',
          'numbered': 'true',
        },
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListComponent(props: props),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('OptionSelectorComponent should render options',
        (WidgetTester tester) async {
      const props = ComponentProps(
        content: 'Choose your option',
        attributes: {
          'options': 'Option A,Option B,Option C',
          'title': 'Select One',
        },
        isComplete: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OptionSelectorComponent(props: props),
          ),
        ),
      );

      expect(find.text('Select One'), findsOneWidget);
      expect(find.text('Choose your option'), findsOneWidget);
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      expect(find.text('Option C'), findsOneWidget);
    });
  });

  group('ComponentProps Tests', () {
    test('should get attribute values correctly', () {
      const props = ComponentProps(
        content: 'test content',
        attributes: {
          'title': 'Test Title',
          'visible': 'true',
          'count': '42',
        },
      );

      expect(props.getAttribute('title'), 'Test Title');
      expect(props.getAttribute('missing', 'default'), 'default');
      expect(props.getBoolAttribute('visible'), true);
      expect(props.getBoolAttribute('missing', false), false);
      expect(props.getIntAttribute('count'), 42);
      expect(props.getIntAttribute('missing', 10), 10);
    });

    test('should check attribute existence', () {
      const props = ComponentProps(
        content: 'test content',
        attributes: {'existing': 'value'},
      );

      expect(props.hasAttribute('existing'), true);
      expect(props.hasAttribute('missing'), false);
    });
  });
}
