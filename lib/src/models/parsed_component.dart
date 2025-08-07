import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Represents a parsed component from XML content
@immutable
class ParsedComponent extends Equatable {
  /// The type of component ('text' or 'component')
  final ComponentType type;

  /// The text content of the component
  final String content;

  /// The component type name (e.g., 'Image', 'Video') for component types
  final String? componentType;

  /// XML attributes as key-value pairs
  final Map<String, String> attributes;

  /// Whether the component parsing is complete
  final bool isComplete;

  /// Unique identifier for the component
  final String id;

  const ParsedComponent({
    required this.type,
    required this.content,
    this.componentType,
    this.attributes = const {},
    this.isComplete = false,
    required this.id,
  });

  @override
  List<Object?> get props =>
      [type, content, componentType, attributes, isComplete, id];

  ParsedComponent copyWith({
    ComponentType? type,
    String? content,
    String? componentType,
    Map<String, String>? attributes,
    bool? isComplete,
    String? id,
  }) {
    return ParsedComponent(
      type: type ?? this.type,
      content: content ?? this.content,
      componentType: componentType ?? this.componentType,
      attributes: attributes ?? this.attributes,
      isComplete: isComplete ?? this.isComplete,
      id: id ?? this.id,
    );
  }
}

/// Enum representing component types
enum ComponentType { text, component }
