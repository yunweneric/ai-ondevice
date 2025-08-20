# Flutter Gemma Setup

This document outlines the setup and configuration for the Flutter Gemma package in the Offline AI project.

## ✅ Completed Setup

### 1. Dependencies
- Added `flutter_gemma: ^0.10.2` to `pubspec.yaml`
- Updated to latest version for best compatibility

### 2. iOS Configuration
- **Minimum iOS Version**: Updated to iOS 16.0 in `ios/Podfile` (required for MediaPipe GenAI)
- **Memory Entitlements**: Created `ios/Runner/Runner.entitlements` with:
  - Extended virtual addressing
  - Increased memory limits
  - Increased debugging memory limits
- **Info.plist Updates**:
  - File sharing enabled (`UIFileSharingEnabled`)
  - Network access description for development
  - Performance optimization enabled
  - App transport security configured

### 3. Android Configuration
- **OpenGL Support**: Added OpenCL libraries to `AndroidManifest.xml` for GPU acceleration:
  - `libOpenCL.so`
  - `libOpenCL-car.so`
  - `libOpenCL-pixel.so`

### 4. Web Configuration
- **MediaPipe Dependencies**: Added required scripts to `web/index.html`:
  - FilesetResolver
  - LlmInference

### 5. Service Integration
- **FlutterGemmaService**: Created placeholder service in `lib/shared/data/services/flutter_gemma_service.dart`
- **Service Locator**: Registered service in dependency injection system
- **Exports**: Added service to shared exports

## 🔄 Next Steps

### 1. Install Dependencies
```bash
flutter pub get
cd ios && pod install --repo-update
```

### 2. Download AI Models
- Visit [Kaggle](https://www.kaggle.com/models/google/gemma) to download models
- Recommended models for mobile:
  - **Gemma 3 Nano 2B**: Lightweight with vision support
  - **Gemma 3 1B**: Text-only, good performance
  - **Gemma 3 270M**: Ultra-compact for low-end devices

### 3. Implement Service Methods
The current `FlutterGemmaService` is a placeholder. Once you have models and understand the API:

```dart
// Example usage (to be implemented)
final gemmaService = GetIt.instance<FlutterGemmaService>();
await gemmaService.initialize();
await gemmaService.initializeModel('gemma-3-nano-2b');
final response = await gemmaService.generateText('Hello, how are you?');
```

### 4. Model Storage
- Store models in app's documents directory
- Implement model management UI
- Add download progress indicators

### 5. Testing
- Test on physical devices (iOS 16.0+, Android 8.0+)
- Verify memory usage with different model sizes
- Test GPU vs CPU backend performance

## 📱 Supported Models

### Text-Only Models
- Gemma 3 1B
- Gemma 3 270M
- TinyLlama 1.1B
- Llama 3.2 1B
- Phi models

### Multimodal Models (Vision + Text)
- Gemma 3 Nano 2B
- Gemma 3 Nano 4B

### Function Calling Support
- Gemma 3 Nano models
- Hammer 2.1 0.5B
- DeepSeek models
- Qwen models

## ⚠️ Important Notes

1. **Memory Requirements**: Large models require significant RAM (8GB+ recommended for multimodal)
2. **iOS Requirements**: Minimum iOS 16.0, memory entitlements required
3. **Model Size**: Consider device capabilities when choosing models
4. **Offline First**: Models run locally, no internet required after download
5. **Privacy**: All processing happens on-device

## 🐛 Troubleshooting

### iOS Build Issues
- Ensure minimum iOS version is 16.0
- Clean and reinstall pods: `cd ios && pod install --repo-update`
- Verify entitlements file exists and is properly formatted

### Android Issues
- OpenCL libraries are optional (GPU acceleration)
- Models will fall back to CPU if GPU unavailable

### Memory Issues
- Use smaller models on devices with <6GB RAM
- Monitor memory usage during model initialization
- Close models when not in use

## 📚 Resources

- [Flutter Gemma Package](https://pub.dev/packages/flutter_gemma)
- [MediaPipe GenAI Documentation](https://developers.google.com/mediapipe/solutions/genai)
- [Gemma Models on Kaggle](https://www.kaggle.com/models/google/gemma)
- [iOS Memory Management](https://developer.apple.com/documentation/xcode/entitlements)
