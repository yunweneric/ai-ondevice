import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart' hide DownloadTask;
import 'package:path_provider/path_provider.dart';
import 'package:offline_ai/shared/shared.dart';

ReceivePort _port = ReceivePort();

class DownloadManagerService {
  final LocalNotificationService _notificationService;
  final PermissionService _permissionService;
  final Map<String, DownloadTask> _downloads = {};
  final Map<String, StreamController<DownloadProgress>> _progressControllers = {};

  DownloadManagerService(this._notificationService) : _permissionService = PermissionService();

  /// Initialize flutter_downloader
  static Future<void> initializeDownloader({int step = 10}) async {
    try {
      IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
      _port.listen((dynamic data) {
        String id = data[0];
        DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
        int progress = data[2];
        AppLogger.log('Download progress: $id, $status, $progress');
      });

      AppLogger.i('=== Initializing FlutterDownloader ===');

      await FlutterDownloader.initialize(
        debug: true,
        ignoreSsl: false,
      );

      AppLogger.i('FlutterDownloader.initialize() completed');

      // Register callback for download events
      AppLogger.i('Registering download callback...');
      FlutterDownloader.registerCallback(downloadCallback, step: step);
      AppLogger.i('Download callback registered successfully');
    } catch (e) {
      AppLogger.e('Failed to initialize FlutterDownloader: $e');
      AppLogger.e('Stack trace: ${StackTrace.current}');
    }
  }

  /// Get all downloads
  Map<String, DownloadTask> get downloads => Map.unmodifiable(_downloads);

  /// Get download task by ID
  DownloadTask? getDownloadTask(String id) => _downloads[id];

  /// Get all download IDs for debugging
  List<String> getDownloadIds() {
    AppLogger.log('=== Current Download IDs ===');
    AppLogger.log('Total downloads: ${_downloads.length}');
    for (final entry in _downloads.entries) {
      AppLogger.log('ID: ${entry.key}, File: ${entry.value.fileName}, Status: ${entry.value.status}');
    }
    return _downloads.keys.toList();
  }

  /// Get progress stream for a download
  Stream<DownloadProgress>? getProgressStream(String id) => _progressControllers[id]?.stream;

  /// Start a new download
  Future<DownloadTask> startDownload({
    required String url,
    required String fileName,
    String? customId,
    Map<String, dynamic>? metadata,
  }) async {
    final id = customId ?? _generateId();

    // Check permissions
    final permissionsGranted = await _permissionService.requestDownloadPermissions();
    if (!permissionsGranted) {
      throw Exception('Download permissions not granted');
    }

    // Get download directory
    final directory = await getDownloadDirectory();
    final savedDir = directory.path;

    // Create download task
    final downloadTask = DownloadTask(
      id: id,
      url: url,
      fileName: fileName,
      filePath: '$savedDir/$fileName',
      totalBytes: 0,
      downloadedBytes: 0,
      status: DownloadStatus.downloading,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _downloads[id] = downloadTask;
    _progressControllers[id] = StreamController<DownloadProgress>.broadcast();

    // Start flutter_downloader download
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      headers: {}, // Add any required headers here
      savedDir: savedDir,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: false,
    );

    if (taskId != null) {
      AppLogger.i('FlutterDownloader returned task ID: $taskId');
      AppLogger.i('Original download ID: $id');

      // Update download task with task ID
      final updatedTask = downloadTask.copyWith(id: taskId);
      _downloads[taskId] = updatedTask;

      // Also store with original ID for backward compatibility
      _downloads[id] = updatedTask;

      // Store progress controller with FlutterDownloader task ID
      _progressControllers[taskId] = _progressControllers[id]!;
      AppLogger.i('Progress controller stored with FlutterDownloader task ID: $taskId');

      AppLogger.i('Download task updated with FlutterDownloader task ID');
      AppLogger.i('Returning task with ID: $taskId');

      return updatedTask;
    } else {
      throw Exception('Failed to create download task');
    }
  }

  /// Resume a paused download
  Future<void> resumeDownload(String id) async {
    final downloadTask = _downloads[id];
    if (downloadTask == null) {
      throw Exception('Download not found');
    }

    try {
      await FlutterDownloader.resume(taskId: id);

      // Update status
      _downloads[id] = downloadTask.copyWith(status: DownloadStatus.downloading);
      _progressControllers[id] = StreamController<DownloadProgress>.broadcast();
    } catch (e) {
      throw Exception('Failed to resume download: $e');
    }
  }

  /// Pause a download
  Future<void> pauseDownload(String id) async {
    final downloadTask = _downloads[id];
    if (downloadTask == null) {
      throw Exception('Download not found');
    }

    try {
      await FlutterDownloader.pause(taskId: id);

      // Update status
      _downloads[id] = downloadTask.copyWith(status: DownloadStatus.paused);
      _progressControllers[id]?.close();
      _progressControllers.remove(id);
    } catch (e) {
      throw Exception('Failed to pause download: $e');
    }
  }

