import 'package:permission_handler/permission_handler.dart';
import 'package:offline_ai/shared/shared.dart';

enum PermissionType {
  storage,
  photos,
  videos,
  audio,
  manageExternalStorage,
  notification,
}

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    try {
      final status = await Permission.storage.status;
      AppLogger.i('Storage permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error checking storage permission: $e');
      return false;
    }
  }

  /// Check if photos permission is granted (for Android 13+)
  Future<bool> isPhotosPermissionGranted() async {
    try {
      final status = await Permission.photos.status;
      AppLogger.i('Photos permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error checking photos permission: $e');
      return false;
    }
  }

  /// Check if videos permission is granted (for Android 13+)
  Future<bool> isVideosPermissionGranted() async {
    try {
      final status = await Permission.videos.status;
      AppLogger.i('Videos permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error checking videos permission: $e');
      return false;
    }
  }

  /// Check if audio permission is granted (for Android 13+)
  Future<bool> isAudioPermissionGranted() async {
    try {
      final status = await Permission.audio.status;
      AppLogger.i('Audio permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error checking audio permission: $e');
      return false;
    }
  }

  /// Check if manage external storage permission is granted
  Future<bool> isManageExternalStoragePermissionGranted() async {
    try {
      final status = await Permission.manageExternalStorage.status;
      AppLogger.i('Manage external storage permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error checking manage external storage permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    try {
      final status = await Permission.notification.status;
      AppLogger.i('Notification permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error checking notification permission: $e');
      return false;
    }
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    try {
      AppLogger.i('Requesting storage permission');
      final status = await Permission.storage.request();
      AppLogger.i('Storage permission request result: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Request photos permission (for Android 13+)
  Future<bool> requestPhotosPermission() async {
    try {
      AppLogger.i('Requesting photos permission');
      final status = await Permission.photos.request();
      AppLogger.i('Photos permission request result: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error requesting photos permission: $e');
      return false;
    }
  }

  /// Request videos permission (for Android 13+)
  Future<bool> requestVideosPermission() async {
    try {
      AppLogger.i('Requesting videos permission');
      final status = await Permission.videos.request();
      AppLogger.i('Videos permission request result: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error requesting videos permission: $e');
      return false;
    }
  }

  /// Request audio permission (for Android 13+)
  Future<bool> requestAudioPermission() async {
    try {
      AppLogger.i('Requesting audio permission');
      final status = await Permission.audio.request();
      AppLogger.i('Audio permission request result: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error requesting audio permission: $e');
      return false;
    }
  }

  /// Request manage external storage permission
  Future<bool> requestManageExternalStoragePermission() async {
    try {
      AppLogger.i('Requesting manage external storage permission');
      final status = await Permission.manageExternalStorage.request();
      AppLogger.i('Manage external storage permission request result: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error requesting manage external storage permission: $e');
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      AppLogger.i('Requesting notification permission');
      final status = await Permission.notification.request();
      AppLogger.i('Notification permission request result: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Request all necessary permissions for downloading and saving files
  Future<bool> requestDownloadPermissions() async {
    try {
      AppLogger.i('Requesting download permissions');

      // For Android 13+ (API 33+), we need to request specific media permissions
      // For older Android versions, we use storage permission
      // For iOS, we use storage permission

      bool allGranted = true;

      // Check if we're on Android 13+ and need specific media permissions
      if (await _isAndroid13OrHigher()) {
        AppLogger.i('Android 13+ detected, requesting media permissions');

        // Request photos permission for images
        if (!await requestPhotosPermission()) {
          allGranted = false;
        }

        // Request videos permission for video files
        if (!await requestVideosPermission()) {
          allGranted = false;
        }

        // Request audio permission for audio files
        if (!await requestAudioPermission()) {
          allGranted = false;
        }
      } else {
        // For older Android versions and iOS, use storage permission
        if (!await requestStoragePermission()) {
          allGranted = false;
        }
      }

      AppLogger.i('Download permissions request completed. All granted: $allGranted');
      return allGranted;
    } catch (e) {
      AppLogger.e('Error requesting download permissions: $e');
      return false;
    }
  }

  /// Request all permissions (download and notification)
  Future<bool> requestAllPermissions() async {
    try {
      AppLogger.i('Requesting all permissions');

      final downloadGranted = await requestDownloadPermissions();
      final notificationGranted = await requestNotificationPermission();

      final allGranted = downloadGranted && notificationGranted;
      AppLogger.i('All permissions request completed. All granted: $allGranted');
      return allGranted;
    } catch (e) {
      AppLogger.e('Error requesting all permissions: $e');
      return false;
    }
  }

  /// Check if all permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    try {
      AppLogger.i('Checking all permissions');

      final downloadGranted = await areDownloadPermissionsGranted();
      final notificationGranted = await isNotificationPermissionGranted();

      final allGranted = downloadGranted && notificationGranted;
      AppLogger.i('All permissions check completed. All granted: $allGranted');
      return allGranted;
    } catch (e) {
      AppLogger.e('Error checking all permissions: $e');
      return false;
    }
  }

  /// Check if all necessary permissions for downloading are granted
  Future<bool> areDownloadPermissionsGranted() async {
    try {
      AppLogger.i('Checking download permissions');

      bool allGranted = true;

      // Check if we're on Android 13+ and need specific media permissions
      if (await _isAndroid13OrHigher()) {
        AppLogger.i('Android 13+ detected, checking media permissions');

        if (!await isPhotosPermissionGranted()) {
          allGranted = false;
        }

        if (!await isVideosPermissionGranted()) {
          allGranted = false;
        }

        if (!await isAudioPermissionGranted()) {
          allGranted = false;
        }
      } else {
        // For older Android versions and iOS, check storage permission
        if (!await isStoragePermissionGranted()) {
          allGranted = false;
        }
      }

      AppLogger.i('Download permissions check completed. All granted: $allGranted');
      return allGranted;
    } catch (e) {
      AppLogger.e('Error checking download permissions: $e');
      return false;
    }
  }

  /// Open app settings if permissions are permanently denied
  Future<void> openAppSettingsPage() async {
    try {
      AppLogger.i('Opening app settings');
      await openAppSettings();
    } catch (e) {
      AppLogger.e('Error opening app settings: $e');
    }
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied(PermissionType type) async {
    try {
      Permission permission;
      switch (type) {
        case PermissionType.storage:
          permission = Permission.storage;
          break;
        case PermissionType.photos:
          permission = Permission.photos;
          break;
        case PermissionType.videos:
          permission = Permission.videos;
          break;
        case PermissionType.audio:
          permission = Permission.audio;
          break;
        case PermissionType.manageExternalStorage:
          permission = Permission.manageExternalStorage;
          break;
        case PermissionType.notification:
          permission = Permission.notification;
          break;
      }

      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      AppLogger.e('Error checking if permission is permanently denied: $e');
      return false;
    }
  }

  /// Check if any download permission is permanently denied
  Future<bool> isAnyDownloadPermissionPermanentlyDenied() async {
    try {
      if (await _isAndroid13OrHigher()) {
        return await isPermissionPermanentlyDenied(PermissionType.photos) ||
            await isPermissionPermanentlyDenied(PermissionType.videos) ||
            await isPermissionPermanentlyDenied(PermissionType.audio);
      } else {
        return await isPermissionPermanentlyDenied(PermissionType.storage);
      }
    } catch (e) {
      AppLogger.e('Error checking if any download permission is permanently denied: $e');
      return false;
    }
  }

  /// Helper method to check if we're on Android 13+ (API 33+)
  Future<bool> _isAndroid13OrHigher() async {
    // This is a simplified check - in a real app, you might want to use
    // a more robust method to detect Android version
    try {
      // For now, we'll assume Android 13+ if we can request photos permission
      // This is not the most accurate method, but it works for our use case
      final photosStatus = await Permission.photos.status;
      return photosStatus != PermissionStatus.denied;
    } catch (e) {
      AppLogger.e('Error checking Android version: $e');
      return false;
    }
  }

  /// Get a user-friendly message for permission denial
  String getPermissionDenialMessage() {
    return 'Storage permission is required to download and save files to your device. '
        'Please grant the permission in app settings to continue.';
  }

  /// Get a user-friendly message for permanently denied permission
  String getPermanentlyDeniedMessage() {
    return 'Storage permission has been permanently denied. '
        'Please enable it manually in your device settings to download files.';
  }
}
