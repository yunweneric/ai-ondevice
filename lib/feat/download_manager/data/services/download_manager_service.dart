import 'dart:io';
import 'package:background_downloader/background_downloader.dart' as bg;
import 'package:path_provider/path_provider.dart';
import 'package:offline_ai/shared/shared.dart';

class DownloadManagerService {
  final PermissionService _permissionService;

  DownloadManagerService() : _permissionService = PermissionService();

  /// Initialize background_downloader
  Future<void> initializeDownloader() async {
    try {
      AppLogger.i('=== Initializing Background Downloader ===');

      // Configure the downloader
      await bg.FileDownloader().configureNotification(
        running: bg.TaskNotification('Downloading', 'file: {filename}'),
        complete: bg.TaskNotification('Download finished', 'file: {filename}'),
        progressBar: true,
      );

      // Start the downloader and track tasks
      AppLogger.i('Starting FileDownloader...');
      await bg.FileDownloader().start();
      AppLogger.i('FileDownloader started successfully');

      AppLogger.i('Starting task tracking...');
      await bg.FileDownloader().trackTasks();
      AppLogger.i('Task tracking started successfully');

      // Test if the downloader is working
      AppLogger.i('Testing downloader functionality...');
      try {
        final testTask = bg.DownloadTask(
          url: 'https://httpbin.org/bytes/1024', // Small test file
          filename: 'test.txt',
          directory: (await getDownloadDirectory()).path,
          updates: bg.Updates.statusAndProgress,
        );

        AppLogger.i('Test task created, attempting download...');
        final testResult = await bg.FileDownloader().download(testTask);
        AppLogger.i('Test download completed with status: ${testResult.status}');

        // Clean up test file
        try {
          final testFile = File('${(await getDownloadDirectory()).path}/test.txt');
          if (await testFile.exists()) {
            await testFile.delete();
            AppLogger.i('Test file cleaned up');
          }
        } catch (e) {
          AppLogger.e('Failed to clean up test file: $e');
        }
      } catch (e) {
        AppLogger.e('Test download failed: $e');
        AppLogger.e('This indicates a fundamental issue with the downloader');
      }

      AppLogger.i('Background downloader initialized successfully');
    } catch (e) {
      AppLogger.e('Failed to initialize background downloader: $e');
      AppLogger.e('Stack trace: ${StackTrace.current}');
    }
  }

