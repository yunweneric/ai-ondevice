import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai/shared/data/services/permission_service.dart';

void main() {
  group('PermissionService', () {
    late PermissionService permissionService;

    setUp(() {
      permissionService = PermissionService();
    });

    test('should be singleton', () {
      final instance1 = PermissionService();
      final instance2 = PermissionService();
      expect(instance1, equals(instance2));
    });

    test('should provide permission denial message', () {
      final message = permissionService.getPermissionDenialMessage();
      expect(message, isA<String>());
      expect(message.isNotEmpty, isTrue);
    });

    test('should provide permanently denied message', () {
      final message = permissionService.getPermanentlyDeniedMessage();
      expect(message, isA<String>());
      expect(message.isNotEmpty, isTrue);
    });
  });
}
