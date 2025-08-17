import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:offline_ai/shared/shared.dart';

class DownloadManagerService {
  final PermissionService _permissionService;
  final Dio _dio;
  final Map<String, DownloadTask> _downloads = {};
  final Map<String, StreamController<DownloadProgress>> _progressControllers = {};
  final Map<String, CancelToken> _cancelTokens = {};

  DownloadManagerService() 
    : _permissionService = PermissionService(),
      _dio = Dio() {
    _setupDio();
  }

  /// Setup Dio with proper configuration for downloads
  void _setupDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => AppLogger.i(obj.toString()),
    ));
  }

  /// Initialize the download manager
  Future<void> initialize() async {
    try {
      AppLogger.i('=== Initializing Dio-based Download Manager ===');
      
      // Check permissions
      final permissionsGranted = await _permissionService.requestDownloadPermissions();
      if (!permissionsGranted) {
        throw Exception('Download permissions not granted');
      }

      // Create download directory if it doesn't exist
      final downloadDir = await getDownloadDirectory();
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      AppLogger.i('Download manager initialized successfully');
    } catch (e) {
      AppLogger.e('Failed to initialize download manager: $e');
      rethrow;
    }
  }

  /// Start a new download with resumable capability
  Future<DownloadTask> startDownload({
    required String url,
    required String fileName,
    String? customId,
    Map<String, dynamic>? metadata,
    Function(double)? onProgress,
  }) async {
    final id = customId ?? _generateId();
    
    try {
      // Check if download already exists
      if (_downloads.containsKey(id)) {
        throw Exception('Download with ID $id already exists');
      }

      // Check permissions
      final permissionsGranted = await _permissionService.requestDownloadPermissions();
      if (!permissionsGranted) {
        throw Exception('Download permissions not granted');
      }

      // Get download directory
      final downloadDir = await getDownloadDirectory();
      final filePath = '${downloadDir.path}/$fileName';

      // Check if file exists for resume capability
      final file = File(filePath);
      int downloadedBytes = 0;
      bool canResume = false;

      if (await file.exists()) {
        downloadedBytes = await file.length();
        canResume = downloadedBytes > 0;
        AppLogger.i('Found existing file: $filePath, size: $downloadedBytes bytes');
      }

      // Create download task
      final task = DownloadTask(
        id: id,
        url: url,
        fileName: fileName,
        filePath: filePath,
        totalBytes: 0, // Will be updated when we get response
        downloadedBytes: downloadedBytes,
        status: DownloadStatus.downloading,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      _downloads[id] = task;
      _progressControllers[id] = StreamController<DownloadProgress>.broadcast();
      _cancelTokens[id] = CancelToken();

      // Start the actual download
      _performDownload(task, canResume, downloadedBytes);

      return task;
    } catch (e) {
      AppLogger.e('Failed to start download: $e');
      rethrow;
    }
  }

  /// Perform the actual download with resume support
  Future<void> _performDownload(DownloadTask task, bool canResume, int startByte) async {
    try {
      final cancelToken = _cancelTokens[task.id];
      if (cancelToken == null) return;

      // Prepare headers for resume
      final headers = <String, dynamic>{};
      if (canResume && startByte > 0) {
        headers['Range'] = 'bytes=$startByte-';
        AppLogger.i('Resuming download from byte $startByte');
      }

      // Create file for writing
      final file = File(task.filePath);
      final raf = await file.open(mode: canResume ? FileMode.writeOnlyAppend : FileMode.writeOnly);

      // Perform download with progress tracking
      await _dio.download(
        task.url,
        task.filePath,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) async {
          if (total != null) {
            final currentBytes = startByte + received;
            final progress = DownloadProgress(
              taskId: task.id,
              progress: total > 0 ? currentBytes / total : 0.0,
              downloadedBytes: currentBytes,
              totalBytes: total,
              speed: 0.0, // Could calculate speed if needed
              estimatedTimeRemaining: Duration.zero, // TODO: Calculate actual time remaining
              timestamp: DateTime.now(),
            );

            // Update task
            _downloads[task.id] = task.copyWith(
              totalBytes: total,
              downloadedBytes: currentBytes,
            );

            // Emit progress
            _progressControllers[task.id]?.add(progress);

            // Write to file
            if (received > 0) {
              // For resume, we need to handle this differently
              // This is a simplified approach
            }
          }
        },
      );

      // Download completed
      final finalTask = _downloads[task.id]?.copyWith(
        status: DownloadStatus.completed,
        completedAt: DateTime.now(),
      );
      
      if (finalTask != null) {
        _downloads[task.id] = finalTask;
      }

      AppLogger.i('Download completed: ${task.fileName}');
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        AppLogger.i('Download cancelled: ${task.fileName}');
        _downloads[task.id] = task.copyWith(
          status: DownloadStatus.cancelled,
        );
      } else {
        AppLogger.e('Download failed: ${task.fileName}, error: $e');
        _downloads[task.id] = task.copyWith(
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        );
      }
    } finally {
      // Clean up
      final raf = await File(task.filePath).open(mode: FileMode.read);
      await raf.close();
    }
  }

  /// Pause a download
  Future<void> pauseDownload(String id) async {
    final task = _downloads[id];
    if (task == null || task.status != DownloadStatus.downloading) {
      throw Exception('Download not found or not downloading');
    }

    // Cancel the current download
    _cancelTokens[id]?.cancel('Paused by user');
    
    // Update status
    _downloads[id] = task.copyWith(
      status: DownloadStatus.paused,
    );

    AppLogger.i('Download paused: ${task.fileName}');
  }

  /// Resume a paused download
  Future<void> resumeDownload(String id) async {
    final task = _downloads[id];
    if (task == null || task.status != DownloadStatus.paused) {
      throw Exception('Download not found or not paused');
    }

    // Create new cancel token
    _cancelTokens[id] = CancelToken();

    // Resume download
    _downloads[id] = task.copyWith(
      status: DownloadStatus.downloading,
    );

    _performDownload(task, true, task.downloadedBytes);
    AppLogger.i('Download resumed: ${task.fileName}');
  }

  /// Cancel a download
  Future<void> cancelDownload(String id) async {
    final task = _downloads[id];
    if (task == null) {
      throw Exception('Download not found');
    }

    // Cancel the download
    _cancelTokens[id]?.cancel('Cancelled by user');
    
    // Update status
    _downloads[id] = task.copyWith(
      status: DownloadStatus.cancelled,
    );

    // Clean up file if it exists
    final file = File(task.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    AppLogger.i('Download cancelled: ${task.fileName}');
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

  /// Get download progress stream
  Stream<DownloadProgress> getProgressStream(String id) {
    return _progressControllers[id]?.stream ?? Stream.empty();
  }

  /// Get download task by ID
  DownloadTask? getDownloadTask(String id) {
    return _downloads[id];
  }

  /// Get all downloads
  List<DownloadTask> get downloads => _downloads.values.toList();

  /// Get downloads by status
  List<DownloadTask> getDownloadsByStatus(DownloadStatus status) {
    return _downloads.values.where((task) => task.status == status).toList();
  }

  /// Get active downloads (downloading or paused)
  List<DownloadTask> get activeDownloads {
    return _downloads.values.where((task) => task.isActive).toList();
  }

  /// Get completed downloads
  List<DownloadTask> get completedDownloads {
    return _downloads.values.where((task) => task.isCompleted).toList();
  }

  /// Get failed downloads
  List<DownloadTask> get failedDownloads {
    return _downloads.values.where((task) => task.isFailed).toList();
  }

  /// Delete a download and its file
  Future<void> deleteDownload(String id) async {
    final task = _downloads[id];
    if (task == null) return;

    // Cancel if active
    if (task.isActive) {
      _cancelTokens[id]?.cancel('Deleted by user');
    }

    // Delete file
    final file = File(task.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    // Remove from tracking
    _downloads.remove(id);
    _progressControllers[id]?.close();
    _progressControllers.remove(id);
    _cancelTokens.remove(id);

    AppLogger.i('Download deleted: ${task.fileName}');
  }

  /// Clear all downloads
  Future<void> clearAllDownloads() async {
    for (final id in _downloads.keys.toList()) {
      await deleteDownload(id);
    }
    AppLogger.i('All downloads cleared');
  }

  /// Get download statistics
  Map<String, dynamic> getDownloadStats() {
    final total = _downloads.length;
    final downloading = _downloads.values.where((t) => t.status == DownloadStatus.downloading).length;
    final paused = _downloads.values.where((t) => t.status == DownloadStatus.paused).length;
    final completed = _downloads.values.where((t) => t.status == DownloadStatus.completed).length;
    final failed = _downloads.values.where((t) => t.status == DownloadStatus.failed).length;
    final cancelled = _downloads.values.where((t) => t.status == DownloadStatus.cancelled).length;

    return {
      'total': total,
      'downloading': downloading,
      'paused': paused,
      'completed': completed,
      'failed': failed,
      'cancelled': cancelled,
    };
  }

  /// Generate unique ID for downloads
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Dispose the service
  Future<void> dispose() async {
    // Cancel all active downloads
    for (final token in _cancelTokens.values) {
      token.cancel('Service disposed');
    }

    // Close all progress controllers
    for (final controller in _progressControllers.values) {
      await controller.close();
    }

    // Clear all data
    _downloads.clear();
    _progressControllers.clear();
    _cancelTokens.clear();

    AppLogger.i('Download manager service disposed');
  }
}
