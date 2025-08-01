import 'dart:io';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/model_mangement/data/models/ai_model.dart';

class ModelDownloadService extends DownloadService {
  ModelDownloadService(super.dio, super.notificationService) {
    AppLogger.i('ModelDownloadService initialized');
  }

  /// Download an AI model
  Future<DownloadInfo> downloadModel({
    required AiModel model,
    String? customId,
  }) async {
    AppLogger.i('Starting model download: Model=${model.name}, ID=${model.id}, Size=${model.modelSize}');

    final fileName = _generateModelFileName(model);
    AppLogger.i('Generated filename: $fileName for model: ${model.name}');

    return await startDownload(
      url: model.url,
      fileName: fileName,
      customId: customId ?? 'model_${model.id}',
    );
  }

  /// Resume downloading a model
  Future<void> resumeModelDownload(String modelId) async {
    AppLogger.i('Resuming model download: $modelId');
    final downloadId = 'model_$modelId';
    await resumeDownload(downloadId);
  }

  /// Auto-resume model downloads that were interrupted
  Future<void> autoResumeModelDownloads() async {
    AppLogger.i('Auto-resuming model downloads...');
    await autoResumeDownloads();
  }

  /// Pause downloading a model
  Future<void> pauseModelDownload(String modelId) async {
    AppLogger.i('Pausing model download: $modelId');
    final downloadId = 'model_$modelId';
    await pauseDownload(downloadId);
  }

  /// Cancel downloading a model
  Future<void> cancelModelDownload(String modelId) async {
    AppLogger.i('Cancelling model download: $modelId');
    final downloadId = 'model_$modelId';
    await cancelDownload(downloadId);
  }

  /// Get model download info
  DownloadInfo? getModelDownloadInfo(String modelId) {
    final downloadId = 'model_$modelId';
    final info = getDownloadInfo(downloadId);
    AppLogger.log(
        'Model download info: ModelID=$modelId, DownloadID=$downloadId, Info=${info != null ? 'Found' : 'Not found'}');
    return info;
  }

  /// Get model download progress stream
  Stream<DownloadProgress>? getModelProgressStream(String modelId) {
    final downloadId = 'model_$modelId';
    AppLogger.log('Getting model progress stream: ModelID=$modelId, DownloadID=$downloadId');
    return getProgressStream(downloadId);
  }

  /// Check if model is being downloaded
  bool isModelDownloading(String modelId) {
    final downloadInfo = getModelDownloadInfo(modelId);
    final isDownloading = downloadInfo?.status == DownloadStatus.downloading;
    AppLogger.log('Model download status: ModelID=$modelId, IsDownloading=$isDownloading');
    return isDownloading;
  }

  /// Check if model download is paused
  bool isModelDownloadPaused(String modelId) {
    final downloadInfo = getModelDownloadInfo(modelId);
    final isPaused = downloadInfo?.status == DownloadStatus.paused;
    AppLogger.log('Model pause status: ModelID=$modelId, IsPaused=$isPaused');
    return isPaused;
  }

  /// Check if model download is completed
  bool isModelDownloadCompleted(String modelId) {
    final downloadInfo = getModelDownloadInfo(modelId);
    final isCompleted = downloadInfo?.status == DownloadStatus.completed;
    AppLogger.log('Model completion status: ModelID=$modelId, IsCompleted=$isCompleted');
    return isCompleted;
  }

  /// Check if model download failed
  bool isModelDownloadFailed(String modelId) {
    final downloadInfo = getModelDownloadInfo(modelId);
    final isFailed = downloadInfo?.status == DownloadStatus.failed;
    AppLogger.log('Model failure status: ModelID=$modelId, IsFailed=$isFailed');
    return isFailed;
  }

  /// Get all model downloads
  Map<String, DownloadInfo> getModelDownloads() {
    final modelDownloads = <String, DownloadInfo>{};

    for (final entry in downloads.entries) {
      if (entry.key.startsWith('model_')) {
        final modelId = entry.key.replaceFirst('model_', '');
        modelDownloads[modelId] = entry.value;
      }
    }

    AppLogger.i('Retrieved model downloads: Count=${modelDownloads.length}');
    return modelDownloads;
  }

