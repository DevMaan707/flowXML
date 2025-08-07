import 'package:flutter/material.dart';
import '../core/component_base.dart';

/// Loader component for showing loading states
class LoaderComponent extends XmlComponent {
  const LoaderComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'Loader';

  @override
  Map<String, String> get defaultAttributes => {
        'type': 'circular',
        'size': 'medium',
        'color': 'primary',
      };

  @override
  Widget build(BuildContext context) {
    final type = props.getAttribute('type', 'circular');
    final size = props.getAttribute('size', 'medium');
    final color = props.getAttribute('color', 'primary');
    final message = props.content.trim();

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      padding: EdgeInsets.all(props.style?.padding ?? 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoader(context, type, size, color),
          if (message.isNotEmpty) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoader(
      BuildContext context, String type, String size, String color) {
    final loaderColor = _getColor(context, color);
    final loaderSize = _getSize(size);

    switch (type.toLowerCase()) {
      case 'linear':
        return SizedBox(
          width: loaderSize * 2,
          height: 4,
          child: LinearProgressIndicator(
            color: loaderColor,
            backgroundColor: loaderColor.withOpacity(0.2),
          ),
        );
      case 'dots':
        return _buildDotsLoader(loaderColor, loaderSize);
      case 'circular':
      default:
        return SizedBox(
          width: loaderSize,
          height: loaderSize,
          child: CircularProgressIndicator(
            color: loaderColor,
            strokeWidth: loaderSize / 8,
          ),
        );
    }
  }

  Widget _buildDotsLoader(Color color, double size) {
    return SizedBox(
      width: size * 2,
      height: size / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500 + (index * 200)),
            width: size / 6,
            height: size / 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  Color _getColor(BuildContext context, String colorName) {
    switch (colorName.toLowerCase()) {
      case 'primary':
        return Theme.of(context).colorScheme.primary;
      case 'secondary':
        return Theme.of(context).colorScheme.secondary;
      case 'error':
        return Theme.of(context).colorScheme.error;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  double _getSize(String sizeName) {
    switch (sizeName.toLowerCase()) {
      case 'small':
        return 16.0;
      case 'large':
        return 32.0;
      case 'medium':
      default:
        return 24.0;
    }
  }
}
