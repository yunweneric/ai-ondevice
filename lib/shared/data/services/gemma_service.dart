import 'dart:io';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import '../../logging/logger.dart';

class GemmaService {
  static final GemmaService _instance = GemmaService._internal();
  factory GemmaService() => _instance;
  GemmaService._internal();

  bool _isInitialized = false;
  dynamic _model; // Will be properly typed once flutter_gemma is imported

  /// Initialize the Gemma service
  Future<void> initialize() async {
    try {
      AppLogger.i('Initializing Gemma service...');

      // Get the documents directory for model storage
      final documentsDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${documentsDir.path}/models');

      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      AppLogger.i('Gemma service initialized successfully');
      _isInitialized = true;
    } catch (e) {
      AppLogger.e('Failed to initialize Gemma service: $e');
      rethrow;
    }
  }

  /// Load a model from the specified path
  Future<void> loadModel({
    required String modelPath,
    String modelType = 'gemma3Nano',
    bool supportImage = false,
    String backendType = 'cpu',
  }) async {
    try {
      AppLogger.i('Loading model from: $modelPath');

      if (_model != null) {
        // Close existing model if available
        try {
          await _model.close();
        } catch (e) {
          AppLogger.e('Error closing existing model: $e');
        }
      }

      // Create model instance - this will be properly implemented once flutter_gemma is available
      // For now, we'll store the path and configuration
      _model = {
        'path': modelPath,
        'type': modelType,
        'supportImage': supportImage,
        'backend': backendType,
        'initialized': false,
      };

      AppLogger.i('Model configuration prepared successfully');
    } catch (e) {
      AppLogger.e('Failed to load model: $e');
      rethrow;
    }
  }

  /// Generate text response
  Future<String> generateText({
    required String prompt,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    try {
      if (_model == null) {
        throw Exception('Model not loaded. Call loadModel() first.');
      }

      AppLogger.i(
          'Generating text for prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...');

      // This will be implemented with actual flutter_gemma API
      // For now, return a placeholder response
      await Future.delayed(const Duration(seconds: 1)); // Simulate processing

      AppLogger.i('Text generation completed');
      return 'This is a placeholder response. The actual flutter_gemma integration will be implemented once the package is properly configured.';
    } catch (e) {
      AppLogger.e('Failed to generate text: $e');
      rethrow;
    }
  }

  /// Generate chat response
  Future<String> generateChatResponse({
    required List<dynamic> messages,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    try {
      if (_model == null) {
        throw Exception('Model not loaded. Call loadModel() first.');
      }

      AppLogger.i('Generating chat response for ${messages.length} messages');

      // This will be implemented with actual flutter_gemma API
      // For now, return a placeholder response
      await Future.delayed(const Duration(seconds: 1)); // Simulate processing

      AppLogger.i('Chat response generated successfully');
      return 'This is a placeholder chat response. The actual flutter_gemma integration will be implemented once the package is properly configured.';
    } catch (e) {
      AppLogger.e('Failed to generate chat response: $e');
      rethrow;
    }
  }

  /// Check if a model supports function calling
  bool supportsFunctionCalls() {
    // This will be implemented with actual flutter_gemma API
    return false;
  }

  /// Check if a model supports thinking mode
  bool supportsThinkingMode() {
    // This will be implemented with actual flutter_gemma API
    return false;
  }

  /// Check if a model supports images
  bool supportsImages() {
    // This will be implemented with actual flutter_gemma API
    return _model?['supportImage'] ?? false;
  }

  /// Get model information
  Map<String, dynamic>? getModelInfo() {
    return _model;
  }

  /// Close the current model
  Future<void> closeModel() async {
    try {
      if (_model != null) {
        // Close model if available
        try {
          await _model.close();
        } catch (e) {
          AppLogger.e('Error closing model: $e');
        }
        _model = null;
        AppLogger.i('Model closed successfully');
      }
    } catch (e) {
      AppLogger.e('Failed to close model: $e');
      rethrow;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if a model is loaded
  bool get isModelLoaded => _model != null;

  /// Dispose the service
  Future<void> dispose() async {
    await closeModel();
    _isInitialized = false;
  }
}