  /// Delete model download and file
  Future<void> deleteModelDownload(String modelId) async {
    AppLogger.i('Deleting model download: $modelId');
    final downloadId = 'model_$modelId';
    await deleteDownload(downloadId);
  }

  /// Get model file path
  String? getModelFilePath(String modelId) {
    final downloadInfo = getModelDownloadInfo(modelId);
    final filePath = downloadInfo?.filePath;
    AppLogger.log('Model file path: ModelID=$modelId, Path=$filePath');
    return filePath;
  }

  /// Check if model file exists
  Future<bool> isModelFileExists(String modelId) async {
    final filePath = getModelFilePath(modelId);
    if (filePath == null) {
      AppLogger.log('Model file check: ModelID=$modelId, Exists=false (no path)');
      return false;
    }

    final file = File(filePath);
    final exists = await file.exists();
    AppLogger.log('Model file check: ModelID=$modelId, Path=$filePath, Exists=$exists');
    return exists;
  }

  /// Get model file size
  Future<int?> getModelFileSize(String modelId) async {
    final filePath = getModelFilePath(modelId);
    if (filePath == null) {
      AppLogger.log('Model file size: ModelID=$modelId, Size=null (no path)');
      return null;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      AppLogger.log('Model file size: ModelID=$modelId, Size=null (file not found)');
      return null;
    }

    final size = await file.length();
    AppLogger.log('Model file size: ModelID=$modelId, Size=$size bytes');
    return size;
  }

  /// Validate model file integrity
  Future<bool> validateModelFile(String modelId, String expectedHash) async {
    AppLogger.i('Validating model file: ModelID=$modelId, ExpectedHash=$expectedHash');

    final filePath = getModelFilePath(modelId);
    if (filePath == null) {
      AppLogger.e('Model file validation failed: ModelID=$modelId, Reason=No file path');
      return false;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      AppLogger.e('Model file validation failed: ModelID=$modelId, Reason=File not found');
      return false;
    }

    // TODO: Implement hash validation
    // For now, just check if file exists and has size > 0
    final fileSize = await file.length();
    final isValid = fileSize > 0;

    AppLogger.i('Model file validation result: ModelID=$modelId, IsValid=$isValid, FileSize=$fileSize bytes');
    return isValid;
  }

