import 'package:meta/meta.dart';
import 'parsed_component.dart';

/// State management for streaming XML parser
@immutable
class XmlParserState {
  /// Buffer holding incomplete XML content
  final String buffer;

  /// List of completed parsed components
  final List<ParsedComponent> components;

  /// Currently being parsed component
  final ParsedComponent? currentComponent;

  /// Whether we're inside a Message tag
  final bool isInsideMessage;

  /// Whether we're inside a ChatResponse tag
  final bool isInsideChatResponse;

  /// Current nesting depth
  final int depth;

  /// Component stack for nested parsing
  final List<ComponentStackEntry> componentStack;

  const XmlParserState({
    this.buffer = '',
    this.components = const [],
    this.currentComponent,
    this.isInsideMessage = false,
    this.isInsideChatResponse = false,
    this.depth = 0,
    this.componentStack = const [],
  });

  XmlParserState copyWith({
    String? buffer,
    List<ParsedComponent>? components,
    ParsedComponent? currentComponent,
    bool? isInsideMessage,
    bool? isInsideChatResponse,
    int? depth,
    List<ComponentStackEntry>? componentStack,
  }) {
    return XmlParserState(
      buffer: buffer ?? this.buffer,
      components: components ?? this.components,
      currentComponent: currentComponent,
      isInsideMessage: isInsideMessage ?? this.isInsideMessage,
      isInsideChatResponse: isInsideChatResponse ?? this.isInsideChatResponse,
      depth: depth ?? this.depth,
      componentStack: componentStack ?? this.componentStack,
    );
  }
}

/// Entry for component stack tracking
@immutable
class ComponentStackEntry {
  final String tag;
  final Map<String, String> attributes;

  const ComponentStackEntry({required this.tag, required this.attributes});
}
