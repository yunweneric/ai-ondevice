import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai/shared/data/services/gemma_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Flutter Gemma Integration Tests', () {
    test('GemmaService can be instantiated', () {
      final gemmaService = GemmaService();
      expect(gemmaService, isNotNull);
      expect(gemmaService.isInitialized, isFalse);
    });

    test('GemmaService can be initialized', () async {
      final gemmaService = GemmaService();
      await gemmaService.initialize();
      expect(gemmaService.isInitialized, isTrue);
    });

    test('GemmaService can load model configuration', () async {
      final gemmaService = GemmaService();
      await gemmaService.initialize();

      await gemmaService.loadModel(
        modelPath: '/test/path/model.tflite',
        modelType: 'gemma3Nano',
        supportImage: true,
        backendType: 'gpu',
      );

      expect(gemmaService.isModelLoaded, isTrue);

      final modelInfo = gemmaService.getModelInfo();
      expect(modelInfo, isNotNull);
      expect(modelInfo!['path'], '/test/path/model.tflite');
      expect(modelInfo!['type'], 'gemma3Nano');
      expect(modelInfo!['supportImage'], isTrue);
      expect(modelInfo!['backend'], 'gpu');
    });

    test('GemmaService can generate placeholder text', () async {
      final gemmaService = GemmaService();
      await gemmaService.initialize();

      await gemmaService.loadModel(
        modelPath: '/test/path/model.tflite',
        modelType: 'gemma3Nano',
      );

      final response = await gemmaService.generateText(
        prompt: 'Hello, how are you?',
        maxTokens: 100,
        temperature: 0.7,
      );

      expect(response, isA<String>());
      expect(response.isNotEmpty, isTrue);
      expect(response.contains('placeholder'), isTrue);
    });

    test('GemmaService can generate placeholder chat response', () async {
      final gemmaService = GemmaService();
      await gemmaService.initialize();

      await gemmaService.loadModel(
        modelPath: '/test/path/model.tflite',
        modelType: 'gemma3Nano',
      );

      final response = await gemmaService.generateChatResponse(
        messages: [
          {'role': 'user', 'content': 'Hello'},
          {'role': 'assistant', 'content': 'Hi there!'},
        ],
        maxTokens: 100,
        temperature: 0.7,
      );

      expect(response, isA<String>());
      expect(response.isNotEmpty, isTrue);
      expect(response.contains('placeholder'), isTrue);
    });

    test('GemmaService can close model', () async {
      final gemmaService = GemmaService();
      await gemmaService.initialize();

      await gemmaService.loadModel(
        modelPath: '/test/path/model.tflite',
        modelType: 'gemma3Nano',
      );

      expect(gemmaService.isModelLoaded, isTrue);

      await gemmaService.closeModel();
      expect(gemmaService.isModelLoaded, isFalse);
    });

    test('GemmaService can dispose', () async {
      final gemmaService = GemmaService();
      await gemmaService.initialize();

      await gemmaService.loadModel(
        modelPath: '/test/path/model.tflite',
        modelType: 'gemma3Nano',
      );

      expect(gemmaService.isInitialized, isTrue);
      expect(gemmaService.isModelLoaded, isTrue);

      await gemmaService.dispose();
      expect(gemmaService.isInitialized, isFalse);
      expect(gemmaService.isModelLoaded, isFalse);
    });

    test('GemmaService feature support checks work', () {
      final gemmaService = GemmaService();

      // These are placeholder implementations for now
      expect(gemmaService.supportsFunctionCalls(), isFalse);
      expect(gemmaService.supportsThinkingMode(), isFalse);
      expect(gemmaService.supportsImages(), isFalse);
    });
  });
}
