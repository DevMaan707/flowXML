import 'dart:developer' as developer;

import '../models/component_props.dart';
import 'component_base.dart';
import '../components/built_in_components.dart';

/// Registry for managing XML component types and their factories
class ComponentRegistry {
  static const String _logTag = 'ComponentRegistry';

  final Map<String, ComponentFactory> _factories = {};
  final Map<String, String> _aliases = {};

  static ComponentRegistry? _instance;

  /// Get singleton instance
  static ComponentRegistry get instance {
    _instance ??= ComponentRegistry._internal();
    return _instance!;
  }

  ComponentRegistry._internal() {
    _registerBuiltInComponents();
  }

  /// Register a component factory
  void register(ComponentFactory factory) {
    final type = factory.componentType;

    if (_factories.containsKey(type)) {
      developer.log('Overriding existing component: $type', name: _logTag);
    }

    _factories[type] = factory;
    developer.log('Registered component: $type', name: _logTag);
  }

  /// Register a component with a simple creator function
  void registerComponent<T extends XmlComponent>(
    String type,
    T Function(ComponentProps props) creator,
  ) {
    register(GenericComponentFactory<T>(type, creator));
  }

  /// Register an alias for a component type
  void registerAlias(String alias, String actualType) {
    if (!_factories.containsKey(actualType)) {
      throw ArgumentError(
          'Cannot create alias for unregistered type: $actualType');
    }

    _aliases[alias] = actualType;
    developer.log('Registered alias: $alias -> $actualType', name: _logTag);
  }

  /// Unregister a component type
  void unregister(String type) {
    _factories.remove(type);

    // Remove related aliases
    final aliasesToRemove = <String>[];
    for (final entry in _aliases.entries) {
      if (entry.value == type) {
        aliasesToRemove.add(entry.key);
      }
    }

    for (final alias in aliasesToRemove) {
      _aliases.remove(alias);
    }

    developer.log('Unregistered component: $type', name: _logTag);
  }

  /// Create a component instance
  XmlComponent? createComponent(String type, ComponentProps props) {
    // Resolve alias if exists
    final actualType = _aliases[type] ?? type;

    final factory = _factories[actualType];
    if (factory == null) {
      developer.log('Unknown component type: $type', name: _logTag);
      return null;
    }

    try {
      return factory.create(props);
    } catch (e, stackTrace) {
      developer.log('Error creating component $type: $e',
          name: _logTag, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Check if a component type is registered
  bool isRegistered(String type) {
    final actualType = _aliases[type] ?? type;
    return _factories.containsKey(actualType);
  }

  /// Get all registered component types
  List<String> get registeredTypes {
    final types = <String>[..._factories.keys, ..._aliases.keys];
    types.sort();
    return types;
  }

  /// Get component factory for a type
  ComponentFactory? getFactory(String type) {
    final actualType = _aliases[type] ?? type;
    return _factories[actualType];
  }

  /// Clear all registered components
  void clear() {
    _factories.clear();
    _aliases.clear();
    developer.log('Cleared all components', name: _logTag);
  }

  /// Reset to default built-in components only
  void resetToDefaults() {
    clear();
    _registerBuiltInComponents();
    developer.log('Reset to default components', name: _logTag);
  }

  /// Register all built-in components
  void _registerBuiltInComponents() {
    developer.log('Registering built-in components', name: _logTag);

    // Register default built-in components
    registerComponent('Image', (props) => ImageComponent(props: props));
    registerComponent('Video', (props) => VideoComponent(props: props));
    registerComponent(
        'OptionSelector', (props) => OptionSelectorComponent(props: props));
    registerComponent(
        'SelectedOption', (props) => SelectedOptionComponent(props: props));
    registerComponent('Loader', (props) => LoaderComponent(props: props));
    registerComponent('PostBody', (props) => PostBodyComponent(props: props));
    registerComponent('Button', (props) => ButtonComponent(props: props));
    registerComponent('Card', (props) => CardComponent(props: props));
    registerComponent('List', (props) => ListComponent(props: props));
    registerComponent('Progress', (props) => ProgressComponent(props: props));

    // Register common aliases
    registerAlias('Img', 'Image');
    registerAlias('Vid', 'Video');
    registerAlias('Options', 'OptionSelector');
    registerAlias('Loading', 'Loader');
    registerAlias('Spinner', 'Loader');
    registerAlias('Post', 'PostBody');
    registerAlias('Content', 'PostBody');
    registerAlias('Btn', 'Button');
    registerAlias('Panel', 'Card');
    registerAlias('ProgressBar', 'Progress');
  }

  /// Get registry statistics
  Map<String, dynamic> get statistics {
    return {
      'totalComponents': _factories.length,
      'totalAliases': _aliases.length,
      'registeredTypes': registeredTypes,
    };
  }
}
