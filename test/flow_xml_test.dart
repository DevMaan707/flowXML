import 'package:flutter_test/flutter_test.dart';
import 'package:flowxml/flowxml.dart';

void main() {
  group('FlowXML Tests', () {
    test('should register and retrieve components', () {
      final registry = ComponentRegistry.instance;

      // Test that built-in components are registered
      expect(registry.isRegistered('Card'), true);
      expect(registry.isRegistered('Image'), true);
      expect(registry.isRegistered('Video'), true);
      expect(registry.isRegistered('Button'), true);
    });

    test('should create XML stream controller', () {
      final controller = FlowXML.createStreamController();
      expect(controller, isA<XmlStreamController>());

      // Clean up
      controller.dispose();
    });

    test('should parse simple XML', () {
      const xmlContent = '<Card title="Test">Content</Card>';
      final parser = StreamingXmlParser();
      final components = parser.addChunk(xmlContent);

      expect(components, isNotEmpty);
    });
  });
}
