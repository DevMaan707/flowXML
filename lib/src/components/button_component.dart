import 'package:flutter/material.dart';
import '../core/component_base.dart';

/// Button component for interactive actions
class ButtonComponent extends XmlComponent with InteractiveComponent {
  const ButtonComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'Button';

  @override
  Map<String, String> get defaultAttributes => {
        'variant': 'filled',
        'size': 'medium',
        'color': 'primary',
        'disabled': 'false',
      };

  @override
  Widget build(BuildContext context) {
    final variant = props.getAttribute('variant', 'filled');
    final size = props.getAttribute('size', 'medium');
    final colorName = props.getAttribute('color', 'primary');
    final isDisabled = props.getBoolAttribute('disabled', false);
    final text = props.content.trim();
    final action = props.getAttribute('action');

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      child: _buildButton(
          context, variant, size, colorName, isDisabled, text, action),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String variant,
    String size,
    String colorName,
    bool isDisabled,
    String text,
    String action,
  ) {
    final color = _getColor(context, colorName);
    final buttonSize = _getButtonSize(size);

    switch (variant.toLowerCase()) {
      case 'outlined':
        return OutlinedButton(
          onPressed: isDisabled ? null : () => _handlePress(action),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            minimumSize: buttonSize,
          ),
          child: Text(text),
        );
      case 'text':
        return TextButton(
          onPressed: isDisabled ? null : () => _handlePress(action),
          style: TextButton.styleFrom(
            foregroundColor: color,
            minimumSize: buttonSize,
          ),
          child: Text(text),
        );
      case 'filled':
      default:
        return ElevatedButton(
          onPressed: isDisabled ? null : () => _handlePress(action),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: _getContrastColor(color),
            minimumSize: buttonSize,
          ),
          child: Text(text),
        );
    }
  }

  void _handlePress(String action) {
    onTap();
    if (action.isNotEmpty) {
      onInteraction('button_press', {
        'action': action,
        'text': props.content.trim(),
      });
    }
  }

  Color _getColor(BuildContext context, String colorName) {
    switch (colorName.toLowerCase()) {
      case 'primary':
        return Theme.of(context).colorScheme.primary;
      case 'secondary':
        return Theme.of(context).colorScheme.secondary;
      case 'error':
        return Theme.of(context).colorScheme.error;
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Size _getButtonSize(String sizeName) {
    switch (sizeName.toLowerCase()) {
      case 'small':
        return const Size(64, 32);
      case 'large':
        return const Size(120, 48);
      case 'medium':
      default:
        return const Size(88, 40);
    }
  }
}
