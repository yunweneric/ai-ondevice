part of 'download_manager_bloc.dart';

abstract class DownloadManagerEvent extends Equatable {
  const DownloadManagerEvent();

  @override
  List<Object?> get props => [];
}

/// Start a new download
class StartDownload extends DownloadManagerEvent {
  final String url;
  final String fileName;
  final String? customId;
  final Map<String, dynamic>? metadata;

  const StartDownload({
    required this.url,
    required this.fileName,
    this.customId,
    this.metadata,
  });

  @override
  List<Object?> get props => [url, fileName, customId, metadata];
}

/// Resume a paused download
class ResumeDownload extends DownloadManagerEvent {
  final String id;

  const ResumeDownload(this.id);

  @override
  List<Object?> get props => [id];
}

/// Pause a download
class PauseDownload extends DownloadManagerEvent {
  final String id;

  const PauseDownload(this.id);

  @override
  List<Object?> get props => [id];
}

/// Cancel a download
class CancelDownload extends DownloadManagerEvent {
  final String id;

  const CancelDownload(this.id);

  @override
  List<Object?> get props => [id];
}

/// Delete a completed download
class DeleteDownload extends DownloadManagerEvent {
  final String id;

  const DeleteDownload(this.id);

  @override
  List<Object?> get props => [id];
}

/// Load all downloads
class LoadDownloads extends DownloadManagerEvent {
  const LoadDownloads();
}

/// Auto-resume interrupted downloads
class AutoResumeDownloads extends DownloadManagerEvent {
  const AutoResumeDownloads();
}

/// Check download status
class CheckDownloadStatus extends DownloadManagerEvent {
  final String id;

  const CheckDownloadStatus(this.id);

  @override
  List<Object?> get props => [id];
}

/// Validate download file
class ValidateDownloadFile extends DownloadManagerEvent {
  final String id;
  final String expectedHash;

  const ValidateDownloadFile(this.id, this.expectedHash);

  @override
  List<Object?> get props => [id, expectedHash];
}

/// Clear download errors
class ClearDownloadErrors extends DownloadManagerEvent {
  const ClearDownloadErrors();
}

/// Retry failed download
class RetryFailedDownload extends DownloadManagerEvent {
  final String id;

  const RetryFailedDownload(this.id);

  @override
  List<Object?> get props => [id];
}

/// Refresh download progress
class RefreshDownloadProgress extends DownloadManagerEvent {
  final String id;

  const RefreshDownloadProgress(this.id);

  @override
  List<Object?> get props => [id];
}
