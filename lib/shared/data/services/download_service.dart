import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:offline_ai/shared/shared.dart';

enum DownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

class DownloadProgress {
  final int downloadedBytes;
  final int totalBytes;
  final double progress;
  final double speed; // bytes per second
  final Duration estimatedTimeRemaining;

  DownloadProgress({
    required this.downloadedBytes,
    required this.totalBytes,
    required this.progress,
    required this.speed,
    required this.estimatedTimeRemaining,
  });
}

class DownloadInfo {
  final String id;
  final String url;
  final String fileName;
  final String filePath;
  final int totalBytes;
  final int downloadedBytes;
  final DownloadStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  DownloadInfo({
    required this.id,
    required this.url,
    required this.fileName,
    required this.filePath,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  DownloadInfo copyWith({
    String? id,
    String? url,
    String? fileName,
    String? filePath,
    int? totalBytes,
    int? downloadedBytes,
    DownloadStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return DownloadInfo(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DownloadService {
  final Dio _dio;
  final LocalNotificationService _notificationService;
  final PermissionService _permissionService;
  final Map<String, DownloadInfo> _downloads = {};
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, StreamController<DownloadProgress>> _progressControllers = {};

  DownloadService(this._dio, this._notificationService) : _permissionService = PermissionService() {
    AppLogger.i('DownloadService initialized');
  }

  /// Get all downloads
  Map<String, DownloadInfo> get downloads => Map.unmodifiable(_downloads);

  /// Auto-resume downloads that were interrupted
  Future<void> autoResumeDownloads() async {
    AppLogger.i('Auto-resuming downloads...');

    for (final entry in _downloads.entries) {
      final id = entry.key;
      final downloadInfo = entry.value;

      // Check if download was interrupted (paused or has partial file)
      final canResume = downloadInfo.status == DownloadStatus.paused ||
          (await _hasPartialFile(downloadInfo.filePath) && downloadInfo.status != DownloadStatus.completed);

      if (canResume) {
        AppLogger.i('Auto-resuming download: $id');
        try {
          await resumeDownload(id);
        } catch (e) {
          AppLogger.e('Failed to auto-resume download $id: $e');
        }
      }
    }
  }

  /// Get download info by ID
  DownloadInfo? getDownloadInfo(String id) => _downloads[id];

  /// Get progress stream for a download
  Stream<DownloadProgress>? getProgressStream(String id) => _progressControllers[id]?.stream;

  /// Start a new download
  Future<DownloadInfo> startDownload({
    required String url,
    required String fileName,
    String? customId,
  }) async {
    final id = customId ?? _generateId();

    AppLogger.i('Starting download: ID=$id, URL=$url, FileName=$fileName');

    // Check permissions
    final permissionsGranted = await _permissionService.requestDownloadPermissions();
    if (!permissionsGranted) {
      AppLogger.e('Download permissions not granted for download: $id');
      throw Exception('Download permissions not granted');
    }

    AppLogger.i('Storage permission granted for download: $id');

    // Get download directory
    final directory = await getDownloadDirectory();
    final filePath = '${directory.path}/$fileName';

    AppLogger.i('Download path: $filePath for download: $id');

    // Create download info
    final downloadInfo = DownloadInfo(
      id: id,
      url: url,
      fileName: fileName,
      filePath: filePath,
      totalBytes: 0,
      downloadedBytes: 0,
      status: DownloadStatus.downloading,
      createdAt: DateTime.now(),
    );

    _downloads[id] = downloadInfo;
    _progressControllers[id] = StreamController<DownloadProgress>.broadcast();

    AppLogger.i('Download info created: $id, Status: ${downloadInfo.status}');

    // Start background download
    _downloadFile(id, url, filePath);

    return downloadInfo;
  }

  /// Resume a paused download
  Future<void> resumeDownload(String id) async {
    AppLogger.i('Resuming download: $id');

    final downloadInfo = _downloads[id];
    if (downloadInfo == null) {
      AppLogger.e('Download not found for resume: $id');
      throw Exception('Download not found');
    }

    // Check if download is paused or if we have a partial file
    final canResume = downloadInfo.status == DownloadStatus.paused ||
        (await _hasPartialFile(downloadInfo.filePath) && downloadInfo.status != DownloadStatus.completed);

    if (!canResume) {
      AppLogger.e('Download cannot be resumed: $id, Status: ${downloadInfo.status}');
      throw Exception('Download cannot be resumed');
    }

    // Update status
    _downloads[id] = downloadInfo.copyWith(status: DownloadStatus.downloading);
    _progressControllers[id] = StreamController<DownloadProgress>.broadcast();

    AppLogger.i('Download status updated to downloading: $id');

    // Resume download
    _downloadFile(id, downloadInfo.url, downloadInfo.filePath, downloadInfo.downloadedBytes);
  }

  /// Check if a partial file exists and can be resumed
  Future<bool> _hasPartialFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final fileSize = await file.length();
      return fileSize > 0;
    } catch (e) {
      AppLogger.e('Error checking partial file: $e');
      return false;
    }
  }

  /// Pause a download
  Future<void> pauseDownload(String id) async {
    AppLogger.i('Pausing download: $id');

    final downloadInfo = _downloads[id];
    if (downloadInfo == null) {
      AppLogger.e('Download not found for pause: $id');
      throw Exception('Download not found');
    }

    if (downloadInfo.status != DownloadStatus.downloading) {
      AppLogger.e('Download is not active: $id, Status: ${downloadInfo.status}');
      throw Exception('Download is not active');
    }

    // Cancel current download
    _cancelTokens[id]?.cancel('Paused by user');
    _cancelTokens.remove(id);

    // Update status
    _downloads[id] = downloadInfo.copyWith(status: DownloadStatus.paused);
    _progressControllers[id]?.close();
    _progressControllers.remove(id);

    AppLogger.i('Download paused: $id');
  }

  /// Cancel a download
  Future<void> cancelDownload(String id) async {
    AppLogger.i('Cancelling download: $id');

    final downloadInfo = _downloads[id];
    if (downloadInfo == null) {
      AppLogger.e('Download not found for cancel: $id');
      throw Exception('Download not found');
    }

    // Cancel current download
    _cancelTokens[id]?.cancel('Cancelled by user');
    _cancelTokens.remove(id);

    // Delete partial file
    final file = File(downloadInfo.filePath);
    if (await file.exists()) {
      await file.delete();
      AppLogger.i('Partial file deleted: ${downloadInfo.filePath}');
    }

    // Update status
    _downloads[id] = downloadInfo.copyWith(status: DownloadStatus.cancelled);
    _progressControllers[id]?.close();
    _progressControllers.remove(id);

    AppLogger.i('Download cancelled: $id');
  }

  /// Delete a completed download
  Future<void> deleteDownload(String id) async {
    AppLogger.i('Deleting download: $id');

    final downloadInfo = _downloads[id];
    if (downloadInfo == null) {
      AppLogger.e('Download not found for delete: $id');
      throw Exception('Download not found');
    }

    // Delete file
    final file = File(downloadInfo.filePath);
    if (await file.exists()) {
      await file.delete();
      AppLogger.i('Download file deleted: ${downloadInfo.filePath}');
    }

    // Remove from downloads
    _downloads.remove(id);
    _progressControllers[id]?.close();
    _progressControllers.remove(id);

    AppLogger.i('Download deleted: $id');
  }

  /// Get download directory
  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Use external storage for Android to save to user's device storage
      final directory = Directory('/storage/emulated/0/Download/OfflineAI');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        AppLogger.i('Created Android download directory: ${directory.path}');
      }
      return directory;
    } else if (Platform.isIOS) {
      // Use documents directory for iOS (this is persistent user storage)
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

  /// Download file with progress tracking
  Future<void> _downloadFile(String id, String url, String filePath, [int startByte = 0]) async {
    AppLogger.i('Starting file download: ID=$id, URL=$url, Path=$filePath, StartByte=$startByte');

    final cancelToken = CancelToken();
    _cancelTokens[id] = cancelToken;

    try {
      final file = File(filePath);
      final fileExists = await file.exists();

      // Create file if it doesn't exist
      if (!fileExists) {
        await file.create(recursive: true);
        AppLogger.i('Created download file: $filePath');
      }

      AppLogger.i('Starting Dio download for: $id');

      // Configure Dio for download
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            final downloadedBytes = received + startByte;
            final progress = downloadedBytes / total;
            final speed = _calculateSpeed(downloadedBytes);
            final estimatedTime = _calculateEstimatedTime(downloadedBytes, total, speed);

            final downloadProgress = DownloadProgress(
              downloadedBytes: downloadedBytes,
              totalBytes: total,
              progress: progress,
              speed: speed,
              estimatedTimeRemaining: estimatedTime,
            );

            // Update download info
            _downloads[id] = _downloads[id]!.copyWith(
              downloadedBytes: downloadedBytes,
              totalBytes: total,
            );

            // Emit progress
            _progressControllers[id]?.add(downloadProgress);

            // Update notification
            await _updateNotification(id, downloadProgress);

            AppLogger.log(
                'Download progress: ID=$id, Progress=${(progress * 100).toStringAsFixed(1)}%, Speed=${(speed / 1024 / 1024).toStringAsFixed(2)}MB/s');
          }
        },
        options: Options(
          headers: startByte > 0 ? {'Range': 'bytes=$startByte-'} : null,
        ),
      );

      AppLogger.i('Download completed successfully: $id');

      // Mark as completed
      _downloads[id] = _downloads[id]!.copyWith(
        status: DownloadStatus.completed,
        completedAt: DateTime.now(),
      );

      // Show completion notification
      await _showCompletionNotification(id);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Download was cancelled or paused
        AppLogger.i('Download was cancelled/paused: $id');
        return;
      }

      AppLogger.e('Download failed: ID=$id, Error=$e');

      // Mark as failed
      _downloads[id] = _downloads[id]!.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );

