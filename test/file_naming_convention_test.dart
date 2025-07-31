import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('File Naming Convention Tests', () {
    test('All Dart files in lib directory should be named in snake_case', () {
      final violations = _checkDirectory('lib');

      if (violations.isNotEmpty) {
        final errorMessage = _buildErrorMessage('lib', violations,
            'All Dart files in lib directory should be named in snake_case format');
        fail(errorMessage);
      }
    });

    test('All test files should be named in snake_case', () {
      final violations = _checkDirectory('test');

      if (violations.isNotEmpty) {
        final errorMessage = _buildErrorMessage('test', violations,
            'All test files should be named in snake_case format');
        fail(errorMessage);
      }
    });

    test('All Dart files should follow proper naming conventions', () {
      final allViolations = <String, List<String>>{};

      // Check lib directory
      final libViolations = _checkDirectory('lib');
      if (libViolations.isNotEmpty) {
        allViolations['lib'] = libViolations;
      }

      // Check test directory
      final testViolations = _checkDirectory('test');
      if (testViolations.isNotEmpty) {
        allViolations['test'] = testViolations;
      }

      if (allViolations.isNotEmpty) {
        final errorMessage = _buildComprehensiveErrorMessage(allViolations);
        fail(errorMessage);
      }
    });
  });
}

List<String> _checkDirectory(String directoryPath) {
  final directory = Directory(directoryPath);
  final violations = <String>[];

  if (!directory.existsSync()) {
    return violations;
  }

  _scanDirectory(directory, violations);
  return violations;
}

void _scanDirectory(Directory directory, List<String> violations) {
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
          violations.add(entity.path);
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
    'ios',
    'android',
    'web',
    'windows',
    'macos',
    'linux',
    'node_modules',
    '.git',
    '.github',
    'docs',
    'assets',
  ];

  return skipDirectories.contains(dirName);
}

String _buildErrorMessage(
    String directory, List<String> violations, String description) {
  final buffer = StringBuffer();
  buffer.writeln('❌ $description');
  buffer.writeln('');
  buffer.writeln(
      'Found ${violations.length} violations in $directory directory:');
  buffer.writeln('');

  for (final violation in violations) {
    buffer.writeln('  • $violation');
  }

  buffer.writeln('');
  buffer.writeln('Examples of correct naming:');
  buffer.writeln('  ✅ main.dart (single word)');
  buffer.writeln('  ✅ utils.dart (single word)');
  buffer.writeln('  ✅ my_file.dart (multi-word)');
  buffer.writeln('  ✅ user_profile_screen.dart (multi-word)');
  buffer.writeln('  ✅ chat_message_widget.dart (multi-word)');
  buffer.writeln('');
  buffer.writeln('Examples of incorrect naming:');
  buffer.writeln('  ❌ myFile.dart (camelCase)');
  buffer.writeln('  ❌ MyFile.dart (PascalCase)');
  buffer.writeln('  ❌ my-file.dart (kebab-case)');
  buffer.writeln('  ❌ my_file_.dart (ends with underscore)');
  buffer.writeln('  ❌ _my_file.dart (starts with underscore)');
  buffer.writeln('  ❌ Main.dart (single word with capital)');
  buffer.writeln('  ❌ Utils.dart (single word with capital)');

  return buffer.toString();
}

String _buildComprehensiveErrorMessage(
    Map<String, List<String>> allViolations) {
  final buffer = StringBuffer();
  buffer.writeln('❌ File Naming Convention Violations Found');
  buffer.writeln('');

  for (final entry in allViolations.entries) {
    final directory = entry.key;
    final violations = entry.value;

    buffer
        .writeln('📁 $directory directory (${violations.length} violations):');
    for (final violation in violations) {
      buffer.writeln('  • $violation');
    }
    buffer.writeln('');
  }

  buffer.writeln('📋 Naming Convention Rules:');
  buffer
      .writeln('  • Single word files: just lowercase (e.g., "main", "utils")');
  buffer.writeln(
      '  • Multi-word files: snake_case (e.g., "chat_screen", "model_card")');
  buffer.writeln('  • Only use lowercase letters, numbers, and underscores');
  buffer.writeln('  • Do not start or end with underscore');
  buffer.writeln('  • Do not use consecutive underscores');
  buffer.writeln('  • Do not use camelCase or PascalCase');
  buffer.writeln('');
  buffer.writeln('Examples:');
  buffer.writeln('  ✅ main.dart (single word)');
  buffer.writeln('  ✅ utils.dart (single word)');
  buffer.writeln('  ✅ chat_screen.dart (multi-word)');
  buffer.writeln('  ✅ model_card_widget.dart (multi-word)');
  buffer.writeln('  ✅ download_service.dart (multi-word)');
  buffer.writeln('  ❌ Main.dart (single word with capital)');
  buffer.writeln('  ❌ Utils.dart (single word with capital)');
  buffer.writeln('  ❌ chatScreen.dart (camelCase)');
  buffer.writeln('  ❌ ChatScreen.dart (PascalCase)');
  buffer.writeln('  ❌ chat-screen.dart (kebab-case)');

  return buffer.toString();
}
