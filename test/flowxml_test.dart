import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowxml/flowxml.dart';

void main() {
  group('FlowXML Core Tests', () {
    late ComponentRegistry registry;

    setUp(() {
      registry = ComponentRegistry.instance;
    });

    test('should have built-in components registered', () {
      expect(registry.isRegistered('Card'), true);
      expect(registry.isRegistered('Image'), true);
      expect(registry.isRegistered('Video'), true);
      expect(registry.isRegistered('Button'), true);
      expect(registry.isRegistered('Progress'), true);
      expect(registry.isRegistered('List'), true);
      expect(registry.isRegistered('OptionSelector'), true);
      expect(registry.isRegistered('PostBody'), true);
      expect(registry.isRegistered('Loader'), true);
    });

    test('should create XML stream controller', () {
      final controller = FlowXML.createStreamController();
      expect(controller, isA<XmlStreamController>());
      expect(controller.isStreaming, false);
      expect(controller.currentComponents, isEmpty);

      // Clean up
      controller.dispose();
    });

    test('should register custom component', () {
      const testComponentType = 'TestComponent';

      // Register custom component
      FlowXML.registerComponent(testComponentType, (props) {
        return TestComponent(props: props);
      });

      expect(registry.isRegistered(testComponentType), true);

      // Clean up
      registry.unregister(testComponentType);
    });

    test('should handle component aliases', () {
      registry.registerAlias('Img', 'Image');
      expect(registry.isRegistered('Img'), true);

      final component = registry.createComponent(
          'Img', const ComponentProps(content: 'test'));
      expect(component, isNotNull);
      expect(component, isA<ImageComponent>());
    });

    test('should check if component is registered', () {
      expect(FlowXML.isComponentRegistered('Card'), true);
      expect(FlowXML.isComponentRegistered('NonExistentComponent'), false);
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

  group('ParsedComponent Tests', () {
    test('should create parsed component correctly', () {
      const component = ParsedComponent(
        id: 'test-1',
        type: ComponentType.component,
        componentType: 'Card',
        content: 'Test content',
        attributes: {'title': 'Test'},
        isComplete: true,
      );

      expect(component.id, 'test-1');
      expect(component.type, ComponentType.component);
      expect(component.componentType, 'Card');
      expect(component.content, 'Test content');
      expect(component.isComplete, true);
    });

    test('should copy with new values', () {
      const original = ParsedComponent(
        id: 'test-1',
        type: ComponentType.text,
        content: 'Original',
      );

      final copy = original.copyWith(
        content: 'Updated',
        isComplete: true,
      );

      expect(copy.content, 'Updated');
      expect(copy.isComplete, true);
      expect(copy.id, original.id); // Should keep original id
    });
  });

  group('XML Stream Controller Tests', () {
    late XmlStreamController controller;

    setUp(() {
      controller = XmlStreamController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should have initial state', () {
      expect(controller.isStreaming, false);
      expect(controller.currentComponents, isEmpty);
      expect(controller.currentError, isNull);
    });

    test('should start streaming', () {
      controller.startStreaming();
      expect(controller.isStreaming, true);
    });

    test('should reset state', () {
      controller.startStreaming();
      controller.reset();
      expect(controller.isStreaming, false);
      expect(controller.currentComponents, isEmpty);
    });

    test('should provide statistics', () {
      final stats = controller.statistics;
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('componentsCount'), true);
      expect(stats.containsKey('isStreaming'), true);
    });
  });
}

// Test component for custom component registration tests
class TestComponent extends XmlComponent {
  const TestComponent({super.key, required super.props});

  @override
  String get componentType => 'TestComponent';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(props.content),
    );
  }
}
