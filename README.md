# Offline AI

A Flutter mobile application that allows you to download and use AI models offline on your device. Interact with powerful AI models like Gemini Pro and UX Pilot without requiring an internet connection.

## 🌟 Features

- **Offline AI Models**: Download and use AI models directly on your device
- **Privacy-First**: All processing happens locally, no data sent to cloud servers
- **Multiple Models**: Support for various AI models (Gemini Pro, UX Pilot, Vision Lite)
- **Seamless Experience**: Download once, switch models, and continue your work anywhere
- **Model Management**: Easily manage, download, and switch between models
- **Voice & Image Input**: Support for voice, image, and camera input methods
- **Cross-Platform**: Available on iOS and Android

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode (for mobile development)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yunweneric/offline_ai.git
   cd offline_ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Usage

1. **Onboarding**: Complete the initial setup to understand the app's features
2. **Model Selection**: Choose and download your first AI model
3. **Chat Interface**: Start conversations with your AI models
4. **Model Management**: Download additional models or switch between them

## 🏗️ Project Structure

```
lib/
├── feat/                           # Feature-based modules
│   ├── chat/                      # Chat functionality
│   │   ├── data/
│   │   │   ├── models/           # Chat data models
│   │   │   ├── repositories/     # Chat repositories
│   │   │   └── services/         # Chat services
│   │   ├── domain/
│   │   │   ├── entities/         # Chat domain entities
│   │   │   └── usecases/         # Chat business logic
│   │   └── presentation/
│   │       ├── screens/          # Chat screens
│   │       ├── widgets/          # Chat widgets
│   │       └── logic/            # Chat BLoCs
│   ├── model_management/          # AI model management
│   └── onboarding/               # Onboarding screens
├── shared/                        # Shared components
│   ├── core/
│   │   ├── service_locators.dart # Dependency injection
│   │   └── bootstrap.dart        # App initialization
│   ├── data/
│   │   ├── repositories/         # Shared repositories
│   │   └── services/             # Shared services
│   ├── presentation/
│   │   ├── screens/              # Shared screens
│   │   ├── widgets/              # Shared widgets
│   │   ├── theme/                # Theme configuration
│   │   └── logic/                # Shared BLoCs
│   └── utils/
│       └── sizing.dart           # Spacing utilities
└── main.dart                     # App entry point
```

## 🎨 UI Development

For detailed information on adding new UI components, see our [UI Development Guide](docs/ui.md).

### Key Guidelines:
- Use `AppSizing` utilities for consistent spacing
- Use `theme.primaryColor` and `theme.cardColor` for theming
- Use predefined text styles from the theme
- Place screens in `feature/presentation/screens/`
- Place widgets in `feature/presentation/widgets/`

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

## 📄 License

This project is licensed under a custom license that allows:
- ✅ Viewing the source code
- ✅ Downloading and installing the app
- ❌ Commercial use

See [LICENSE](LICENSE) for full details.

## 🔧 Development

### Architecture

The app follows a feature-based architecture with:
- **Feature Modules**: Each feature is self-contained with its own data, domain, and presentation layers
- **Shared Components**: Reusable widgets and utilities
- **Clean Architecture**: Separation of concerns with clear boundaries
- **Service Repository Pattern**: For data access and business logic
- **Dependency Injection**: Using GetIt for service locator pattern

### State Management

- **BLoC Pattern**: For complex state management across features
- **Service Repository Pattern**: For data access and business logic separation
- **Dependency Injection**: Using GetIt for service registration and injection
- **Local State**: For component-specific state management

### Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run naming convention tests
flutter test test/naming_convention_test.dart test/file_naming_convention_test.dart
```

### CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment:

- **Pull Request Checks**: Runs tests, code analysis, and builds APK
- **Release Build**: Creates Android APK when a release is published
- **Artifacts**: APK builds are available as downloadable artifacts

#### Workflow Files:
- `.github/workflows/pull-request.yml` - PR checks and APK builds
- `.github/workflows/release.yml` - Release APK builds

## 📋 TODO

- [ ] Add more AI models
- [ ] Implement model versioning
- [ ] Add model performance metrics
- [ ] Implement model sharing
- [ ] Add offline model updates
- [ ] Implement model compression
- [ ] Add user preferences
- [ ] Implement backup/restore

## 🐛 Known Issues

- Model download size can be large (1-2GB per model)
- Initial setup requires internet connection for model downloads
- Some models may require significant device storage

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yunweneric/offline_ai/issues) page
2. Create a new issue with detailed information
3. Join our [Discussions](https://github.com/yunweneric/offline_ai/discussions)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google for Gemini AI models
- The open-source community for various dependencies

---

**Note**: This app is designed for educational and personal use. Please respect the license terms and use responsibly.
