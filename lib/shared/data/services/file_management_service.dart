import 'dart:io';
import 'dart:math';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:storage_space/storage_space.dart';

class FileManagementService {
  /// Get total device space in bytes
  Future<int> getTotalSpace() async {
    try {
      StorageSpace freeSpace = await getStorageSpace(
        lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024,
        fractionDigits: 1,
      );

      return freeSpace.total;
    } catch (e) {
      AppLogger.e('Error getting total space: $e');
      return 0;
    }
  }

  /// Get free device space in bytes
  Future<int> getFreeSpace() async {
    try {
      StorageSpace freeSpace = await getStorageSpace(
        lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024,
        fractionDigits: 1,
      );

      return freeSpace.free;
    } catch (e) {
      AppLogger.e('Error getting free space: $e');
      return 0;
    }
  }

  /// Get used device space in bytes
  Future<int> getUsedSpace() async {
    try {
      StorageSpace usedSpace = await getStorageSpace(
        lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024,
        fractionDigits: 1,
      );

      return usedSpace.used;
    } catch (e) {
      return 0;
    }
  }

  /// Get storage usage percentage (0.0 to 1.0)
  Future<double> getStorageUsagePercentage() async {
    try {
      final totalSpace = await getTotalSpace();
      if (totalSpace == 0) return 0.0;

      final usedSpace = await getUsedSpace();
      final percentage = usedSpace / totalSpace;
      return percentage;
    } catch (e) {
      return 0.0;
    }
  }

