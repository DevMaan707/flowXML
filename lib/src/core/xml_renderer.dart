import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'dart:developer' as developer;

import '../models/parsed_component.dart';
import '../models/component_props.dart';
import 'xml_parser.dart';
import 'component_registry.dart';
import '../components/text_component.dart';
import '../components/fallback_component.dart';

/// Main widget for rendering streaming XML content into Flutter components
class XmlRenderer extends StatefulWidget {
  /// XML content to render
  final String xmlContent;

  /// Whether content is still streaming
  final bool isStreaming;

  /// Callback when components are updated
  final void Function(List<ParsedComponent>)? onComponentsUpdate;

  /// Callback for component interactions
  final ComponentCallback? onComponentInteraction;

  /// Custom component registry (optional)
  final ComponentRegistry? registry;

  /// Custom styling
  final ComponentStyle? style;

  /// Error fallback widget builder
  final Widget Function(String error)? errorBuilder;

  /// Loading widget builder
  final Widget Function()? loadingBuilder;

  const XmlRenderer({
    super.key,
    required this.xmlContent,
    this.isStreaming = false,
    this.onComponentsUpdate,
    this.onComponentInteraction,
    this.registry,
    this.style,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<XmlRenderer> createState() => _XmlRendererState();
}

class _XmlRendererState extends State<XmlRenderer> {
  static const String _logTag = 'XmlRenderer';

  late StreamingXmlParser _parser;
  late ComponentRegistry _registry;

  final BehaviorSubject<List<ParsedComponent>> _componentsSubject =
      BehaviorSubject<List<ParsedComponent>>.seeded([]);

  String _lastProcessedContent = '';
  StreamSubscription? _componentsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
    _setupComponentsListener();
  }

  @override
  void didUpdateWidget(XmlRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.xmlContent != oldWidget.xmlContent ||
        widget.isStreaming != oldWidget.isStreaming) {
      _processXmlContent();
    }

    if (widget.registry != oldWidget.registry) {
      _registry = widget.registry ?? ComponentRegistry.instance;
    }
  }

  @override
  void dispose() {
    _componentsSubscription?.cancel();
    _componentsSubject.close();
    super.dispose();
  }

  void _initializeRenderer() {
    _parser = StreamingXmlParser();
    _registry = widget.registry ?? ComponentRegistry.instance;

    developer.log('Initialized XML renderer', name: _logTag);

    if (widget.xmlContent.isNotEmpty) {
      _processXmlContent();
    }
  }

  void _setupComponentsListener() {
    _componentsSubscription =
        _componentsSubject.stream.distinct().listen((components) {
      widget.onComponentsUpdate?.call(components);
    });
  }

  void _processXmlContent() {
    try {
      developer.log(
          'Processing XML content (${widget.xmlContent.length} chars)',
          name: _logTag);

      // Only process new content
      final newContent =
          widget.xmlContent.substring(_lastProcessedContent.length);

      if (newContent.isNotEmpty) {
        final components = _parser.addChunk(newContent);
        _componentsSubject.add(components);
        _lastProcessedContent = widget.xmlContent;
      }

      // Finalize if streaming is complete
      if (!widget.isStreaming) {
        final finalComponents = _parser.finalize();
        _componentsSubject.add(finalComponents);
        developer.log(
            'Finalized parsing with ${finalComponents.length} components',
            name: _logTag);
      }
    } catch (e, stackTrace) {
      developer.log('Error processing XML content: $e',
          name: _logTag, error: e, stackTrace: stackTrace);
      _handleError(e.toString());
    }
  }

  void _handleError(String error) {
    // Create fallback text component for error content
    final fallbackComponent = ParsedComponent(
      type: ComponentType.text,
      content: widget.xmlContent.isNotEmpty
          ? widget.xmlContent.replaceAll(RegExp(r'<[^>]*>'), '')
          : 'Error processing content',
      isComplete: true,
      id: 'error-fallback-${DateTime.now().millisecondsSinceEpoch}',
    );

    _componentsSubject.add([fallbackComponent]);
  }

  Widget _buildComponent(ParsedComponent component) {
    try {
      final props = ComponentProps(
        content: component.content,
        attributes: component.attributes,
        isComplete: component.isComplete,
        onInteraction: widget.onComponentInteraction,
        context: context,
        style: widget.style,
      );

      if (component.type == ComponentType.text) {
        return TextComponent(props: props);
      } else if (component.type == ComponentType.component &&
          component.componentType != null) {
        final xmlComponent =
            _registry.createComponent(component.componentType!, props);

        if (xmlComponent != null) {
          return xmlComponent;
        } else {
          // Create fallback component for unknown types
          final fallbackProps = ComponentProps(
            content: component.content,
            attributes: {
              ...component.attributes,
              'originalType': component.componentType ?? 'Unknown',
            },
            isComplete: component.isComplete,
            onInteraction: widget.onComponentInteraction,
            context: context,
            style: widget.style,
          );
          return FallbackComponent(props: fallbackProps);
        }
      }

      // Default fallback
      return TextComponent(props: props);
    } catch (e, stackTrace) {
      developer.log('Error building component: $e',
          name: _logTag, error: e, stackTrace: stackTrace);

      return Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[200]!),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          'Error rendering component: ${component.componentType ?? 'Unknown'}',
          style: TextStyle(color: Colors.red[700], fontSize: 12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ParsedComponent>>(
      stream: _componentsSubject.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(snapshot.error.toString()) ??
              _buildDefaultError(snapshot.error.toString());
        }

        final components = snapshot.data ?? [];

        if (components.isEmpty) {
          if (widget.isStreaming) {
            return widget.loadingBuilder?.call() ?? _buildDefaultLoading();
          } else if (widget.xmlContent.isEmpty) {
            return _buildEmptyState();
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...components.map((component) => _buildComponent(component)),
            if (widget.isStreaming && components.isNotEmpty)
              _buildStreamingIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildDefaultLoading() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Processing...',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDefaultError(String error) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 20),
              const SizedBox(width: 8),
              Text(
                'Rendering Error',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.red[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'No content available',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildStreamingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
          SizedBox(width: 8),
          Text(
            'Streaming...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
