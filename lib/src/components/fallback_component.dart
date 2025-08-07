import 'package:flutter/material.dart';
import '../core/component_base.dart';
import '../models/component_props.dart';

/// Fallback component for unknown or invalid component types
class FallbackComponent extends XmlComponent {
  const FallbackComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'Fallback';

  @override
  Widget build(BuildContext context) {
    final componentType = props.getAttribute('originalType', 'Unknown');
    final content = props.content;

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[200]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Unknown component: $componentType',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
