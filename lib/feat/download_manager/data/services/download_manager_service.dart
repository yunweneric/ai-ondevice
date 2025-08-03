import 'dart:io';
import 'dart:async';
import 'package:flutter_downloader/flutter_downloader.dart' hide DownloadTask;
import 'package:path_provider/path_provider.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/download_manager/data/models/download_task.dart';
import 'package:offline_ai/feat/download_manager/data/models/download_progress.dart';

class DownloadManagerService {
  final LocalNotificationService _notificationService;
  final PermissionService _permissionService;
  final Map<String, DownloadTask> _downloads = {};
  final Map<String, StreamController<DownloadProgress>> _progressControllers = {};

  DownloadManagerService(this._notificationService) : _permissionService = PermissionService() {
    AppLogger.i('DownloadManagerService initialized');
    _initializeDownloader();
  }

  /// Initialize flutter_downloader
  Future<void> _initializeDownloader() async {
    try {
      await FlutterDownloader.initialize(
        debug: true,
        ignoreSsl: false,
      );

      // Register callback for download events
      FlutterDownloader.registerCallback(downloadCallback);

      AppLogger.i('FlutterDownloader initialized successfully');
    } catch (e) {
      AppLogger.e('Failed to initialize FlutterDownloader: $e');
    }
  }

  /// Update download progress based on flutter_downloader events
  void _updateDownloadProgress(String taskId, DownloadTaskStatus status, int progress) {
    final downloadTask = _downloads[taskId];
    if (downloadTask == null) return;

    // Update download status
    final newStatus = _convertDownloadStatus(status);
    final updatedTask = downloadTask.copyWith(
      status: newStatus,
      downloadedBytes: progress,
    );
    _downloads[taskId] = updatedTask;

    // Emit progress if controller exists
    final controller = _progressControllers[taskId];
    if (controller != null && !controller.isClosed) {
      final downloadProgress = DownloadProgress(
        taskId: taskId,
        downloadedBytes: progress,
        totalBytes: downloadTask.totalBytes,
        progress: downloadTask.totalBytes > 0 ? progress / downloadTask.totalBytes : 0.0,
        speed: _calculateSpeed(progress),
        estimatedTimeRemaining: _calculateEstimatedTime(progress, downloadTask.totalBytes),
        timestamp: DateTime.now(),
      );

      controller.add(downloadProgress);
    }

    // Handle completion
    if (status == DownloadTaskStatus.complete) {
      _handleDownloadComplete(taskId);
    } else if (status == DownloadTaskStatus.failed) {
      _handleDownloadFailed(taskId);
    }
  }

  /// Convert flutter_downloader status to our DownloadStatus
  DownloadStatus _convertDownloadStatus(DownloadTaskStatus status) {
    switch (status) {
      case DownloadTaskStatus.undefined:
        return DownloadStatus.idle;
      case DownloadTaskStatus.enqueued:
        return DownloadStatus.downloading;
      case DownloadTaskStatus.running:
        return DownloadStatus.downloading;
      case DownloadTaskStatus.complete:
        return DownloadStatus.completed;
      case DownloadTaskStatus.failed:
        return DownloadStatus.failed;
      case DownloadTaskStatus.canceled:
        return DownloadStatus.cancelled;
      case DownloadTaskStatus.paused:
        return DownloadStatus.paused;
    }
  }

  /// Calculate download speed
  double _calculateSpeed(int downloadedBytes) {
    // Simple implementation - in production you'd track speed over time
    return downloadedBytes.toDouble();
  }

  /// Calculate estimated time remaining
  Duration _calculateEstimatedTime(int downloadedBytes, int totalBytes) {
    final speed = _calculateSpeed(downloadedBytes);
    if (speed <= 0) return Duration.zero;

    final remainingBytes = totalBytes - downloadedBytes;
    final seconds = remainingBytes / speed;
    return Duration(seconds: seconds.toInt());
  }

  /// Handle download completion
  void _handleDownloadComplete(String taskId) async {
    AppLogger.i('Download completed: $taskId');

    final downloadTask = _downloads[taskId];
    if (downloadTask != null) {
      _downloads[taskId] = downloadTask.copyWith(
        status: DownloadStatus.completed,
        completedAt: DateTime.now(),
      );

      // Show completion notification
      await _showCompletionNotification(taskId);
    }
  }

  /// Handle download failure
  void _handleDownloadFailed(String taskId) async {
    AppLogger.e('Download failed: $taskId');

    final downloadTask = _downloads[taskId];
    if (downloadTask != null) {
      _downloads[taskId] = downloadTask.copyWith(
        status: DownloadStatus.failed,
        errorMessage: 'Download failed',
      );

      // Show error notification
      await _showErrorNotification(taskId, 'Download failed');
    }
  }

