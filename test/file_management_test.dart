import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai/shared/shared.dart';

void main() {
  group('FileManagementService Tests', () {
    late FileManagementService service;

    setUp(() {
      service = FileManagementService();
    });

    test('should format bytes correctly', () {
      expect(UtilHelper.formatBytes(0), '0 B');
      expect(UtilHelper.formatBytes(1024), '1.00 KB');
      expect(UtilHelper.formatBytes(1048576), '1.00 MB');
      expect(UtilHelper.formatBytes(1073741824), '1.00 GB');
    });

    test('should get total space', () async {
      final totalSpace = await service.getTotalSpace();
      expect(totalSpace, isA<int>());
      expect(totalSpace, greaterThan(0));
    });

    test('should get free space', () async {
      final freeSpace = await service.getFreeSpace();
      expect(freeSpace, isA<int>());
      expect(freeSpace, greaterThanOrEqualTo(0));
    });

    test('should get used space', () async {
      final usedSpace = await service.getUsedSpace();
      expect(usedSpace, isA<int>());
      expect(usedSpace, greaterThanOrEqualTo(0));
    });

    test('should get app data size', () async {
      final appDataSize = await service.getAppDataSize();
      expect(appDataSize, isA<int>());
      expect(appDataSize, greaterThanOrEqualTo(0));
    });
  });

  group('FileManagementRepository Tests', () {
    late FileManagementRepository repository;
    late FileManagementService service;

    setUp(() {
      service = FileManagementService();
      repository = FileManagementRepository(service);
    });

    test('should format bytes correctly', () {
      expect(UtilHelper.formatBytes(0), '0 B');
      expect(UtilHelper.formatBytes(1024), '1.00 KB');
      expect(UtilHelper.formatBytes(1048576), '1.00 MB');
    });

    test('should get total space', () async {
      final totalSpace = await repository.getTotalSpace();
      expect(totalSpace, isA<int>());
      expect(totalSpace, greaterThan(0));
    });

    test('should get free space', () async {
      final freeSpace = await repository.getFreeSpace();
      expect(freeSpace, isA<int>());
      expect(freeSpace, greaterThanOrEqualTo(0));
    });

    test('should get used space', () async {
      final usedSpace = await repository.getUsedSpace();
      expect(usedSpace, isA<int>());
      expect(usedSpace, greaterThanOrEqualTo(0));
    });

    test('should get app data size', () async {
      final appDataSize = await repository.getAppDataSize();
      expect(appDataSize, isA<int>());
      expect(appDataSize, greaterThanOrEqualTo(0));
    });
  });
}
