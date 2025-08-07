// Export all built-in components
export 'image_component.dart';
export 'video_component.dart';
export 'option_selector.dart';
export 'selected_option_component.dart';
export 'loader_component.dart';
export 'post_body_component.dart';
export 'button_component.dart';
export 'card_component.dart';
export 'list_component.dart';
export 'progress_component.dart';
export 'text_component.dart';
export 'fallback_component.dart';

import 'package:flutter/material.dart';
import '../models/component_props.dart';
import '../core/component_base.dart';

// Re-export individual components for easy importing
import 'image_component.dart';
import 'video_component.dart';
import 'option_selector.dart';
import 'selected_option_component.dart';
import 'loader_component.dart';
import 'post_body_component.dart';
import 'button_component.dart';
import 'card_component.dart';
import 'list_component.dart';
import 'progress_component.dart';
import 'text_component.dart';
import 'fallback_component.dart';

/// Helper function to get all built-in component factories
Map<String, ComponentFactory> getBuiltInComponents() {
  return {
    'Image': GenericComponentFactory(
        'Image', (props) => ImageComponent(props: props)),
    'Video': GenericComponentFactory(
        'Video', (props) => VideoComponent(props: props)),
    'OptionSelector': GenericComponentFactory(
        'OptionSelector', (props) => OptionSelectorComponent(props: props)),
    'SelectedOption': GenericComponentFactory(
        'SelectedOption', (props) => SelectedOptionComponent(props: props)),
    'Loader': GenericComponentFactory(
        'Loader', (props) => LoaderComponent(props: props)),
    'PostBody': GenericComponentFactory(
        'PostBody', (props) => PostBodyComponent(props: props)),
    'Button': GenericComponentFactory(
        'Button', (props) => ButtonComponent(props: props)),
    'Card':
        GenericComponentFactory('Card', (props) => CardComponent(props: props)),
    'List':
        GenericComponentFactory('List', (props) => ListComponent(props: props)),
    'Progress': GenericComponentFactory(
        'Progress', (props) => ProgressComponent(props: props)),
    'Text':
        GenericComponentFactory('Text', (props) => TextComponent(props: props)),
    'Fallback': GenericComponentFactory(
        'Fallback', (props) => FallbackComponent(props: props)),
  };
}

/// Helper function to create a default component theme
ComponentStyle createDefaultTheme({
  Color? primaryColor,
  Color? backgroundColor,
  Color? textColor,
  double? fontSize,
}) {
  return ComponentStyle(
    backgroundColor: backgroundColor ?? Colors.white,
    textColor: textColor ?? Colors.black87,
    fontSize: fontSize ?? 14.0,
    padding: 16.0,
    margin: 8.0,
  );
}

/// Helper function to create error-safe component props
ComponentProps createSafeProps({
  required String content,
  Map<String, String>? attributes,
  bool isComplete = true,
  ComponentCallback? onInteraction,
  BuildContext? context,
  ComponentStyle? style,
}) {
  return ComponentProps(
    content: content,
    attributes: attributes ?? {},
    isComplete: isComplete,
    onInteraction: onInteraction,
    context: context,
    style: style,
  );
}
