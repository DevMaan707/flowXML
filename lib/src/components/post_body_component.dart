import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/component_base.dart';

/// Post body component for displaying generated content with copy functionality
class PostBodyComponent extends XmlComponent with InteractiveComponent {
  const PostBodyComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'PostBody';

  @override
  Map<String, String> get defaultAttributes => {
        'copyable': 'true',
        'showHeader': 'true',
        'headerText': 'Generated Content',
      };

  @override
  Widget build(BuildContext context) {
    final copyable = props.getBoolAttribute('copyable', true);
    final showHeader = props.getBoolAttribute('showHeader', true);
    final headerText = props.getAttribute('headerText', 'Generated Content');
    final content = props.content;

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    headerText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (copyable && content.isNotEmpty)
                    _CopyButton(
                      content: content,
                      onCopy: () => onInteraction('copy', {'content': content}),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (content.isNotEmpty)
                  SelectableText(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                if (!props.isComplete) _buildGeneratingIndicator(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingIndicator(BuildContext context) {
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
            'Generating...',
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

class _CopyButton extends StatefulWidget {
  final String content;
  final VoidCallback onCopy;

  const _CopyButton({
    required this.content,
    required this.onCopy,
  });

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _copied ? null : _copyToClipboard,
      icon: Icon(
        _copied ? Icons.check : Icons.copy,
        size: 18,
        color: _copied ? Colors.green : Theme.of(context).colorScheme.primary,
      ),
      tooltip: _copied ? 'Copied!' : 'Copy to clipboard',
    );
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.content));
    widget.onCopy();

    setState(() {
      _copied = true;
    });

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }
}
