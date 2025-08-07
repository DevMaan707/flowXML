import 'dart:developer' as developer;

import '../models/parsed_component.dart';
import '../models/xml_parser_state.dart';
import '../utils/xml_utils.dart';

/// High-performance streaming XML parser for real-time component rendering
class StreamingXmlParser {
  static const String _logTag = 'StreamingXmlParser';

  /// Special components that receive custom rendering
  static const Set<String> _specialComponents = {
    'Image',
    'Video',
    'OptionSelector',
    'SelectedOption',
    'Loader',
    'PostBody',
    'Button',
    'Card',
    'List',
    'Progress',
  };

  XmlParserState _state;
  final XmlUtils _xmlUtils;

  /// Create a new streaming XML parser
  StreamingXmlParser()
      : _state = const XmlParserState(),
        _xmlUtils = XmlUtils();

  /// Add a chunk of XML content for incremental parsing
  /// Returns updated list of parsed components
  List<ParsedComponent> addChunk(String chunk) {
    try {
      developer.log(
          'Adding chunk: ${chunk.substring(0, chunk.length > 100 ? 100 : chunk.length)}...',
          name: _logTag);

      _state = _state.copyWith(buffer: _state.buffer + chunk);
      _processBuffer();
      return getCurrentComponents();
    } catch (e, stackTrace) {
      developer.log('Error processing chunk: $e',
          name: _logTag, error: e, stackTrace: stackTrace);
      return _handleParsingError(e.toString());
    }
  }

  /// Finalize parsing and return all completed components
  List<ParsedComponent> finalize() {
    try {
      developer.log('Finalizing parser', name: _logTag);

      // Process any remaining buffer content
      if (_state.buffer.trim().isNotEmpty) {
        _processRemainingBuffer();
      }

      // Complete current component if exists
      if (_state.currentComponent != null) {
        final completedComponent =
            _state.currentComponent!.copyWith(isComplete: true);
        _state = _state.copyWith(
          components: [..._state.components, completedComponent],
          currentComponent: null,
        );
      }

      return _sanitizeComponents(_state.components);
    } catch (e, stackTrace) {
      developer.log('Error finalizing: $e',
          name: _logTag, error: e, stackTrace: stackTrace);
      return _state.components;
    }
  }

  /// Reset parser state for new content
  void reset() {
    developer.log('Resetting parser state', name: _logTag);
    _state = const XmlParserState();
  }

  /// Get current parsed components without finalizing
  List<ParsedComponent> getCurrentComponents() {
    final result = List<ParsedComponent>.from(_state.components);

    if (_state.currentComponent != null) {
      result.add(_state.currentComponent!);
    }

    return result;
  }

  /// Process the current buffer for complete tags and text
  void _processBuffer() {
    int lastProcessedIndex = 0;

    // Enhanced regex to match opening, closing, and self-closing tags
    final tagRegex =
        RegExp(r'<\s*(/?)([a-zA-Z][a-zA-Z0-9]*)\s*([^>]*?)\s*(/?)>');

    for (final match in tagRegex.allMatches(_state.buffer)) {
      // Process any text before this tag
      final textBefore =
          _state.buffer.substring(lastProcessedIndex, match.start);
      if (textBefore.trim().isNotEmpty) {
        _processTextContent(textBefore);
      }

      final isClosing = match.group(1) == '/';
      final tagName = match.group(2)!;
      final attributeString = match.group(3) ?? '';
      final isSelfClosing = match.group(4) == '/';

      if (isClosing) {
        _processClosingTag(tagName);
      } else {
        _processOpeningTag(tagName, attributeString, isSelfClosing);
      }

      lastProcessedIndex = match.end;
    }

    // Handle remaining text
    final remainingText = _state.buffer.substring(lastProcessedIndex);
    if (remainingText.isNotEmpty && !remainingText.contains('<')) {
      _processTextContent(remainingText);
      _state = _state.copyWith(buffer: '');
    } else {
      _state = _state.copyWith(buffer: remainingText);
    }
  }

  /// Process opening XML tags
  void _processOpeningTag(
      String tagName, String attributeString, bool isSelfClosing) {
    developer.log('Processing opening tag: $tagName', name: _logTag);

    switch (tagName.toLowerCase()) {
      case 'chatresponse':
      case 'userresponse':
        _state = _state.copyWith(isInsideChatResponse: true);
        break;

      case 'message':
      case 'usermessage':
        _state = _state.copyWith(isInsideMessage: true);
        break;

      default:
        if (_state.isInsideChatResponse &&
            _specialComponents.contains(tagName)) {
          _processSpecialComponent(tagName, attributeString, isSelfClosing);
        }
        break;
    }
  }

