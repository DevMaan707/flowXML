import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Base properties for all XML components
@immutable
class ComponentProps {
  /// The text content of the component
  final String content;

  /// XML attributes as key-value pairs
  final Map<String, String> attributes;

  /// Whether the component parsing is complete
  final bool isComplete;

  /// Callback for component interactions
  final ComponentCallback? onInteraction;

  /// Build context for accessing theme and media query
  final BuildContext? context;

  /// Custom style overrides
  final ComponentStyle? style;

  const ComponentProps({
    required this.content,
    this.attributes = const {},
    this.isComplete = false,
    this.onInteraction,
    this.context,
    this.style,
  });

  /// Get attribute value with optional default
  String getAttribute(String key, [String defaultValue = '']) {
    return attributes[key] ?? defaultValue;
  }

  /// Check if attribute exists
  bool hasAttribute(String key) {
    return attributes.containsKey(key);
  }

  /// Get attribute as boolean
  bool getBoolAttribute(String key, [bool defaultValue = false]) {
    final value = attributes[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Get attribute as integer
  int getIntAttribute(String key, [int defaultValue = 0]) {
    final value = attributes[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }
}

/// Callback function type for component interactions
typedef ComponentCallback = void Function(
    String action, Map<String, dynamic> data);

/// Custom styling for components
@immutable
class ComponentStyle {
  final double? padding;
  final double? margin;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ComponentStyle({
    this.padding,
    this.margin,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });
}
