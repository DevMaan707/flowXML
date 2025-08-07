import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/component_base.dart';

/// Image component for displaying images from URLs
class ImageComponent extends XmlComponent {
  const ImageComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'Image';

  @override
  Set<String> get requiredAttributes => {'src'};

  @override
  Map<String, String> get defaultAttributes => {
        'width': '200',
        'height': '200',
        'fit': 'cover',
        'placeholder': 'true',
      };

  @override
  Widget build(BuildContext context) {
    if (!validate()) {
      return _buildErrorWidget('Image URL is required');
    }

    final imageUrl = props.getAttribute('src', props.content.trim());
    final width = props.getIntAttribute('width', 200).toDouble();
    final height = props.getIntAttribute('height', 200).toDouble();
    final fit = _getBoxFit(props.getAttribute('fit', 'cover'));
    final showPlaceholder = props.getBoolAttribute('placeholder', true);

    if (imageUrl.isEmpty) {
      return _buildErrorWidget('No image URL provided');
    }

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: SizedBox(
          width: width,
          height: height,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            placeholder:
                showPlaceholder ? (context, url) => _buildPlaceholder() : null,
            errorWidget: (context, url, error) =>
                _buildErrorWidget('Failed to load image'),
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }

  BoxFit _getBoxFit(String fitString) {
    switch (fitString.toLowerCase()) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitwidth':
        return BoxFit.fitWidth;
      case 'fitheight':
        return BoxFit.fitHeight;
      case 'scaledown':
        return BoxFit.scaleDown;
      case 'cover':
      default:
        return BoxFit.cover;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.red[700], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
