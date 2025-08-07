/// FlowXML - A modern Flutter library that converts XML code into Flutter components with real-time streaming support.
///
/// This library provides a comprehensive solution for handling streaming XML responses and rendering dynamic UI components.
library flowxml;

import 'package:flowxml/flowxml.dart';

// Core exports
export 'src/core/xml_parser.dart';
export 'src/core/xml_renderer.dart';
export 'src/core/component_base.dart';
export 'src/core/component_registry.dart';
export 'src/core/xml_stream_controller.dart';

// Models
export 'src/models/parsed_component.dart';
export 'src/models/component_props.dart';
export 'src/models/xml_parser_state.dart';

// Components
export 'src/components/built_in_components.dart';
export 'src/components/text_component.dart';
export 'src/components/image_component.dart';
export 'src/components/video_component.dart';
export 'src/components/option_selector.dart';
export 'src/components/selected_option_component.dart';
export 'src/components/loader_component.dart';
export 'src/components/post_body_component.dart';
export 'src/components/button_component.dart';
export 'src/components/card_component.dart';
export 'src/components/list_component.dart';
export 'src/components/progress_component.dart';
export 'src/components/fallback_component.dart';

// Utils
export 'src/utils/xml_utils.dart';

/// Main convenience class for FlowXML functionality
class FlowXML {
  static ComponentRegistry get registry => ComponentRegistry.instance;

  /// Create a new XML renderer widget
  static XmlRenderer renderer({
    required String xmlContent,
    bool isStreaming = false,
    void Function(List<ParsedComponent>)? onComponentsUpdate,
    ComponentCallback? onComponentInteraction,
    ComponentRegistry? registry,
    ComponentStyle? style,
  }) {
    return XmlRenderer(
      xmlContent: xmlContent,
      isStreaming: isStreaming,
      onComponentsUpdate: onComponentsUpdate,
      onComponentInteraction: onComponentInteraction,
      registry: registry,
      style: style,
    );
  }

  /// Create a new XML stream controller for advanced streaming
  static XmlStreamController createStreamController() {
    return XmlStreamController();
  }

  /// Register a custom component
  static void registerComponent<T extends XmlComponent>(
    String type,
    T Function(ComponentProps props) creator,
  ) {
    registry.registerComponent<T>(type, creator);
  }

  /// Check if a component type is registered
  static bool isComponentRegistered(String type) {
    return registry.isRegistered(type);
  }
}
