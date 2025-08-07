# FlowXML

A modern Flutter library that converts XML code into Flutter components with real-time streaming support.

[![pub package](https://img.shields.io/pub/v/flowxml.svg)](https://pub.dev/packages/flowxml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

FlowXML provides a comprehensive solution for handling streaming XML responses from AI APIs and rendering dynamic UI components in Flutter. It's designed with flexibility, modularity, and scalability in mind.

## Features

- **🔄 Real-time Streaming**: Handle partial XML content as it streams
- **🧩 Dynamic Components**: Render interactive UI elements based on XML tags
- **🎨 Customizable**: Easy to add new component types and customize existing ones
- **📱 Flutter Native**: Built specifically for Flutter with Material Design
- **🚀 High Performance**: Efficient parsing and rendering with minimal overhead
- **🛡️ Error Resilient**: Graceful handling of malformed or incomplete XML
- **📦 Extensible**: Modular architecture for easy expansion

## Supported Components

### Built-in Components

- **Text**: Rich text with Markdown support
- **Image**: Network images with caching and loading states
- **Video**: Video playback with native controls
- **OptionSelector**: Interactive choice selection
- **Button**: Customizable action buttons
- **Card**: Grouped content display
- **List**: Structured data presentation
- **Progress**: Progress indicators and bars
- **Loader**: Loading states and spinners
- **PostBody**: Generated content with copy functionality

### Component Features

- Streaming content support
- Custom styling and theming
- Error states and fallbacks
- Interactive callbacks
- Accessibility support

## Installation

Add FlowXML to your `pubspec.yaml`:

```yaml
dependencies:
  flowxml: ^1.0.0
```
Then run:
```shell
flutter pub get
```
## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flowxml/flowxml.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const xmlContent = '''
      <ChatResponse>
        <Message>Hello! Here's an image:</Message>
        <Image src="https://picsum.photos/300/200">Beautiful scenery</Image>
        <OptionSelector options="Yes,No,Maybe" title="Do you like it?">
          What do you think?
        </OptionSelector>
      </ChatResponse>
    ''';

    return FlowXML.renderer(
      xmlContent: xmlContent,
      onComponentInteraction: (action, data) {
        print('Component interaction: $action with data: $data');
      },
    );
  }
}

```

### Streaming Content
```dart
class StreamingExample extends StatefulWidget {
  @override
  _StreamingExampleState createState() => _StreamingExampleState();
}

class _StreamingExampleState extends State<StreamingExample> {
  late XmlStreamController _controller;
  String _xmlContent = '';
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _controller = FlowXML.createStreamController();

    // Listen to parsed components
    _controller.componentsStream.listen((components) {
      setState(() {
        // Update UI with new components
      });
    });

    _simulateStreaming();
  }

  void _simulateStreaming() async {
    _controller.startStreaming();

    final chunks = [
      '<ChatResponse><Message>Processing',
      ' your request...</Message>',
      '<Loader>Please wait</Loader>',
      '<PostBody>Generated response here</PostBody>',
      '</ChatResponse>'
    ];

    for (final chunk in chunks) {
      await Future.delayed(Duration(seconds: 1));
      _controller.addChunk(chunk);
    }

    _controller.completeStreaming();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ParsedComponent>>(
      stream: _controller.componentsStream,
      builder: (context, snapshot) {
        final components = snapshot.data ?? [];

        return Column(
          children: components.map((component) {
            // Render each component
            return FlowXML.renderer(
              xmlContent: component.content,
              isStreaming: !component.isComplete,
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

```

## Customization

### Registering Custom Components
```dart
class CustomAlertComponent extends XmlComponent {
  const CustomAlertComponent({super.key, required super.props});

  @override
  String get componentType => 'Alert';

  @override
  Widget build(BuildContext context) {
    final type = props.getAttribute('type', 'info');
    final title = props.getAttribute('title', 'Alert');

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getAlertColor(type),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(props.content),
        ],
      ),
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'error': return Colors.red[100]!;
      case 'warning': return Colors.orange[100]!;
      case 'success': return Colors.green[100]!;
      default: return Colors.blue[100]!;
    }
  }
}

// Register the component
FlowXML.registerComponent('Alert', (props) => CustomAlertComponent(props: props));

```
### Custom styling

```dart
final customStyle = ComponentStyle(
  backgroundColor: Colors.grey[50],
  textColor: Colors.black87,
  fontSize: 16.0,
  padding: 20.0,
  margin: 12.0,
);

FlowXML.renderer(
  xmlContent: xmlContent,
  style: customStyle,
);

```

## Advanced Features

### Component Registry

```dart
// Check if component is registered
bool isRegistered = FlowXML.isComponentRegistered('MyComponent');

// Get registry statistics
Map<String, dynamic> stats = FlowXML.registry.statistics;

// Register component aliases
FlowXML.registry.registerAlias('Img', 'Image');

```

### Error Handling
```dart
FlowXML.renderer(
  xmlContent: xmlContent,
  errorBuilder: (error) => Container(
    padding: EdgeInsets.all(16),
    child: Text('Error: $error'),
  ),
  loadingBuilder: () => CircularProgressIndicator(),
);

```
### Component Interactions

```dart
FlowXML.renderer(
  xmlContent: xmlContent,
  onComponentInteraction: (action, data) {
    switch (action) {
      case 'select':
        print('User selected: ${data['value']}');
        break;
      case 'button_press':
        print('Button pressed: ${data['action']}');
        break;
      case 'copy':
        print('Content copied: ${data['content']}');
        break;
    }
  },
);

```
