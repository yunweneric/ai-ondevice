# Contributing to Offline AI

Thank you for your interest in contributing to Offline AI! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **Bug Reports**: Report bugs and issues
- **Feature Requests**: Suggest new features
- **Code Contributions**: Submit pull requests
- **Documentation**: Improve documentation
- **UI/UX**: Design improvements and user experience enhancements
- **Testing**: Help with testing and quality assurance

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Git
- A code editor (VS Code, Android Studio, etc.)

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/yourusername/offline_ai.git
   cd offline_ai
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/originalusername/offline_ai.git
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📝 Development Workflow

### 1. Create a Feature Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create a new feature branch
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Follow the [UI Development Guide](docs/ui.md) for UI components
- Use the established project structure
- Follow the coding standards below

### 3. Test Your Changes

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Check for linting issues
flutter analyze
```

### 4. Commit Your Changes

```bash
# Add your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add new chat screen with voice input support

- Implement voice input functionality
- Add animated options button
- Update chat UI with new features"
```

### 5. Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create PR on GitHub
```

## 📋 Pull Request Guidelines

### Before Submitting

- [ ] Code follows the project's style guidelines
- [ ] All tests pass
- [ ] No linting errors
- [ ] Documentation is updated if needed
- [ ] UI changes follow the [UI Development Guide](docs/ui.md)

### Pull Request Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes.

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
```

## 🎨 Code Standards

### Dart/Flutter Standards

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Project-Specific Standards

#### File Organization
```
lib/feat/feature_name/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   └── usecases/
└── presentation/
    ├── screens/
    └── widgets/
```

#### Naming Conventions
- **Screens**: `ScreenNameScreen` (e.g., `ChatScreen`)
- **Widgets**: `WidgetName` (e.g., `ModelCard`)
- **Files**: `snake_case.dart` (e.g., `chat_screen.dart`)

#### UI Guidelines
- Use `AppSizing` utilities for spacing
- Use `theme.primaryColor` and `theme.cardColor`
- Use predefined text styles from theme
- Don't modify text styles with `copyWith` unless necessary

### State Management

- **BLoC Pattern**: Use for complex state management across features
- **Service Repository Pattern**: For data access and business logic separation
- **Dependency Injection**: Use GetIt for service registration and injection
- **Local State**: Use for component-specific state management

### Dependency Injection

The project uses GetIt for dependency injection. Services are registered in `lib/shared/core/service_locators.dart`:

```dart
// Example service registration
getIt.registerSingleton<DownloadService>(downloadService);
getIt.registerSingleton<ThemeBloc>(themeBloc);

// Usage in widgets
final downloadService = getIt<DownloadService>();
final themeBloc = getIt<ThemeBloc>();
```

## 🐛 Reporting Bugs

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug.

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen.

## Actual Behavior
What actually happens.

## Environment
- OS: [e.g., iOS 15, Android 12]
- Device: [e.g., iPhone 13, Samsung Galaxy S21]
- Flutter Version: [e.g., 3.10.0]
- App Version: [e.g., 1.0.0]

## Screenshots/Videos
If applicable, add screenshots or videos.

## Additional Information
Any other relevant information.
```

## 💡 Feature Requests

### Feature Request Template

```markdown
## Feature Description
Clear description of the requested feature.

## Use Case
Why this feature is needed.

## Proposed Solution
How you think it should be implemented.

## Alternatives Considered
Other approaches you've considered.

## Additional Information
Any other relevant information.
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/feature_test.dart
```

### Writing Tests

- Write unit tests for business logic
- Write widget tests for UI components
- Aim for good test coverage
- Use descriptive test names

## 📚 Documentation

### Updating Documentation

- Update README.md for major changes
- Update UI documentation for UI changes
- Add inline comments for complex code
- Update API documentation if needed

## 🔄 Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version number updated
- [ ] Changelog updated
- [ ] Release notes prepared

## 🏷️ Labels and Milestones

### Issue Labels
- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `ui/ux`: User interface or experience related

### Pull Request Labels
- `breaking`: Breaking changes
- `bug fix`: Bug fixes
- `feature`: New features
- `documentation`: Documentation changes
- `ui/ux`: UI/UX improvements

## 🎯 Getting Help

### Questions and Discussions

- Use [GitHub Discussions](https://github.com/yourusername/offline_ai/discussions) for questions
- Check existing issues before creating new ones
- Be respectful and constructive

### Communication Channels

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors page

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to Offline AI! 🚀 