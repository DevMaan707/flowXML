import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/component_base.dart';
import '../models/component_props.dart';

/// Video component for displaying videos from URLs
class VideoComponent extends XmlComponent {
  const VideoComponent({
    super.key,
    required super.props,
  });

  @override
  String get componentType => 'Video';

  @override
  Set<String> get requiredAttributes => {'src'};

  @override
  Map<String, String> get defaultAttributes => {
        'width': '300',
        'height': '200',
        'controls': 'true',
        'autoplay': 'false',
      };

  @override
  Widget build(BuildContext context) {
    if (!validate()) {
      return _buildErrorWidget('Video URL is required');
    }

    final videoUrl = props.getAttribute('src', props.content.trim());
    final width = props.getIntAttribute('width', 300).toDouble();
    final height = props.getIntAttribute('height', 200).toDouble();
    final showControls = props.getBoolAttribute('controls', true);
    final autoplay = props.getBoolAttribute('autoplay', false);

    if (videoUrl.isEmpty) {
      return _buildErrorWidget('No video URL provided');
    }

    return Container(
      margin: EdgeInsets.all(props.style?.margin ?? 8.0),
      child: SizedBox(
        width: width,
        height: height,
        child: _VideoPlayerWidget(
          videoUrl: videoUrl,
          showControls: showControls,
          autoplay: autoplay,
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
          Icon(Icons.video_library_outlined, color: Colors.red[400], size: 32),
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

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool showControls;
  final bool autoplay;

  const _VideoPlayerWidget({
    required this.videoUrl,
    required this.showControls,
    required this.autoplay,
  });

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();

      if (widget.autoplay && mounted) {
        await _controller.play();
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load video: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[200]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            _error!,
            style: TextStyle(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: widget.showControls
          ? VideoPlayer(_controller)
          : AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
    );
  }
}
