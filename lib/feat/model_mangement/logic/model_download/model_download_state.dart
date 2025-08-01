import 'package:equatable/equatable.dart';
import 'package:offline_ai/shared/shared.dart';

class ModelDownloadState extends Equatable {
  final Map<String, DownloadInfo> downloads;
  final Map<String, DownloadProgress> downloadProgress;
  final Map<String, String> downloadErrors;
  final Map<String, bool> storageSpaceChecks;
  final Map<String, bool> fileValidations;
  final bool isLoading;
  final String? error;

  const ModelDownloadState({
    this.downloads = const {},
    this.downloadProgress = const {},
    this.downloadErrors = const {},
    this.storageSpaceChecks = const {},
    this.fileValidations = const {},
    this.isLoading = false,
    this.error,
  });

  ModelDownloadState copyWith({
    Map<String, DownloadInfo>? downloads,
    Map<String, DownloadProgress>? downloadProgress,
    Map<String, String>? downloadErrors,
    Map<String, bool>? storageSpaceChecks,
    Map<String, bool>? fileValidations,
    bool? isLoading,
    String? error,
  }) {
    return ModelDownloadState(
      downloads: downloads ?? this.downloads,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadErrors: downloadErrors ?? this.downloadErrors,
      storageSpaceChecks: storageSpaceChecks ?? this.storageSpaceChecks,
      fileValidations: fileValidations ?? this.fileValidations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get download info for a specific model
  DownloadInfo? getDownloadInfo(String modelId) => downloads[modelId];

  /// Get download progress for a specific model
  DownloadProgress? getDownloadProgress(String modelId) => downloadProgress[modelId];

  /// Get download error for a specific model
  String? getDownloadError(String modelId) => downloadErrors[modelId];

  /// Check if a model is being downloaded
  bool isModelDownloading(String modelId) {
    final downloadInfo = downloads[modelId];
    return downloadInfo?.status == DownloadStatus.downloading;
  }

  /// Check if a model download is paused
  bool isModelDownloadPaused(String modelId) {
    final downloadInfo = downloads[modelId];
    return downloadInfo?.status == DownloadStatus.paused;
  }

  /// Check if a model download is completed
  bool isModelDownloadCompleted(String modelId) {
    final downloadInfo = downloads[modelId];
    return downloadInfo?.status == DownloadStatus.completed;
  }

  /// Check if a model download failed
  bool isModelDownloadFailed(String modelId) {
    final downloadInfo = downloads[modelId];
    return downloadInfo?.status == DownloadStatus.failed;
  }

  /// Check if a model download is cancelled
  bool isModelDownloadCancelled(String modelId) {
    final downloadInfo = downloads[modelId];
    return downloadInfo?.status == DownloadStatus.cancelled;
  }

  /// Get all downloading models
  List<String> get downloadingModels {
    return downloads.entries
        .where((entry) => entry.value.status == DownloadStatus.downloading)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all paused models
  List<String> get pausedModels {
    return downloads.entries
        .where((entry) => entry.value.status == DownloadStatus.paused)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all completed models
  List<String> get completedModels {
    return downloads.entries
        .where((entry) => entry.value.status == DownloadStatus.completed)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all failed models
  List<String> get failedModels {
    return downloads.entries
        .where((entry) => entry.value.status == DownloadStatus.failed)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get progress percentage for a model
  int getProgressPercentage(String modelId) {
    final progress = downloadProgress[modelId];
    if (progress == null) return 0;
    return (progress.progress * 100).toInt();
  }

  /// Get formatted progress text for a model
  String getProgressText(String modelId) {
    final progress = downloadProgress[modelId];
    if (progress == null) return '0%';
    return '${(progress.progress * 100).toInt()}%';
  }

  /// Get formatted speed text for a model
  String getSpeedText(String modelId) {
    final progress = downloadProgress[modelId];
    if (progress == null) return '0 MB/s';
    final speedMBps = (progress.speed / 1024 / 1024).toStringAsFixed(2);
    return '$speedMBps MB/s';
  }

  /// Get formatted time remaining for a model
  String getTimeRemainingText(String modelId) {
    final progress = downloadProgress[modelId];
    if (progress == null) return '0s';

    final duration = progress.estimatedTimeRemaining;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get formatted total file size for a model
  String getTotalFileSizeText(String modelId) {
    final progress = downloadProgress[modelId];
    if (progress == null) return '0 B';
    return UtilHelper.formatBytes(progress.totalBytes);
  }

  /// Get formatted downloaded size for a model
  String getDownloadedSizeText(String modelId) {
    final progress = downloadProgress[modelId];
    if (progress == null) return '0 B';
    return UtilHelper.formatBytes(progress.downloadedBytes);
  }

  /// Get formatted remaining size for a model
  String getRemainingSizeText(String modelId) {
    final progress = downloadProgress[modelId];
    if (progress == null) return '0 B';
    final remainingBytes = progress.totalBytes - progress.downloadedBytes;
    return UtilHelper.formatBytes(remainingBytes);
  }

  /// Get total file size in bytes for a model
  int getTotalFileSize(String modelId) {
    final progress = downloadProgress[modelId];
    return progress?.totalBytes ?? 0;
  }

  /// Get downloaded size in bytes for a model
  int getDownloadedSize(String modelId) {
    final progress = downloadProgress[modelId];
    return progress?.downloadedBytes ?? 0;
  }

  /// Get remaining size in bytes for a model
  int getRemainingSize(String modelId) {
    final progress = downloadProgress[modelId];
    if (progress == null) return 0;
    return progress.totalBytes - progress.downloadedBytes;
  }

  /// Check if there's enough storage space for a model
  bool hasEnoughStorageSpace(String modelId) {
    return storageSpaceChecks[modelId] ?? false;
  }

  /// Check if model file is valid
  bool isModelFileValid(String modelId) {
    return fileValidations[modelId] ?? false;
  }

  /// Get total number of downloads
  int get totalDownloads => downloads.length;

  /// Get number of active downloads
  int get activeDownloads => downloadingModels.length;

  /// Get number of completed downloads
  int get completedDownloads => completedModels.length;

  /// Get number of failed downloads
  int get failedDownloads => failedModels.length;

  /// Check if there are any active downloads
  bool get hasActiveDownloads => activeDownloads > 0;

  /// Check if there are any failed downloads
  bool get hasFailedDownloads => failedDownloads > 0;

  /// Check if there are any completed downloads
  bool get hasCompletedDownloads => completedDownloads > 0;

  /// Check if model download can be resumed
  bool canResumeModelDownload(String modelId) {
    final downloadInfo = downloads[modelId];
    if (downloadInfo == null) return false;

    // Can resume if paused or if there's a partial file
    return downloadInfo.status == DownloadStatus.paused ||
        downloadInfo.status == DownloadStatus.failed ||
        (downloadInfo.downloadedBytes > 0 && downloadInfo.status != DownloadStatus.completed);
  }

  @override
  List<Object?> get props => [
        downloads,
        downloadProgress,
        downloadErrors,
        storageSpaceChecks,
        fileValidations,
        isLoading,
        error,
      ];
}