  /// Start a new download and wait for completion
  Future<DownloadTask> startDownload({
    required String url,
    required String fileName,
    String? customId,
    Map<String, dynamic>? metadata,
    Function(double)? onProgress,
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

    // Create background_downloader task
    final backgroundTask = bg.DownloadTask(
      url: url,
      filename: fileName,
      directory: savedDir,
      updates: bg.Updates.statusAndProgress,
      metaData: id,
      requiresWiFi: false,
      retries: 3,
      allowPause: true,
    );

    AppLogger.i('=== Starting Background Download ===');
    AppLogger.i('Custom ID: $id');
    AppLogger.i('URL: $url');
    AppLogger.i('File: $fileName');
    AppLogger.i('Directory: $savedDir');

    // Start the download and wait for result
    AppLogger.i('Calling FileDownloader().download...');
    final result = await bg.FileDownloader().download(
      backgroundTask,
      onProgress: (progress) {
        AppLogger.log('Progress: ${(progress * 100).toStringAsFixed(1)}%');
        onProgress?.call(progress);
      },
      onStatus: (status) {
        AppLogger.log('Status: $status');
        AppLogger.log('Status type: ${status.runtimeType}');
      },
    );
    AppLogger.i('Download call completed');

    AppLogger.i('Download completed with status: ${result.status}');

    // Create our download task based on the result
    final downloadTask = DownloadTask(
      id: backgroundTask.taskId,
      url: url,
      fileName: fileName,
      filePath: '$savedDir/$fileName',
      totalBytes: 0, // Will be updated from database
      downloadedBytes: 0,
      status: _convertTaskStatus(result.status),
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    AppLogger.i('Download task created successfully');
    return downloadTask;
  }

  /// Resume a paused download
  Future<void> resumeDownload(String id) async {
    try {
      AppLogger.i('Resume download requested: $id');
      // For now, just log since we need to get the actual task
      AppLogger.i('Download resume logged: $id');
    } catch (e) {
      throw Exception('Failed to resume download: $e');
    }
  }

  /// Pause a download
  Future<void> pauseDownload(String id) async {
    try {
      AppLogger.i('Pause download requested: $id');
      // For now, just log since we need to get the actual task
      AppLogger.i('Download pause logged: $id');
    } catch (e) {
      throw Exception('Failed to pause download: $e');
    }
  }

  /// Cancel a download
  Future<void> cancelDownload(String id) async {
    try {
      AppLogger.i('Cancel download requested: $id');
      // For now, just log since we need to get the actual task
      AppLogger.i('Download cancel logged: $id');
    } catch (e) {
      throw Exception('Failed to cancel download: $e');
    }
  }

  /// Delete a completed download
  Future<void> deleteDownload(String id) async {
    AppLogger.i('Deleting download: $id');

    try {
      // For now, just log since we need to get the actual task
      AppLogger.i('Download delete logged: $id');
    } catch (e) {
      AppLogger.e('Failed to delete download: $id, Error: $e');
      throw Exception('Failed to delete download: $e');
    }
  }

  /// Auto-resume downloads that were interrupted
  Future<void> autoResumeDownloads() async {
    AppLogger.i('Auto-resuming downloads...');

    try {
      final records = await bg.FileDownloader().database.allRecords();

      for (final record in records) {
        if (record.status == bg.TaskStatus.paused) {
          AppLogger.i('Auto-resuming paused task: ${record.taskId}');
          // For now, just log since we need to get the actual task
          AppLogger.i('Auto-resume logged for: ${record.taskId}');
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

  /// Convert background_downloader TaskStatus to our DownloadStatus
  DownloadStatus _convertTaskStatus(bg.TaskStatus status) {
    switch (status) {
      case bg.TaskStatus.enqueued:
        return DownloadStatus.downloading;
      case bg.TaskStatus.running:
        return DownloadStatus.downloading;
      case bg.TaskStatus.complete:
        return DownloadStatus.completed;
      case bg.TaskStatus.failed:
        return DownloadStatus.failed;
      case bg.TaskStatus.canceled:
        return DownloadStatus.cancelled;
      case bg.TaskStatus.paused:
        return DownloadStatus.paused;
      case bg.TaskStatus.notFound:
        return DownloadStatus.failed;
      case bg.TaskStatus.waitingToRetry:
        return DownloadStatus.downloading;
    }
  }

  /// Generate unique download ID
  String _generateId() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    AppLogger.log('Generated download ID: $id');
    return id;
  }

  /// Get all downloads from database
  Future<Map<String, DownloadTask>> get downloads async {
    final downloads = <String, DownloadTask>{};

    try {
      // Get all records from database
      final records = await bg.FileDownloader().database.allRecords();

      for (final record in records) {
        final downloadTask = DownloadTask(
          id: record.taskId,
          url: record.task.url,
          fileName: record.task.filename,
          filePath: record.task.filePath.toString(),
          totalBytes: record.expectedFileSize,
          downloadedBytes: (record.expectedFileSize * record.progress).round(),
          status: _convertTaskStatus(record.status),
          createdAt: DateTime.now(),
          metadata: record.task.metaData != null ? {'customId': record.task.metaData} : null,
        );
        downloads[record.taskId] = downloadTask;
      }
    } catch (e) {
      AppLogger.e('Error getting downloads from database: $e');
    }

    return downloads;
  }

  /// Get download task by ID from database
  Future<DownloadTask?> getDownloadTask(String id) async {
    try {
      final record = await bg.FileDownloader().database.recordForId(id);
      if (record == null) return null;

      return DownloadTask(
        id: record.taskId,
        url: record.task.url,
        fileName: record.task.filename,
        filePath: record.task.filePath.toString(),
        totalBytes: record.expectedFileSize,
        downloadedBytes: (record.expectedFileSize * record.progress).round(),
        status: _convertTaskStatus(record.status),
        createdAt: DateTime.now(),
        metadata: record.task.metaData != null ? {'customId': record.task.metaData} : null,
      );
    } catch (e) {
      AppLogger.e('Error getting download task: $e');
      return null;
    }
  }

  /// Get progress stream for a download (not used with direct download method)
  Stream<DownloadProgress>? getProgressStream(String id) {
    // This method is kept for compatibility but won't be used
    // since we're using the direct download method
    return null;
  }

  /// Dispose resources
  void dispose() {
    AppLogger.i('Disposing DownloadManagerService');
    AppLogger.i('DownloadManagerService disposed');
  }
}