  /// Generate model file name
  String _generateModelFileName(AiModel model) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = model.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final fileName = '${sanitizedName}_${model.modelVersion}_$timestamp.bin';
    AppLogger.log('Generated model filename: $fileName for model: ${model.name}');
    return fileName;
  }

  /// Get download directory for models
  Future<Directory> getModelDownloadDirectory() async {
    final baseDirectory = await getDownloadDirectory();
    final modelDirectory = Directory('${baseDirectory.path}/models');

    if (!await modelDirectory.exists()) {
      await modelDirectory.create(recursive: true);
      AppLogger.i('Created model download directory: ${modelDirectory.path}');
    }

    return modelDirectory;
  }

  /// Get available storage space
  Future<int> getAvailableStorageSpace() async {
    try {
      // Use disk_space package to get real storage information
      final availableSpace = await _getRealStorageSpace();
      AppLogger.log('Available storage space: $availableSpace bytes');
      return availableSpace;
    } catch (e) {
      AppLogger.e('Error getting available storage space: $e');
      // Return a conservative estimate as fallback
      return 512 * 1024 * 1024; // 512MB fallback
    }
  }

  /// Get real storage space using disk_space_plus package
  Future<int> _getRealStorageSpace() async {
    try {
      // Get available space in GB and convert to bytes
      final availableSpaceGB = await DiskSpacePlus.getFreeDiskSpace ?? 0;

      if (availableSpaceGB <= 0) {
        AppLogger.log('Disk space returned null or zero, using fallback');
        return _getFallbackStorageSpace();
      }

      final availableSpaceBytes = (availableSpaceGB * 1024 * 1024 * 1024).round();

      AppLogger.log(
          'Real storage space calculation: ${availableSpaceGB.toStringAsFixed(2)} GB = $availableSpaceBytes bytes');
      return availableSpaceBytes;
    } catch (e) {
      AppLogger.e('Error getting real storage space: $e');
      return _getFallbackStorageSpace();
    }
  }

  /// Get fallback storage space based on platform
  int _getFallbackStorageSpace() {
    if (Platform.isAndroid) {
      return 2 * 1024 * 1024 * 1024; // 2GB fallback for Android
    } else if (Platform.isIOS) {
      return 1024 * 1024 * 1024; // 1GB fallback for iOS
    } else {
      return 1024 * 1024 * 1024; // 1GB fallback for other platforms
    }
  }

  /// Check if there's enough space for model
  Future<bool> hasEnoughSpaceForModel(AiModel model) async {
    AppLogger.i('Checking storage space for model: ${model.name}, Size=${model.modelSize}');

    final availableSpace = await getAvailableStorageSpace();
    // Parse model size from string (e.g., "1.2GB" -> 1.2 * 1024 MB)
    final sizeInMB = _parseModelSize(model.modelSize);
    final requiredSpace = sizeInMB * 1024 * 1024; // Convert MB to bytes

    final hasSpace = availableSpace >= requiredSpace;
    AppLogger.i(
        'Storage space check: Model=${model.name}, Available=$availableSpace bytes, Required=$requiredSpace bytes, HasSpace=$hasSpace');

    return hasSpace;
  }

  /// Get download speed for a model
  double getModelDownloadSpeed(String modelId) {
    final downloadInfo = getModelDownloadInfo(modelId);
    if (downloadInfo == null) return 0.0;

    final now = DateTime.now();
    final duration = now.difference(downloadInfo.createdAt);
    if (duration.inSeconds == 0) return 0.0;

    final speed = downloadInfo.downloadedBytes / duration.inSeconds;
    AppLogger.log('Model download speed: ModelID=$modelId, Speed=${speed.toStringAsFixed(2)} bytes/s');
    return speed;
  }

  /// Get estimated time remaining for model download
  Duration getModelDownloadEstimatedTime(String modelId) {
    final downloadInfo = getModelDownloadInfo(modelId);
    if (downloadInfo == null) return Duration.zero;

    final speed = getModelDownloadSpeed(modelId);
    if (speed <= 0) return Duration.zero;

    final remainingBytes = downloadInfo.totalBytes - downloadInfo.downloadedBytes;
    final seconds = remainingBytes / speed;
    final duration = Duration(seconds: seconds.toInt());

    AppLogger.log('Model download ETA: ModelID=$modelId, ETA=${duration.inSeconds} seconds');
    return duration;
  }

  /// Get formatted download progress for model
  String getModelDownloadProgressText(String modelId) {
    final downloadInfo = getModelDownloadInfo(modelId);
    if (downloadInfo == null) return '0%';

    final progress = (downloadInfo.downloadedBytes / downloadInfo.totalBytes * 100).toInt();
    AppLogger.log('Model download progress: ModelID=$modelId, Progress=$progress%');
    return '$progress%';
  }

  /// Get formatted download speed for model
  String getModelDownloadSpeedText(String modelId) {
    final speed = getModelDownloadSpeed(modelId);
    if (speed <= 0) return '0 MB/s';

    final speedMBps = (speed / 1024 / 1024).toStringAsFixed(2);
    AppLogger.log('Model download speed text: ModelID=$modelId, Speed=$speedMBps MB/s');
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

    AppLogger.log('Formatted file size: $bytes bytes = $formattedSize');
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

    AppLogger.log('Formatted time remaining: ${duration.inSeconds} seconds = $formattedTime');
    return formattedTime;
  }

  /// Parse model size from string (e.g., "1.2GB" -> 1.2 * 1024 MB)
  double _parseModelSize(String modelSize) {
    final size = modelSize.toLowerCase();
    double sizeInMB;

    if (size.contains('gb')) {
      final value = double.tryParse(size.replaceAll('gb', '')) ?? 0;
      sizeInMB = value * 1024; // Convert GB to MB
    } else if (size.contains('mb')) {
      sizeInMB = double.tryParse(size.replaceAll('mb', '')) ?? 0;
    } else if (size.contains('kb')) {
      final value = double.tryParse(size.replaceAll('kb', '')) ?? 0;
      sizeInMB = value / 1024; // Convert KB to MB
    } else {
      // Assume bytes
      final value = double.tryParse(size) ?? 0;
      sizeInMB = value / 1024 / 1024; // Convert bytes to MB
    }

    AppLogger.log('Parsed model size: $modelSize = ${sizeInMB.toStringAsFixed(2)} MB');
    return sizeInMB;
  }
}