  /// Format bytes to human readable string (e.g., "1.5 GB")
  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, i);

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Get formatted storage information
  Future<Map<String, String>> getFormattedStorageInfo() async {
    try {
      final totalSpace = await getTotalSpace();
      final freeSpace = await getFreeSpace();
      final usedSpace = await getUsedSpace();
      final usagePercentage = await getStorageUsagePercentage();

      return {
        'total': formatBytes(totalSpace),
        'free': formatBytes(freeSpace),
        'used': formatBytes(usedSpace),
        'percentage': '${(usagePercentage * 100).toStringAsFixed(1)}%',
      };
    } catch (e) {
      return {
        'total': '0 B',
        'free': '0 B',
        'used': '0 B',
        'percentage': '0%',
      };
    }
  }

  /// Get detailed storage information with platform-specific details
  Future<Map<String, dynamic>> getDetailedStorageInfo() async {
    try {
      final totalSpace = await getTotalSpace();
      final freeSpace = await getFreeSpace();
      final usedSpace = await getUsedSpace();
      final usagePercentage = await getStorageUsagePercentage();
      final appDataSize = await getAppDataSize();

      return {
        'total': totalSpace,
        'free': freeSpace,
        'used': usedSpace,
        'percentage': usagePercentage,
        'appDataSize': appDataSize,
        'formatted': {
          'total': formatBytes(totalSpace),
          'free': formatBytes(freeSpace),
          'used': formatBytes(usedSpace),
          'appData': formatBytes(appDataSize),
          'percentage': '${(usagePercentage * 100).toStringAsFixed(1)}%',
        },
        'platform': Platform.operatingSystem,
        'isIOS': Platform.isIOS,
        'isAndroid': Platform.isAndroid,
      };
    } catch (e) {
      AppLogger.e('Error getting detailed storage info: $e');
      return {
        'total': 0,
        'free': 0,
        'used': 0,
        'percentage': 0.0,
        'appDataSize': 0,
        'formatted': {
          'total': '0 B',
          'free': '0 B',
          'used': '0 B',
          'appData': '0 B',
          'percentage': '0%',
        },
        'platform': Platform.operatingSystem,
        'isIOS': Platform.isIOS,
        'isAndroid': Platform.isAndroid,
      };
    }
  }

  /// Get storage information for specific directories (as shown in the official example)
  Future<List<Map<String, dynamic>>> getDirectoryStorageInfo() async {
    try {
      List<Directory> directories;

      if (Platform.isIOS) {
        directories = [await getApplicationDocumentsDirectory()];
      } else if (Platform.isAndroid) {
        directories = await getExternalStorageDirectories(
          type: StorageDirectory.movies,
        ).then(
          (list) async => list ?? [await getApplicationDocumentsDirectory()],
        );
      } else {
        return [];
      }

      List<Map<String, dynamic>> directorySpace = [];

      for (var directory in directories) {
        try {
          var space = await DiskSpacePlus.getFreeDiskSpaceForPath(directory.path) ?? 0;
          directorySpace.add({
            'path': directory.path,
            'space': space,
            'formatted': formatBytes(space.toInt()),
          });
          AppLogger.i('Space in ${directory.path}: ${formatBytes(space.toInt())}');
        } catch (e) {
          AppLogger.e('Error getting space for ${directory.path}: $e');
        }
      }

      return directorySpace;
    } catch (e) {
      AppLogger.e('Error getting directory storage info: $e');
      return [];
    }
  }

  /// Get app documents directory
  Future<Directory?> getAppDocumentsDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      AppLogger.i('App documents directory: ${directory.path}');
      return directory;
    } catch (e) {
      AppLogger.e('Error getting app documents directory: $e');
      return null;
    }
  }

  /// Get app cache directory
  Future<Directory?> getAppCacheDirectory() async {
    try {
      final directory = await getTemporaryDirectory();
      AppLogger.i('App cache directory: ${directory.path}');
      return directory;
    } catch (e) {
      AppLogger.e('Error getting app cache directory: $e');
      return null;
    }
  }

  /// Get app data directory size in bytes
  Future<int> getAppDataSize() async {
    try {
      final documentsDir = await getAppDocumentsDirectory();
      final cacheDir = await getAppCacheDirectory();

      int totalSize = 0;

      if (documentsDir != null && documentsDir.existsSync()) {
        totalSize += await _getDirectorySize(documentsDir);
      }

      if (cacheDir != null && cacheDir.existsSync()) {
        totalSize += await _getDirectorySize(cacheDir);
      }

      AppLogger.i('App data size: $totalSize bytes');
      return totalSize;
    } catch (e) {
      AppLogger.e('Error getting app data size: $e');
      return 0;
    }
  }

  /// Get directory size recursively
  Future<int> _getDirectorySize(Directory directory) async {
    try {
      int totalSize = 0;

      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      AppLogger.e('Error calculating directory size: $e');
      return 0;
    }
  }

  /// Clear app cache directory
  Future<bool> clearAppCache() async {
    try {
      final cacheDir = await getAppCacheDirectory();
      if (cacheDir == null || !cacheDir.existsSync()) {
        AppLogger.i('Cache directory does not exist');
        return false;
      }

      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }

      AppLogger.i('App cache cleared successfully');
      return true;
    } catch (e) {
      AppLogger.e('Error clearing app cache: $e');
      return false;
    }
  }

  /// Clear app documents directory
  Future<bool> clearAppDocuments() async {
    try {
      final documentsDir = await getAppDocumentsDirectory();
      if (documentsDir == null || !documentsDir.existsSync()) {
        AppLogger.i('Documents directory does not exist');
        return false;
      }

      await for (final entity in documentsDir.list()) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }

      AppLogger.i('App documents cleared successfully');
      return true;
    } catch (e) {
      AppLogger.e('Error clearing app documents: $e');
      return false;
    }
  }

  /// Clear all app data (cache + documents)
  Future<bool> clearAllAppData() async {
    try {
      final cacheCleared = await clearAppCache();
      final documentsCleared = await clearAppDocuments();

      final success = cacheCleared && documentsCleared;
      AppLogger.i('All app data cleared: $success');
      return success;
    } catch (e) {
      AppLogger.e('Error clearing all app data: $e');
      return false;
    }
  }
}