  /// Cancel a download
  Future<void> cancelDownload(String id) async {
    final downloadTask = _downloads[id];
    if (downloadTask == null) {
      throw Exception('Download not found');
    }

    try {
      await FlutterDownloader.cancel(taskId: id);

      // Update status
      _downloads[id] = downloadTask.copyWith(status: DownloadStatus.cancelled);
      _progressControllers[id]?.close();
      _progressControllers.remove(id);
    } catch (e) {
      throw Exception('Failed to cancel download: $e');
    }
  }

  /// Delete a completed download
  Future<void> deleteDownload(String id) async {
    AppLogger.i('Deleting download: $id');

    final downloadTask = _downloads[id];
    if (downloadTask == null) {
      AppLogger.e('Download not found for delete: $id');
      throw Exception('Download not found');
    }

    try {
      await FlutterDownloader.remove(taskId: id, shouldDeleteContent: true);

      // Remove from downloads
      _downloads.remove(id);
      _progressControllers[id]?.close();
      _progressControllers.remove(id);

      AppLogger.i('Download deleted: $id');
    } catch (e) {
      AppLogger.e('Failed to delete download: $id, Error: $e');
      throw Exception('Failed to delete download: $e');
    }
  }

  /// Auto-resume downloads that were interrupted
  Future<void> autoResumeDownloads() async {
    AppLogger.i('Auto-resuming downloads...');

    try {
      final tasks = await FlutterDownloader.loadTasks();

      if (tasks != null) {
        for (final task in tasks) {
          if (task.status == DownloadTaskStatus.paused) {
            AppLogger.i('Auto-resuming paused task: ${task.taskId}');
            await FlutterDownloader.resume(taskId: task.taskId!);
          }
        }
      }

      AppLogger.i('Auto-resume completed');
    } catch (e) {
      AppLogger.e('Failed to auto-resume downloads: $e');
    }
  }

  /// Get download directory
  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Use external storage for Android
      final directory = Directory('/storage/emulated/0/Download/OfflineAI');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        AppLogger.i('Created Android download directory: ${directory.path}');
      }
      return directory;
    } else if (Platform.isIOS) {
      // Use documents directory for iOS
      final directory = await getApplicationDocumentsDirectory();
      final appDirectory = Directory('${directory.path}/OfflineAI');
      if (!await appDirectory.exists()) {
        await appDirectory.create(recursive: true);
        AppLogger.i('Created iOS app directory: ${appDirectory.path}');
      }
      return appDirectory;
    } else {
      // Use documents directory for other platforms
      final directory = await getApplicationDocumentsDirectory();
      final appDirectory = Directory('${directory.path}/OfflineAI');
      if (!await appDirectory.exists()) {
        await appDirectory.create(recursive: true);
        AppLogger.i('Created app directory: ${appDirectory.path}');
      }
      return appDirectory;
    }
  }

  /// Convert status code to DownloadTaskStatus
  DownloadTaskStatus _convertStatusFromCode(int statusCode) {
    switch (statusCode) {
      case 0:
        return DownloadTaskStatus.undefined;
      case 1:
        return DownloadTaskStatus.enqueued;
      case 2:
        return DownloadTaskStatus.running;
      case 3:
        return DownloadTaskStatus.complete;
      case 4:
        return DownloadTaskStatus.failed;
      case 5:
        return DownloadTaskStatus.canceled;
      case 6:
        return DownloadTaskStatus.paused;
      default:
        return DownloadTaskStatus.undefined;
    }
  }

  /// Generate unique download ID
  String _generateId() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    AppLogger.log('Generated download ID: $id');
    return id;
  }

  /// Dispose resources
  void dispose() {
    AppLogger.i('Disposing DownloadManagerService');

    // Close all progress controllers
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port.close();

    AppLogger.i('DownloadManagerService disposed');
  }
}

/// Callback function for flutter_downloader (must be top-level)
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  // This callback runs in a background isolate
  // Send progress to main isolate via IsolateNameServer

  AppLogger.log('🔥🔥🔥 CALLBACK CALLED! 🔥🔥🔥');
  AppLogger.log('=== Download Callback (Background Isolate) ===');
  AppLogger.log('Task ID: $id');
  AppLogger.log('Status: $status');
  AppLogger.log('Progress: $progress bytes');

  // Convert status to readable format
  String statusText;
  switch (status) {
    case 0:
      statusText = 'undefined';
      break;
    case 1:
      statusText = 'enqueued';
      break;
    case 2:
      statusText = 'running';
      break;
    case 3:
      statusText = 'complete';
      break;
    case 4:
      statusText = 'failed';
      break;
    case 5:
      statusText = 'canceled';
      break;
    case 6:
      statusText = 'paused';
      break;
    default:
      statusText = 'unknown';
  }

  AppLogger.log('Status Text: $statusText');

  // Send progress to main isolate via IsolateNameServer
  try {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    if (send != null) {
      send.send([id, status, progress]);
      AppLogger.log('Progress sent to main isolate: $id, $status, $progress');
    } else {
      AppLogger.log('SendPort not found, progress not sent: $id, $status, $progress');
    }
  } catch (e) {
    AppLogger.log('Error sending progress to main isolate: $e');
  }

  AppLogger.log('=== End Download Callback ===');
}
