part of 'download_manager_bloc.dart';

class DownloadManagerState extends Equatable {
  final Map<String, DownloadTask> downloads;
  final Map<String, DownloadProgress> downloadProgress;
  final Map<String, String> downloadErrors;
  final Map<String, bool> fileValidations;
  final bool isLoading;
  final String? error;

  const DownloadManagerState({
    this.downloads = const {},
    this.downloadProgress = const {},
    this.downloadErrors = const {},
    this.fileValidations = const {},
    this.isLoading = false,
    this.error,
  });

  DownloadManagerState copyWith({
    Map<String, DownloadTask>? downloads,
    Map<String, DownloadProgress>? downloadProgress,
    Map<String, String>? downloadErrors,
    Map<String, bool>? fileValidations,
    bool? isLoading,
    String? error,
  }) {
    return DownloadManagerState(
      downloads: downloads ?? this.downloads,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadErrors: downloadErrors ?? this.downloadErrors,
      fileValidations: fileValidations ?? this.fileValidations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'DownloadManagerState(downloads: $downloads, downloadProgress: $downloadProgress, downloadErrors: $downloadErrors, fileValidations: $fileValidations, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(covariant DownloadManagerState other) {
    if (identical(this, other)) return true;

    return other.downloads == downloads &&
        other.downloadProgress == downloadProgress &&
        other.downloadErrors == downloadErrors &&
        other.fileValidations == fileValidations &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return downloads.hashCode ^
        downloadProgress.hashCode ^
        downloadErrors.hashCode ^
        fileValidations.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
  }

  @override
  List<Object?> get props => [
        downloads,
        downloadProgress,
        downloadErrors,
        fileValidations,
        isLoading,
        error,
      ];

  /// Get download task by ID
  DownloadTask? getDownloadTask(String id) => downloads[id];

  /// Get download progress by ID
  DownloadProgress? getDownloadProgress(String id) => downloadProgress[id];

  /// Get download error by ID
  String? getDownloadError(String id) => downloadErrors[id];

  /// Get file validation by ID
  bool? getFileValidation(String id) => fileValidations[id];

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

  /// Get all active downloads
  Map<String, DownloadTask> get activeDownloads {
    return Map.fromEntries(
      downloads.entries.where((entry) => entry.value.isActive),
    );
  }

  /// Get all completed downloads
  Map<String, DownloadTask> get completedDownloads {
    return Map.fromEntries(
      downloads.entries.where((entry) => entry.value.isCompleted),
    );
  }

  /// Get all failed downloads
  Map<String, DownloadTask> get failedDownloads {
    return Map.fromEntries(
      downloads.entries.where((entry) => entry.value.isFailed),
    );
  }

  /// Get total number of downloads
  int get totalDownloads => downloads.length;

  /// Get number of active downloads
  int get activeDownloadsCount => activeDownloads.length;

  /// Get number of completed downloads
  int get completedDownloadsCount => completedDownloads.length;

  /// Get number of failed downloads
  int get failedDownloadsCount => failedDownloads.length;

  /// Check if there are any errors
  bool get hasErrors => downloadErrors.isNotEmpty || error != null;

  /// Get all error messages
  List<String> get errorMessages {
    final messages = <String>[];
    if (error != null) messages.add(error!);
    messages.addAll(downloadErrors.values);
    return messages;
  }
}
