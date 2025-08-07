import 'package:flutter/material.dart';
import 'package:flowxml/flowxml.dart';
import 'dart:async';

void main() {
  runApp(const FlowXMLStreamingApp());
}

class FlowXMLStreamingApp extends StatelessWidget {
  const FlowXMLStreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowXML Streaming Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StreamingDemo(),
    );
  }
}

class StreamingDemo extends StatefulWidget {
  const StreamingDemo({super.key});

  @override
  State<StreamingDemo> createState() => _StreamingDemoState();
}

class _StreamingDemoState extends State<StreamingDemo> {
  late XmlStreamController _streamController;
  bool _isStreaming = false;
  int _chunksProcessed = 0;
  int _totalChunks = 0;
  String _currentXmlContent = '';

  @override
  void initState() {
    super.initState();
    _initializeStreamController();
  }

  void _initializeStreamController() {
    _streamController = XmlStreamController();

    // Listen to streaming status
    _streamController.isStreamingStream.listen((isStreaming) {
      setState(() {
        _isStreaming = isStreaming;
      });
    });

    // Listen to components and update XML content for direct rendering
    _streamController.componentsStream.listen((components) {
      print('Components received: ${components.length}');
      for (var component in components) {
        print('Component: ${component.type}, Content: ${component.content}');
      }
    });
  }

  @override
  void dispose() {
    _streamController.dispose();
    super.dispose();
  }

  List<String> _generateXmlChunks() {
    return [
      '<ChatResponse>',
      '<Message>🚀 Starting XML streaming simulation...</Message>',
      '<Card title="Sample Data" subtitle="Streaming content">',
      'This is a demonstration of real-time XML streaming. ',
      'Watch as components are created and rendered live!',
      '</Card>',
      '<Image src="https://picsum.photos/400/300?random=1" width="400" height="300">',
      'Sample streaming image</Image>',
      '<OptionSelector options="Option A,Option B,Option C" title="Choose one">',
      'Select your preferred option from the streaming content.',
      '</OptionSelector>',
      '<Progress type="linear" value="75" max="100" color="primary">',
      'Processing: 75% Complete',
      '</Progress>',
      '<List type="ordered">',
      'First streaming item,Second streaming item,Third streaming item',
      '</List>',
      '<Button variant="filled" color="primary" action="demo_action">',
      'Streaming Button',
      '</Button>',
      '<PostBody copyable="true" headerText="Generated Content">',
      '# Streaming Content Block\n\n',
      'This content was generated and streamed in real-time. ',
      'FlowXML converts the XML tags into interactive Flutter components ',
      'as the data arrives.\n\n',
      '## Features Demonstrated\n',
      '- Real-time XML parsing\n',
      '- Component rendering\n',
      '- Interactive elements\n',
      '- Rich text formatting',
      '</PostBody>',
      '<Video src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" width="400" height="300">',
      'Sample video component',
      '</Video>',
      '<Card title="✅ Streaming Complete" elevation="2">',
      'All XML content has been successfully streamed and converted to components!',
      '</Card>',
      '</ChatResponse>'
    ];
  }

  Future<void> _startStreaming() async {
    if (_isStreaming) return;

    setState(() {
      _chunksProcessed = 0;
      _currentXmlContent = '';
    });

    final chunks = _generateXmlChunks();
    _totalChunks = chunks.length;

    _streamController.startStreaming();

    // Simulate streaming with delays and build up complete XML
    for (int i = 0; i < chunks.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) break;

      _streamController.addChunk(chunks[i]);

      setState(() {
        _chunksProcessed = i + 1;
        _currentXmlContent += chunks[i];
      });
    }

    _streamController.completeStreaming();
  }

  void _resetStream() {
    _streamController.reset();
    setState(() {
      _chunksProcessed = 0;
      _totalChunks = 0;
      _currentXmlContent = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FlowXML Streaming Demo'),
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isStreaming ? null : _startStreaming,
                  icon: Icon(_isStreaming ? Icons.stream : Icons.play_arrow),
                  label: Text(
                      _isStreaming ? 'Streaming...' : 'Start Big Data Stream'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _resetStream,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                const Spacer(),
                if (_isStreaming)
                  Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 8),
                      Text('$_chunksProcessed / $_totalChunks'),
                    ],
                  ),
              ],
            ),
          ),

          // Progress indicator
          if (_totalChunks > 0)
            LinearProgressIndicator(
              value: _chunksProcessed / _totalChunks,
              backgroundColor: Colors.grey[300],
            ),

          // Debug info
          if (_currentXmlContent.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current XML Content:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      _currentXmlContent.length > 200
                          ? '${_currentXmlContent.substring(0, 200)}...'
                          : _currentXmlContent,
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),

          // Content area with direct XML rendering
          Expanded(
            child: _currentXmlContent.isEmpty && !_isStreaming
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stream, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Ready to stream XML content',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Click "Start Big Data Stream" to begin',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _currentXmlContent.isEmpty && _isStreaming
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Initializing stream...'),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: FlowXML.renderer(
                          xmlContent: _currentXmlContent,
                          isStreaming: _isStreaming,
                          onComponentInteraction: (action, data) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Component interaction: $action'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
