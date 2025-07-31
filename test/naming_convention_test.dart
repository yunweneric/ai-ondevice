import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('File Naming Convention Tests', () {
    test('All Dart files should be named in snake_case', () {
      final libDirectory = Directory('lib');
      final violations = <String>[];

      _scanDirectory(libDirectory, violations);

      if (violations.isNotEmpty) {
        fail('Found ${violations.length} files that do not follow snake_case naming convention:\n'
            '${violations.join('\n')}\n\n'
            'All Dart files should be named in snake_case format (e.g., my_file.dart, not myFile.dart)');
      }
    });

    test('All test files should be named in snake_case', () {
      final testDirectory = Directory('test');
      final violations = <String>[];

      _scanDirectory(testDirectory, violations);

      if (violations.isNotEmpty) {
        fail('Found ${violations.length} test files that do not follow snake_case naming convention:\n'
            '${violations.join('\n')}\n\n'
            'All test files should be named in snake_case format (e.g., my_test.dart, not myTest.dart)');
      }
    });
  });
}

void _scanDirectory(Directory directory, List<String> violations) {
  if (!directory.existsSync()) {
    return;
  }

  final entities = directory.listSync();

  for (final entity in entities) {
    if (entity is File) {
      final fileName = entity.path.split('/').last;

      // Check if it's a Dart file
      if (fileName.endsWith('.dart')) {
        // Remove the .dart extension for checking
        final nameWithoutExtension = fileName.replaceAll('.dart', '');

        // Check if the name follows snake_case convention
        if (!_isSnakeCase(nameWithoutExtension)) {
          violations.add('${entity.path}');
        }
      }
    } else if (entity is Directory) {
      // Skip certain directories that might contain generated files
      final dirName = entity.path.split('/').last;
      if (!_shouldSkipDirectory(dirName)) {
        _scanDirectory(entity, violations);
      }
    }
  }
}

bool _isSnakeCase(String name) {
  // File naming rules:
  // 1. Single word files: just lowercase (e.g., "main", "utils")
  // 2. Multi-word files: snake_case (e.g., "chat_screen", "model_card")
  // 3. Only contain lowercase letters, numbers, and underscores
  // 4. Not start or end with underscore
  // 5. Not have consecutive underscores
  // 6. Not be empty
  // 7. Not be camelCase or PascalCase

  if (name.isEmpty) return false;

  // Check if it starts or ends with underscore
  if (name.startsWith('_') || name.endsWith('_')) return false;

  // Check for consecutive underscores
  if (name.contains('__')) return false;

  // Check if it only contains lowercase letters, numbers, and single underscores
  final validPattern = RegExp(r'^[a-z0-9_]+$');
  if (!validPattern.hasMatch(name)) return false;

  // Additional check: ensure it's not camelCase or PascalCase
  // This catches cases like "myFile" or "MyFile" that should be "my_file"
  if (RegExp(r'[A-Z]').hasMatch(name)) return false;

  // Check if it's a single word (no underscores) - should be just lowercase
  if (!name.contains('_')) {
    // Single word files should be just lowercase
    return name == name.toLowerCase();
  }

  // Multi-word files should be in snake_case
  return true;
}

bool _shouldSkipDirectory(String dirName) {
  // Skip directories that might contain generated files or external dependencies
  final skipDirectories = [
    '.dart_tool',
    'build',
    'generated',
    'gen',
    'generated_plugin_registrant',
    'ephemeral',
  ];

  return skipDirectories.contains(dirName);
}