  /// Get all downloads
  Map<String, DownloadTask> get downloads => Map.unmodifiable(_downloads);

  /// Get download task by ID
  DownloadTask? getDownloadTask(String id) => _downloads[id];

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

    AppLogger.i('Starting download: ID=$id, URL=$url, FileName=$fileName');

    // Check permissions
    final permissionsGranted = await _permissionService.requestDownloadPermissions();
    if (!permissionsGranted) {
      AppLogger.e('Download permissions not granted for download: $id');
      throw Exception('Download permissions not granted');
    }

    // Get download directory
    final directory = await getDownloadDirectory();
    final savedDir = directory.path;

    AppLogger.i('Download directory: $savedDir for download: $id');

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

    AppLogger.i('Download task created: $id, Status: ${downloadTask.status}');

    // Start flutter_downloader download
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      headers: {}, // Add any required headers here
      savedDir: savedDir,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: false,
    );

    AppLogger.i('FlutterDownloader task created: TaskID=$taskId, DownloadID=$id');

    // Update download task with task ID
    _downloads[id] = downloadTask.copyWith(id: taskId);

    return downloadTask;
  }

  /// Resume a paused download
  Future<void> resumeDownload(String id) async {
    AppLogger.i('Resuming download: $id');

    final downloadTask = _downloads[id];
    if (downloadTask == null) {
      AppLogger.e('Download not found for resume: $id');
      throw Exception('Download not found');
    }

    try {
      await FlutterDownloader.resume(taskId: id);

      // Update status
      _downloads[id] = downloadTask.copyWith(status: DownloadStatus.downloading);
      _progressControllers[id] = StreamController<DownloadProgress>.broadcast();

      AppLogger.i('Download resumed: $id');
    } catch (e) {
      AppLogger.e('Failed to resume download: $id, Error: $e');
      throw Exception('Failed to resume download: $e');
    }
  }

  /// Pause a download
  Future<void> pauseDownload(String id) async {
    AppLogger.i('Pausing download: $id');

    final downloadTask = _downloads[id];
    if (downloadTask == null) {
      AppLogger.e('Download not found for pause: $id');
      throw Exception('Download not found');
    }

    try {
      await FlutterDownloader.pause(taskId: id);

      // Update status
      _downloads[id] = downloadTask.copyWith(status: DownloadStatus.paused);
      _progressControllers[id]?.close();
      _progressControllers.remove(id);

      AppLogger.i('Download paused: $id');
    } catch (e) {
      AppLogger.e('Failed to pause download: $id, Error: $e');
      throw Exception('Failed to pause download: $e');
    }
  }

  /// Cancel a download
  Future<void> cancelDownload(String id) async {
    AppLogger.i('Cancelling download: $id');

    final downloadTask = _downloads[id];
    if (downloadTask == null) {
      AppLogger.e('Download not found for cancel: $id');
      throw Exception('Download not found');
    }

    try {
      await FlutterDownloader.cancel(taskId: id);

      // Update status
      _downloads[id] = downloadTask.copyWith(status: DownloadStatus.cancelled);
      _progressControllers[id]?.close();
      _progressControllers.remove(id);

      AppLogger.i('Download cancelled: $id');
    } catch (e) {
      AppLogger.e('Failed to cancel download: $id, Error: $e');
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

  /// Generate unique download ID
  String _generateId() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    AppLogger.log('Generated download ID: $id');
    return id;
  }

  /// Show completion notification
  Future<void> _showCompletionNotification(String id) async {
    final downloadTask = _downloads[id];
    if (downloadTask == null) return;

    AppLogger.i('Showing completion notification: $id');

    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    if (!notificationsEnabled) {
      AppLogger.log('Notifications not enabled, skipping completion notification');
      return;
    }

    await _notificationService.showDownloadComplete(
      id: id,
      title: 'Download Complete',
      body: '${downloadTask.fileName} has been downloaded successfully',
    );
  }

  /// Show error notification
  Future<void> _showErrorNotification(String id, String error) async {
    final downloadTask = _downloads[id];
    if (downloadTask == null) return;

    AppLogger.e('Showing error notification: ID=$id, Error=$error');

    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    if (!notificationsEnabled) {
      AppLogger.log('Notifications not enabled, skipping error notification');
      return;
    }

    await _notificationService.showDownloadError(
      id: id,
      title: 'Download Failed',
      body: 'Failed to download ${downloadTask.fileName}',
    );
  }

  /// Dispose resources
  void dispose() {
    AppLogger.i('Disposing DownloadManagerService');

    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();

    AppLogger.i('DownloadManagerService disposed');
  }
}

/// Callback function for flutter_downloader (must be top-level)
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  // This callback runs in a background isolate
  // For now, we'll handle progress updates through polling
  AppLogger.log('Download callback: ID=$id, Status=$status, Progress=$progress');
}
