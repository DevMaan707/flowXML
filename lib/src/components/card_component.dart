import 'package:flutter/material.dart';
import '../core/component_base.dart';

/// Card component for grouped content display
class CardComponent extends XmlComponent {
  const CardComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'Card';

  @override
  Map<String, String> get defaultAttributes => {
        'elevation': '2',
        'padding': '16',
        'margin': '8',
        'borderRadius': '8',
      };

  @override
  Widget build(BuildContext context) {
    final elevation = props.getIntAttribute('elevation', 2).toDouble();
    final padding = props.getIntAttribute('padding', 16).toDouble();
    final margin = props.getIntAttribute('margin', 8).toDouble();
    final borderRadius = props.getIntAttribute('borderRadius', 8).toDouble();
    final title = props.getAttribute('title');
    final subtitle = props.getAttribute('subtitle');
    final content = props.content.trim();

    return Container(
      margin: EdgeInsets.all(margin),
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
              ],
              if (subtitle.isNotEmpty) ...[
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 12),
              ],
              if (content.isNotEmpty)
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (!props.isComplete) _buildLoadingIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
