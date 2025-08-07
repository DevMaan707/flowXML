import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../models/component_props.dart';

/// Abstract base class for all XML components
@immutable
abstract class XmlComponent extends StatelessWidget {
  /// Component properties
  final ComponentProps props;

  const XmlComponent({
    super.key,
    required this.props,
  });

  /// Build the component widget
  @override
  Widget build(BuildContext context);

  /// Component type name (must be unique)
  String get componentType;

  /// Whether this component supports streaming content
  bool get supportsStreaming => true;

  /// Whether this component can have child components
  bool get supportsChildren => false;

  /// Default attributes for this component
  Map<String, String> get defaultAttributes => const {};

  /// Required attributes for this component
  Set<String> get requiredAttributes => const {};

  /// Validate component properties
  bool validate() {
    // Check required attributes
    for (final required in requiredAttributes) {
      if (!props.hasAttribute(required)) {
        return false;
      }
    }
    return true;
  }

  /// Handle component interaction
  void onInteraction(String action, Map<String, dynamic> data) {
    props.onInteraction?.call(action, data);
  }

  /// Get merged attributes (default + provided)
  Map<String, String> get mergedAttributes {
    final merged = Map<String, String>.from(defaultAttributes);
    merged.addAll(props.attributes);
    return merged;
  }
}

/// Factory interface for creating components
abstract class ComponentFactory {
  /// Create component instance
  XmlComponent create(ComponentProps props);

  /// Component type this factory creates
  String get componentType;

  /// Whether this factory supports the given type
  bool supports(String type) => type == componentType;
}

/// Generic component factory implementation
class GenericComponentFactory<T extends XmlComponent>
    implements ComponentFactory {
  final String _componentType;
  final T Function(ComponentProps props) _creator;

  const GenericComponentFactory(this._componentType, this._creator);

  @override
  XmlComponent create(ComponentProps props) => _creator(props);

  @override
  String get componentType => _componentType;

  @override
  bool supports(String type) => type == _componentType;
}

/// Mixin for components that handle user interactions
mixin InteractiveComponent on XmlComponent {
  /// Handle tap/click interactions
  void onTap() {
    onInteraction('tap', {'timestamp': DateTime.now().toIso8601String()});
  }

  /// Handle selection interactions
  void onSelect(String value) {
    onInteraction('select',
        {'value': value, 'timestamp': DateTime.now().toIso8601String()});
  }

  /// Handle input changes
  void onInputChange(String value) {
    onInteraction('input_change',
        {'value': value, 'timestamp': DateTime.now().toIso8601String()});
  }
}