      // Show error notification
      await _showErrorNotification(id, e.toString());
    } finally {
      _cancelTokens.remove(id);
      _progressControllers[id]?.close();
      _progressControllers.remove(id);

      AppLogger.i('Download cleanup completed: $id');
    }
  }

  /// Calculate download speed
  double _calculateSpeed(int downloadedBytes) {
    // Simple speed calculation - in a real implementation, you'd track speed over time
    return downloadedBytes.toDouble();
  }

  /// Calculate estimated time remaining
  Duration _calculateEstimatedTime(int downloadedBytes, int totalBytes, double speed) {
    if (speed <= 0) return Duration.zero;

    final remainingBytes = totalBytes - downloadedBytes;
    final seconds = remainingBytes / speed;
    return Duration(seconds: seconds.toInt());
  }

  /// Update download notification
  Future<void> _updateNotification(String id, DownloadProgress progress) async {
    final downloadInfo = _downloads[id];
    if (downloadInfo == null) return;

    final progressPercent = (progress.progress * 100).toInt();
    final speedMBps = (progress.speed / 1024 / 1024).toStringAsFixed(2);

    AppLogger.log('Updating notification: ID=$id, Progress=$progressPercent%, Speed=$speedMBps MB/s');

    // Check if notifications are enabled before showing
    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    if (!notificationsEnabled) {
      AppLogger.log('Notifications not enabled, skipping notification update');
      return;
    }

    await _notificationService.showDownloadProgress(
      id: id,
      title: 'Downloading ${downloadInfo.fileName}',
      progress: progressPercent,
      speed: '$speedMBps MB/s',
    );
  }

  /// Show completion notification
  Future<void> _showCompletionNotification(String id) async {
    final downloadInfo = _downloads[id];
    if (downloadInfo == null) return;

    AppLogger.i('Showing completion notification: $id');

    // Check if notifications are enabled before showing
    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    if (!notificationsEnabled) {
      AppLogger.log('Notifications not enabled, skipping completion notification');
      return;
    }

    await _notificationService.showDownloadComplete(
      id: id,
      title: 'Download Complete',
      body: '${downloadInfo.fileName} has been downloaded successfully',
    );
  }

  /// Show error notification
  Future<void> _showErrorNotification(String id, String error) async {
    final downloadInfo = _downloads[id];
    if (downloadInfo == null) return;

    AppLogger.e('Showing error notification: ID=$id, Error=$error');

    // Check if notifications are enabled before showing
    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    if (!notificationsEnabled) {
      AppLogger.log('Notifications not enabled, skipping error notification');
      return;
    }

    await _notificationService.showDownloadError(
      id: id,
      title: 'Download Failed',
      body: 'Failed to download ${downloadInfo.fileName}',
    );
  }

  /// Dispose resources
  void dispose() {
    AppLogger.i('Disposing DownloadService');

    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _cancelTokens.clear();

    AppLogger.i('DownloadService disposed');
  }
}
