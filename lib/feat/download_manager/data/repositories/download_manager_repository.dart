import 'dart:io';
import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/download_manager/data/models/download_task.dart';
import 'package:offline_ai/feat/download_manager/data/models/download_progress.dart';
import 'package:offline_ai/feat/download_manager/data/services/download_manager_service.dart';

class DownloadManagerRepository {
  final DownloadManagerService _downloadManagerService;

  DownloadManagerRepository(this._downloadManagerService);

  /// Start a new download
  Future<DownloadTask> startDownload({
    required String url,
    required String fileName,
    String? customId,
    Map<String, dynamic>? metadata,
  }) async {
    return await _downloadManagerService.startDownload(
      url: url,
      fileName: fileName,
      customId: customId,
      metadata: metadata,
    );
  }

  /// Resume a paused download
  Future<void> resumeDownload(String id) async {
    await _downloadManagerService.resumeDownload(id);
  }

  /// Auto-resume downloads that were interrupted
  Future<void> autoResumeDownloads() async {
    await _downloadManagerService.autoResumeDownloads();
  }

  /// Pause a download
  Future<void> pauseDownload(String id) async {
    await _downloadManagerService.pauseDownload(id);
  }

  /// Cancel a download
  Future<void> cancelDownload(String id) async {
    await _downloadManagerService.cancelDownload(id);
  }

  /// Get download task by ID
  DownloadTask? getDownloadTask(String id) {
    return _downloadManagerService.getDownloadTask(id);
  }

  /// Get progress stream for a download
  Stream<DownloadProgress>? getProgressStream(String id) {
    return _downloadManagerService.getProgressStream(id);
  }

  /// Check if download is active
  bool isDownloadActive(String id) {
    final task = getDownloadTask(id);
    return task?.isActive ?? false;
  }

  /// Check if download is completed
  bool isDownloadCompleted(String id) {
    final task = getDownloadTask(id);
    return task?.isCompleted ?? false;
  }

  /// Check if download failed
  bool isDownloadFailed(String id) {
    final task = getDownloadTask(id);
    return task?.isFailed ?? false;
  }

  /// Check if download is cancelled
  bool isDownloadCancelled(String id) {
    final task = getDownloadTask(id);
    return task?.isCancelled ?? false;
  }

  /// Get all downloads
  Map<String, DownloadTask> getDownloads() {
    return _downloadManagerService.downloads;
  }

  /// Delete a completed download
  Future<void> deleteDownload(String id) async {
    await _downloadManagerService.deleteDownload(id);
  }

  /// Get download file path
  String? getDownloadFilePath(String id) {
    final task = getDownloadTask(id);
    return task?.filePath;
  }

  /// Check if download file exists
  Future<bool> isDownloadFileExists(String id) async {
    final filePath = getDownloadFilePath(id);
    if (filePath == null) return false;

    final file = File(filePath);
    return await file.exists();
  }

  /// Get download file size
  Future<int?> getDownloadFileSize(String id) async {
    final filePath = getDownloadFilePath(id);
    if (filePath == null) return null;

    final file = File(filePath);
    if (!await file.exists()) return null;

    return await file.length();
  }

  /// Validate download file integrity
  Future<bool> validateDownloadFile(String id, String expectedHash) async {
    // TODO: Implement hash validation
    // For now, just check if file exists and has size > 0
    final fileSize = await getDownloadFileSize(id);
    return fileSize != null && fileSize > 0;
  }

  /// Get download speed for a task
  double getDownloadSpeed(String id) {
    final task = getDownloadTask(id);
    if (task == null) return 0.0;

    final now = DateTime.now();
    final duration = now.difference(task.createdAt);
    if (duration.inSeconds == 0) return 0.0;

    return task.downloadedBytes / duration.inSeconds;
  }

  /// Get estimated time remaining for download
  Duration getEstimatedTimeRemaining(String id) {
    final task = getDownloadTask(id);
    if (task == null) return Duration.zero;

    final speed = getDownloadSpeed(id);
    if (speed <= 0) return Duration.zero;

    final remainingBytes = task.totalBytes - task.downloadedBytes;
    final seconds = remainingBytes / speed;
    return Duration(seconds: seconds.toInt());
  }

  /// Get formatted download progress for task
  String getDownloadProgressText(String id) {
    final task = getDownloadTask(id);
    if (task == null) return '0%';

    return task.progressText;
  }

  /// Get formatted download speed for task
  String getDownloadSpeedText(String id) {
    final speed = getDownloadSpeed(id);
    if (speed <= 0) return '0 MB/s';

    final speedMBps = (speed / 1024 / 1024).toStringAsFixed(2);
    return '$speedMBps MB/s';
  }

  /// Get formatted file size
  String getFormattedFileSize(int bytes) {
    String formattedSize;
    if (bytes < 1024) {
      formattedSize = '$bytes B';
    } else if (bytes < 1024 * 1024) {
      formattedSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      formattedSize = '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    } else {
      formattedSize = '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
    }

    return formattedSize;
  }

  /// Get formatted time remaining
  String getFormattedTimeRemaining(Duration duration) {
    String formattedTime;
    if (duration.inHours > 0) {
      formattedTime = '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      formattedTime = '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      formattedTime = '${duration.inSeconds}s';
    }

    return formattedTime;
  }
}
