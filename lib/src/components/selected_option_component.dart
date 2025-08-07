import 'package:flutter/material.dart';
import '../core/component_base.dart';

/// Selected option component for displaying user selections
class SelectedOptionComponent extends XmlComponent {
  const SelectedOptionComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'SelectedOption';

  @override
  Widget build(BuildContext context) {
    final content = props.content.trim();

    if (content.isEmpty && props.isComplete) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              content.isNotEmpty ? content : 'Processing...',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
