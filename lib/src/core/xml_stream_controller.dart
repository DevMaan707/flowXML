import 'dart:async';
import 'dart:developer' as developer;
import 'package:rxdart/rxdart.dart';

import '../models/parsed_component.dart';
import 'xml_parser.dart';

/// Advanced controller for managing XML streaming with reactive streams
class XmlStreamController {
  static const String _logTag = 'XmlStreamController';

  final StreamingXmlParser _parser;
  final BehaviorSubject<List<ParsedComponent>> _componentsSubject;
  final BehaviorSubject<bool> _isStreamingSubject;
  final BehaviorSubject<String?> _errorSubject;

  StreamController<String>? _inputController;
  StreamSubscription? _inputSubscription;

  bool _isDisposed = false;

  XmlStreamController()
      : _parser = StreamingXmlParser(),
        _componentsSubject = BehaviorSubject<List<ParsedComponent>>.seeded([]),
        _isStreamingSubject = BehaviorSubject<bool>.seeded(false),
        _errorSubject = BehaviorSubject<String?>.seeded(null);

  /// Stream of parsed components
  Stream<List<ParsedComponent>> get componentsStream =>
      _componentsSubject.stream;

  /// Stream of streaming status
  Stream<bool> get isStreamingStream => _isStreamingSubject.stream;

  /// Stream of errors
  Stream<String?> get errorStream => _errorSubject.stream;

  /// Current components
  List<ParsedComponent> get currentComponents => _componentsSubject.value;

  /// Current streaming status
  bool get isStreaming => _isStreamingSubject.value;

  /// Current error (if any)
  String? get currentError => _errorSubject.value;

  /// Start streaming XML content
  void startStreaming() {
    if (_isDisposed) {
      throw StateError('Controller has been disposed');
    }

    developer.log('Starting XML streaming', name: _logTag);

    _inputController?.close();
    _inputSubscription?.cancel();

    _inputController = StreamController<String>();
    _isStreamingSubject.add(true);
    _errorSubject.add(null);

    _inputSubscription = _inputController!.stream
        .debounceTime(const Duration(milliseconds: 10))
        .listen(
          _processChunk,
          onError: _handleError,
          onDone: _handleStreamComplete,
        );
  }

  /// Add XML content chunk
  void addChunk(String chunk) {
    if (_isDisposed || _inputController == null) {
      return;
    }

    developer.log('Adding chunk (${chunk.length} chars)', name: _logTag);
    _inputController!.add(chunk);
  }

  /// Complete streaming
  void completeStreaming() {
    if (_isDisposed || _inputController == null) {
      return;
    }

    developer.log('Completing XML streaming', name: _logTag);
    _inputController!.close();
  }

  /// Reset the controller to initial state
  void reset() {
    if (_isDisposed) {
      return;
    }

    developer.log('Resetting XML stream controller', name: _logTag);

    _inputController?.close();
    _inputSubscription?.cancel();
    _inputController = null;
    _inputSubscription = null;

    _parser.reset();
    _componentsSubject.add([]);
    _isStreamingSubject.add(false);
    _errorSubject.add(null);
  }

  /// Process a single chunk of XML content
  void _processChunk(String chunk) {
    try {
      final components = _parser.addChunk(chunk);
      _componentsSubject.add(components);

      developer.log('Processed chunk, now have ${components.length} components',
          name: _logTag);
    } catch (e, stackTrace) {
      developer.log('Error processing chunk: $e',
          name: _logTag, error: e, stackTrace: stackTrace);
      _handleError(e);
    }
  }

  /// Handle streaming completion
  void _handleStreamComplete() {
    try {
      developer.log('Stream complete, finalizing parser', name: _logTag);

      final finalComponents = _parser.finalize();
      _componentsSubject.add(finalComponents);
      _isStreamingSubject.add(false);

      developer.log('Finalized with ${finalComponents.length} components',
          name: _logTag);
    } catch (e, stackTrace) {
      developer.log('Error finalizing stream: $e',
          name: _logTag, error: e, stackTrace: stackTrace);
      _handleError(e);
    }
  }

  /// Handle errors during streaming
  void _handleError(dynamic error) {
    final errorMessage = error.toString();
    developer.log('Streaming error: $errorMessage', name: _logTag);

    _errorSubject.add(errorMessage);
    _isStreamingSubject.add(false);
  }

  /// Get controller statistics
  Map<String, dynamic> get statistics {
    return {
      'componentsCount': currentComponents.length,
      'isStreaming': isStreaming,
      'hasError': currentError != null,
      'parserStatistics': _parser.statistics,
    };
  }

  /// Dispose of the controller and clean up resources
  void dispose() {
    if (_isDisposed) {
      return;
    }

    developer.log('Disposing XML stream controller', name: _logTag);

    _isDisposed = true;
    _inputController?.close();
    _inputSubscription?.cancel();
    _componentsSubject.close();
    _isStreamingSubject.close();
    _errorSubject.close();
  }
}
