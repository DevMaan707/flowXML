# FlowXML Example

This example demonstrates the FlowXML library's capabilities for real-time XML streaming and component rendering.

## Features Demonstrated

- **Real-time XML streaming** - Watch components appear as XML data streams in
- **Dynamic component creation** - XML tags automatically become Flutter widgets
- **Interactive elements** - Buttons, option selectors, and other interactive components
- **Rich content rendering** - Images, videos, cards, lists, and formatted text
- **Performance optimization** - Efficient handling of large datasets
- **Error handling** - Graceful fallback for invalid or incomplete XML

## Components Showcased

- `Card` - Grouped content with titles and elevation
- `Image` - Network images with loading states
- `Video` - Video playback with native controls
- `Button` - Interactive buttons with actions
- `Progress` - Linear and circular progress indicators
- `List` - Ordered and unordered lists
- `OptionSelector` - Interactive choice selection
- `PostBody` - Rich text content with copy functionality
- `Loader` - Loading spinners and indicators
- `Message` - Text messages with markdown support

## Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## What to Expect

When you click **"Start Big Data Stream"**, the app will:

1. Begin streaming XML content in realistic chunks
2. Parse each chunk incrementally as it arrives
3. Render Flutter components in real-time
4. Show progress and performance metrics
5. Demonstrate interactive component features

The demo simulates a realistic AI chat interface where XML responses are streamed and converted into rich UI components on-the-fly.

## Code Structure

- `main.dart` - Main application entry point with streaming demo
- Uses `XmlStreamController` for managing real-time XML streaming
- Demonstrates `FlowXML.renderer()` for direct XML rendering
- Shows component interaction callbacks and error handling

## Key Learning Points

- How to set up real-time XML streaming
- Component registration and customization
- Performance considerations for large datasets
- Error handling and graceful degradation
- Interactive component implementation

This example serves as both a demonstration and a reference implementation for integrating FlowXML into your own applications.