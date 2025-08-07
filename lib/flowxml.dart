/// FlowXML - A modern Flutter library that converts XML code into Flutter components with real-time streaming support.
///
/// This library provides a comprehensive solution for handling streaming XML responses from AI APIs
/// and rendering dynamic UI components in Flutter. It's designed with flexibility, modularity, and scalability in mind.
///
/// ## Features
///
/// - **🔄 Real-time Streaming**: Handle partial XML content as it streams
/// - **🧩 Dynamic Components**: Render interactive UI elements based on XML tags
/// - **🎨 Customizable**: Easy to add new component types and customize existing ones
/// - **📱 Flutter Native**: Built specifically for Flutter with Material Design
/// - **🚀 High Performance**: Efficient parsing and rendering with minimal overhead
/// - **🛡️ Error Resilient**: Graceful handling of malformed or incomplete XML
/// - **📦 Extensible**: Modular architecture for easy expansion
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flowxml/flowxml.dart';
///
/// // Simple XML rendering
/// FlowXML.renderer(
///   xmlContent: '<Card title="Hello">Welcome to FlowXML!</Card>',
///   onComponentInteraction: (action, data) {
///     print('User interacted: $action');
///   },
/// )
///
/// // Advanced streaming
/// final controller = FlowXML.createStreamController();
/// controller.startStreaming();
/// controller.addChunk('<Message>Hello ');
/// controller.addChunk('World!</Message>');
/// controller.completeStreaming();
/// ```
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

/// Main convenience class for FlowXML functionality.
///
/// This class provides static methods for easy access to FlowXML's core features:
/// - Creating XML renderers for displaying XML content as Flutter widgets
/// - Managing XML stream controllers for real-time content streaming
/// - Registering custom components and managing the component registry
///
/// ## Basic Usage
///
/// ```dart
/// // Render static XML content
/// FlowXML.renderer(
///   xmlContent: '<Card title="Hello">Content here</Card>',
/// )
///
/// // Handle streaming XML
/// final controller = FlowXML.createStreamController();
/// // ... use controller for streaming
/// ```
class FlowXML {
  /// Access to the global component registry.
  ///
  /// Use this to register custom components, check component availability,
  /// or get registry statistics.
  static ComponentRegistry get registry => ComponentRegistry.instance;

  /// Create a new XML renderer widget for displaying XML content as Flutter components.
  ///
  /// This is the primary method for rendering XML content in your Flutter app.
  /// It automatically parses the XML and creates appropriate Flutter widgets.
  ///
  /// ## Parameters
  ///
  /// - [xmlContent]: The XML string to parse and render
  /// - [isStreaming]: Whether the content is still being streamed (affects completion state)
  /// - [onComponentsUpdate]: Callback fired when the list of parsed components changes
  /// - [onComponentInteraction]: Callback for handling user interactions with components
  /// - [registry]: Custom component registry (uses global registry if null)
  /// - [style]: Custom styling for components
  ///
  /// ## Example
  ///
  /// ```dart
  /// FlowXML.renderer(
  ///   xmlContent: '''
  ///     <ChatResponse>
  ///       <Message>Hello World!</Message>
  ///       <Button action="greet">Say Hello</Button>
  ///     </ChatResponse>
  ///   ''',
  ///   onComponentInteraction: (action, data) {
  ///     if (action == 'button_press') {
  ///       print('Button clicked: ${data['action']}');
  ///     }
  ///   },
  /// )
  /// ```
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

  /// Create a new XML stream controller for advanced streaming scenarios.
  ///
  /// Use this when you need fine-grained control over XML streaming, such as:
  /// - Handling real-time AI responses
  /// - Processing large XML datasets in chunks
  /// - Managing streaming state and error handling
  ///
  /// ## Example
  ///
  /// ```dart
  /// final controller = FlowXML.createStreamController();
  ///
  /// // Listen to parsed components
  /// controller.componentsStream.listen((components) {
  ///   // Update UI with new components
  /// });
  ///
  /// // Start streaming
  /// controller.startStreaming();
  ///
  /// // Add content chunks as they arrive
  /// controller.addChunk('<Message>Hello ');
  /// controller.addChunk('World!</Message>');
  ///
  /// // Complete the stream
  /// controller.completeStreaming();
  ///
  /// // Clean up
  /// controller.dispose();
  /// ```
  ///
  /// Returns a new [XmlStreamController] instance.
  static XmlStreamController createStreamController() {
    return XmlStreamController();
  }

  /// Register a custom component type with the global component registry.
  ///
  /// This allows you to extend FlowXML with your own custom components that
  /// can be used in XML content just like built-in components.
  ///
  /// ## Parameters
  ///
  /// - [type]: The XML tag name for your component (e.g., 'CustomCard')
  /// - [creator]: Factory function that creates your component from props
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Define a custom component
  /// class AlertComponent extends XmlComponent {
  ///   const AlertComponent({super.key, required super.props});
  ///
  ///   @override
  ///   String get componentType => 'Alert';
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Container(
  ///       padding: EdgeInsets.all(16),
  ///       color: Colors.orange[100],
  ///       child: Text(props.content),
  ///     );
  ///   }
  /// }
  ///
  /// // Register the component
  /// FlowXML.registerComponent('Alert', (props) => AlertComponent(props: props));
  ///
  /// // Now you can use it in XML:
  /// // <Alert>Warning message!</Alert>
  /// ```
  static void registerComponent<T extends XmlComponent>(
    String type,
    T Function(ComponentProps props) creator,
  ) {
    registry.registerComponent<T>(type, creator);
  }

  /// Check if a component type is registered in the global registry.
  ///
  /// Useful for conditionally handling XML content based on available components.
  ///
  /// ## Parameters
  ///
  /// - [type]: The component type name to check
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (FlowXML.isComponentRegistered('CustomAlert')) {
  ///   // Can safely use <CustomAlert> tags
  /// } else {
  ///   // Component not available, handle gracefully
  /// }
  /// ```
  ///
  /// Returns `true` if the component type is registered, `false` otherwise.
  static bool isComponentRegistered(String type) {
    return registry.isRegistered(type);
  }
}
