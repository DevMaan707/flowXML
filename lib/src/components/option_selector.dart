import 'package:flutter/material.dart';
import '../core/component_base.dart';
import '../models/component_props.dart';

/// Option selector component for interactive choice selection
class OptionSelectorComponent extends XmlComponent with InteractiveComponent {
  const OptionSelectorComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'OptionSelector';

  @override
  Set<String> get requiredAttributes => {'options'};

  @override
  Map<String, String> get defaultAttributes => {
        'title': 'Select an option',
        'multiSelect': 'false',
        'layout': 'horizontal',
        'style': 'pills',
      };

  @override
  Widget build(BuildContext context) {
    if (!validate()) {
      return _buildErrorWidget('Options are required');
    }

    final optionsString = props.getAttribute('options');
    final title = props.getAttribute('title', 'Select an option');
    final multiSelect = props.getBoolAttribute('multiSelect', false);
    final layout = props.getAttribute('layout', 'horizontal');
    final style = props.getAttribute('style', 'pills');

    final options = optionsString
        .split(',')
        .map((option) => option.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    if (options.isEmpty) {
      return _buildErrorWidget('No valid options provided');
    }

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      padding: EdgeInsets.all(props.style?.padding ?? 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (props.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              props.content,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildOptionsWidget(context, options, layout, style, multiSelect),
          if (!props.isComplete) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildOptionsWidget(
    BuildContext context,
    List<String> options,
    String layout,
    String style,
    bool multiSelect,
  ) {
    if (layout == 'vertical') {
      return Column(
        children: options
            .map((option) =>
                _buildOptionButton(context, option, style, multiSelect))
            .toList(),
      );
    } else {
      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: options
            .map((option) =>
                _buildOptionButton(context, option, style, multiSelect))
            .toList(),
      );
    }
  }

  Widget _buildOptionButton(
    BuildContext context,
    String option,
    String style,
    bool multiSelect,
  ) {
    return _OptionButton(
      option: option,
      style: style,
      multiSelect: multiSelect,
      onTap: (selectedOption) {
        onSelect(selectedOption);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            'Loading options...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatefulWidget {
  final String option;
  final String style;
  final bool multiSelect;
  final Function(String) onTap;

  const _OptionButton({
    required this.option,
    required this.style,
    required this.multiSelect,
    required this.onTap,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.multiSelect) {
            _isSelected = !_isSelected;
          } else {
            _isSelected = true;
          }
        });
        widget.onTap(widget.option);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: _isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(
            widget.style == 'rounded' ? 20.0 : 8.0,
          ),
        ),
        child: Text(
          widget.option,
          style: TextStyle(
            color: _isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: _isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
