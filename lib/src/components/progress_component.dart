import 'package:flutter/material.dart';
import '../core/component_base.dart';
import '../models/component_props.dart';

/// Progress component for showing completion status
class ProgressComponent extends XmlComponent {
  const ProgressComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'Progress';

  @override
  Map<String, String> get defaultAttributes => {
        'type': 'linear',
        'value': '0',
        'max': '100',
        'showLabel': 'true',
        'color': 'primary',
      };

  @override
  Widget build(BuildContext context) {
    final type = props.getAttribute('type', 'linear');
    final value = props.getIntAttribute('value', 0);
    final max = props.getIntAttribute('max', 100);
    final showLabel = props.getBoolAttribute('showLabel', true);
    final colorName = props.getAttribute('color', 'primary');
    final label = props.content.trim();

    final progress = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    final color = _getColor(context, colorName);

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel && label.isNotEmpty) ...[
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          _buildProgress(context, type, progress, color),
          if (showLabel) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '$value / $max',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgress(
      BuildContext context, String type, double progress, Color color) {
    switch (type.toLowerCase()) {
      case 'circular':
        return Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: color.withOpacity(0.2),
              strokeWidth: 4,
            ),
          ),
        );
      case 'linear':
      default:
        return LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: color.withOpacity(0.2),
          minHeight: 6,
        );
    }
  }

  Color _getColor(BuildContext context, String colorName) {
    switch (colorName.toLowerCase()) {
      case 'primary':
        return Theme.of(context).colorScheme.primary;
      case 'secondary':
        return Theme.of(context).colorScheme.secondary;
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
