import 'dart:developer' as developer;

/// Utility functions for XML processing
class XmlUtils {
  static const String _logTag = 'XmlUtils';

  /// XML entity mappings
  static const Map<String, String> _xmlEntities = {
    '&lt;': '<',
    '&gt;': '>',
    '&amp;': '&',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
  };

  /// Decode XML entities in text content
  String decodeXmlEntities(String text) {
    if (text.isEmpty) return text;

    String result = text;
    for (final entry in _xmlEntities.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    // Handle numeric entities
    result = result.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (match) {
        try {
          final code = int.parse(match.group(1)!);
          return String.fromCharCode(code);
        } catch (e) {
          developer.log('Failed to decode numeric entity: ${match.group(0)}',
              name: _logTag);
          return match.group(0)!;
        }
      },
    );

    // Handle hex entities
    result = result.replaceAllMapped(
      RegExp(r'&#x([0-9a-fA-F]+);'),
      (match) {
        try {
          final code = int.parse(match.group(1)!, radix: 16);
          return String.fromCharCode(code);
        } catch (e) {
          developer.log('Failed to decode hex entity: ${match.group(0)}',
              name: _logTag);
          return match.group(0)!;
        }
      },
    );

    return result;
  }

  /// Parse XML attributes from attribute string
  Map<String, String> parseAttributes(String attributeString) {
    final attributes = <String, String>{};

    if (attributeString.trim().isEmpty) {
      return attributes;
    }

    // Simple approach: handle double quotes first, then single quotes
    final doubleQuoteRegex = RegExp(r'(\w+)\s*=\s*"([^"]*)"');
    final singleQuoteRegex = RegExp(r"(\w+)\s*=\s*'([^']*)'");

    // Process double-quoted attributes
    for (final match in doubleQuoteRegex.allMatches(attributeString)) {
      final name = match.group(1)!;
      final value = match.group(2)!;
      attributes[name] = decodeXmlEntities(value);
    }

    // Process single-quoted attributes
    for (final match in singleQuoteRegex.allMatches(attributeString)) {
      final name = match.group(1)!;
      if (!attributes.containsKey(name)) {
        final value = match.group(2)!;
        attributes[name] = decodeXmlEntities(value);
      }
    }

    // Handle attributes without quotes (less common but valid)
    final unquotedRegex = RegExp(r'(\w+)\s*=\s*([^\s>]+)');
    for (final match in unquotedRegex.allMatches(attributeString)) {
      final name = match.group(1)!;
      if (!attributes.containsKey(name)) {
        final value = match.group(2)!;
        attributes[name] = decodeXmlEntities(value);
      }
    }

    return attributes;
  }

  /// Strip XML tags from content for fallback display
  String stripXmlTags(String content) {
    return content.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// Sanitize content for display
  String sanitizeContent(String content) {
    if (content.isEmpty) return content;

    return content
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove remaining XML tags
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Validate XML tag name
  bool isValidTagName(String tagName) {
    if (tagName.isEmpty) return false;

    // XML tag names must start with letter or underscore
    // and contain only letters, digits, hyphens, periods, and underscores
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_.-]*$').hasMatch(tagName);
  }

  /// Extract root element from XML content
  String? extractRootElement(String xmlContent) {
    final rootRegex = RegExp(r'<\s*([a-zA-Z][a-zA-Z0-9]*)\s*[^>]*>');
    final match = rootRegex.firstMatch(xmlContent);
    return match?.group(1);
  }

  /// Check if content contains valid XML structure
  bool hasValidXmlStructure(String content) {
    if (content.trim().isEmpty) return false;

    // Basic check for matching angle brackets
    final openBrackets = '<'.allMatches(content).length;
    final closeBrackets = '>'.allMatches(content).length;

    return openBrackets > 0 && openBrackets == closeBrackets;
  }

  /// Escape text for XML attributes
  String escapeAttributeValue(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Clean up malformed XML as much as possible
  String cleanupMalformedXml(String xmlContent) {
    String cleaned = xmlContent;

    // Fix unclosed tags at the end
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'<([a-zA-Z][a-zA-Z0-9]*)\s*[^/>]*(?<!/)>(?![^<]*</\1>)$'),
      (match) => '${match.group(0)}</${match.group(1)}>',
    );

    return cleaned;
  }
}
