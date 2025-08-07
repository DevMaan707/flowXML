import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/component_base.dart';

/// Text component for rendering text content with markdown support
class TextComponent extends XmlComponent {
  const TextComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'Text';

  @override
  Map<String, String> get defaultAttributes => {
        'markdown': 'true',
        'selectable': 'false',
        'style': 'body',
      };

  @override
  Widget build(BuildContext context) {
    final content = props.content;
    final useMarkdown = props.getBoolAttribute('markdown', true);
    final isSelectable = props.getBoolAttribute('selectable', false);
    final textStyle = props.getAttribute('style', 'body');

    if (content.isEmpty && props.isComplete) {
      return const SizedBox.shrink();
    }

    final style = _getTextStyle(context, textStyle);

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (useMarkdown)
            MarkdownBody(
              data: content,
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: style,
                h1: style.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                h2: style.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                h3: style.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              selectable: isSelectable,
            )
          else
            isSelectable
                ? SelectableText(content, style: style)
                : Text(content, style: style),
          if (!props.isComplete) _buildStreamingIndicator(context),
        ],
      ),
    );
  }

  TextStyle _getTextStyle(BuildContext context, String styleName) {
    final theme = Theme.of(context);

    switch (styleName.toLowerCase()) {
      case 'headline':
        return theme.textTheme.headlineMedium!;
      case 'title':
        return theme.textTheme.titleLarge!;
      case 'subtitle':
        return theme.textTheme.titleMedium!;
      case 'caption':
        return theme.textTheme.bodySmall!;
      case 'body':
      default:
        return theme.textTheme.bodyMedium!;
    }
  }

  Widget _buildStreamingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
