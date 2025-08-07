import 'package:flutter/material.dart';
import '../core/component_base.dart';
import '../models/component_props.dart';

/// List component for displaying structured data
class ListComponent extends XmlComponent {
  const ListComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'List';

  @override
  Map<String, String> get defaultAttributes => {
        'type': 'unordered',
        'separator': ',',
        'numbered': 'false',
      };

  @override
  Widget build(BuildContext context) {
    final listType = props.getAttribute('type', 'unordered');
    final separator = props.getAttribute('separator', ',');
    final numbered = props.getBoolAttribute('numbered', false);
    final content = props.content.trim();

    if (content.isEmpty && props.isComplete) {
      return const SizedBox.shrink();
    }

    final items = content
        .split(separator)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildListItem(context, item, index, listType, numbered);
          }),
          if (!props.isComplete) _buildLoadingIndicator(context),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    String item,
    int index,
    String listType,
    bool numbered,
  ) {
    Widget leading;

    if (numbered || listType == 'ordered') {
      leading = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    } else {
      leading = Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 12.0),
            child: leading,
          ),
          Expanded(
            child: Text(
              item,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          const SizedBox(width: 12),
          Text(
            'Loading items...',
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
