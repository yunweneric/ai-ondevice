import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/shared/data/services/file_management_service.dart';

class FileManagementRepository {
  final FileManagementService _fileManagementService;

  FileManagementRepository(this._fileManagementService);

  /// Get total device space in bytes
  Future<int> getTotalSpace() async {
    return await _fileManagementService.getTotalSpace();
  }

  /// Get free device space in bytes
  Future<int> getFreeSpace() async {
    return await _fileManagementService.getFreeSpace();
  }

  /// Get used device space in bytes
  Future<int> getUsedSpace() async {
    return await _fileManagementService.getUsedSpace();
  }

  /// Get app data size in bytes
  Future<int> getAppDataSize() async {
    return await _fileManagementService.getAppDataSize();
  }

  /// Clear app cache
  Future<bool> clearAppCache() async {
    return await _fileManagementService.clearAppCache();
  }

  /// Clear app documents
  Future<bool> clearAppDocuments() async {
    return await _fileManagementService.clearAppDocuments();
  }

  /// Clear all app data
  Future<bool> clearAllAppData() async {
    return await _fileManagementService.clearAllAppData();
  }
}