  /// Process closing XML tags
  void _processClosingTag(String tagName) {
    developer.log('Processing closing tag: $tagName', name: _logTag);

    switch (tagName.toLowerCase()) {
      case 'message':
      case 'usermessage':
        _state = _state.copyWith(isInsideMessage: false);
        _completeCurrentComponent();
        break;

      case 'chatresponse':
      case 'userresponse':
        _state = _state.copyWith(isInsideChatResponse: false);
        _completeCurrentComponent();
        break;

      default:
        if (_specialComponents.contains(tagName) &&
            _state.currentComponent != null) {
          _completeCurrentComponent();

          // Pop from component stack
          if (_state.componentStack.isNotEmpty) {
            final newStack =
                List<ComponentStackEntry>.from(_state.componentStack)
                  ..removeLast();
            _state = _state.copyWith(componentStack: newStack);
          }
        }
        break;
    }
  }

  /// Process special component tags
  void _processSpecialComponent(
      String tagName, String attributeString, bool isSelfClosing) {
    // Complete current text component if exists
    if (_state.currentComponent?.type == ComponentType.text) {
      _completeCurrentComponent();
    }

    final attributes = _xmlUtils.parseAttributes(attributeString);
    final componentId = _generateComponentId();

    final component = ParsedComponent(
      type: ComponentType.component,
      componentType: tagName,
      content: '',
      attributes: attributes,
      isComplete: isSelfClosing,
      id: componentId,
    );

    if (isSelfClosing) {
      _state = _state.copyWith(
        components: [..._state.components, component],
      );
    } else {
      _state = _state.copyWith(
        currentComponent: component,
        componentStack: [
          ..._state.componentStack,
          ComponentStackEntry(tag: tagName, attributes: attributes)
        ],
      );
    }
  }

  /// Process text content
  void _processTextContent(String text) {
    if (text.trim().isEmpty) return;

    final decodedText = _xmlUtils.decodeXmlEntities(text);

    if (_state.currentComponent?.type == ComponentType.component) {
      // Add text to current component
      final updatedComponent = _state.currentComponent!.copyWith(
        content: _state.currentComponent!.content + decodedText,
      );
      _state = _state.copyWith(currentComponent: updatedComponent);
    } else if (_state.isInsideMessage) {
      // Handle regular text inside Message tags
      if (_state.currentComponent?.type == ComponentType.text) {
        final updatedComponent = _state.currentComponent!.copyWith(
          content: _state.currentComponent!.content + decodedText,
        );
        _state = _state.copyWith(currentComponent: updatedComponent);
      } else {
        // Create new text component
        _state = _state.copyWith(
          currentComponent: ParsedComponent(
            type: ComponentType.text,
            content: decodedText,
            isComplete: false,
            id: _generateComponentId(),
          ),
        );
      }
    }
  }

  /// Complete the current component and add it to the list
  void _completeCurrentComponent() {
    if (_state.currentComponent != null) {
      final completedComponent =
          _state.currentComponent!.copyWith(isComplete: true);
      _state = _state.copyWith(
        components: [..._state.components, completedComponent],
        currentComponent: null,
      );
    }
  }

  /// Process any remaining buffer content when finalizing
  void _processRemainingBuffer() {
    if (_state.buffer.trim().isNotEmpty) {
      _processTextContent(_state.buffer);
      _state = _state.copyWith(buffer: '');
    }
  }

  /// Handle parsing errors gracefully
  List<ParsedComponent> _handleParsingError(String error) {
    developer.log('Handling parsing error: $error', name: _logTag);

    // Try to salvage readable content from buffer
    final sanitizedContent = _xmlUtils.stripXmlTags(_state.buffer);
    if (sanitizedContent.trim().isNotEmpty) {
      final fallbackComponent = ParsedComponent(
        type: ComponentType.text,
        content: sanitizedContent,
        isComplete: true,
        id: 'fallback-${DateTime.now().millisecondsSinceEpoch}',
      );

      return [..._state.components, fallbackComponent];
    }

    return _state.components;
  }

  /// Sanitize component content for display
  List<ParsedComponent> _sanitizeComponents(List<ParsedComponent> components) {
    return components.map((component) {
      if (component.isComplete && component.content.isNotEmpty) {
        return component.copyWith(
          content: _xmlUtils.sanitizeContent(component.content),
        );
      }
      return component;
    }).toList();
  }

  /// Generate unique component ID
  String _generateComponentId() {
    return 'component-${DateTime.now().millisecondsSinceEpoch}-${_generateRandomId()}';
  }

  /// Generate random component suffix
  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString() +
        chars[random % chars.length] +
        chars[(random ~/ 10) % chars.length];
  }

  /// Check if parser is in a valid state
  bool get isValid {
    return _state.componentStack.isEmpty || _state.isInsideChatResponse;
  }

  /// Get current parser statistics
  Map<String, dynamic> get statistics {
    return {
      'totalComponents': _state.components.length,
      'bufferSize': _state.buffer.length,
      'isInsideMessage': _state.isInsideMessage,
      'isInsideChatResponse': _state.isInsideChatResponse,
      'stackDepth': _state.componentStack.length,
      'hasCurrentComponent': _state.currentComponent != null,
    };
  }
}
