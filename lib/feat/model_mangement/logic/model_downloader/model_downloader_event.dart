part of 'model_downloader_bloc.dart';

sealed class ModelDownloaderEvent extends Equatable {
  const ModelDownloaderEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all existing downloads
final class LoadDownloadsEvent extends ModelDownloaderEvent {
  const LoadDownloadsEvent();
}

/// Event to start downloading a model
final class StartDownloadEvent extends ModelDownloaderEvent {
  final AiModel model;

  const StartDownloadEvent(this.model);

  @override
  List<Object> get props => [model];
}

/// Event to cancel an ongoing download
final class CancelDownloadEvent extends ModelDownloaderEvent {
  final AiModel model;

  const CancelDownloadEvent(this.model);

  @override
  List<Object> get props => [model];
}

/// Event to delete a completed download
final class DeleteDownloadEvent extends ModelDownloaderEvent {
  final AiModel model;

  const DeleteDownloadEvent(this.model);

  @override
  List<Object> get props => [model];
}

/// Event to delete an incomplete download
final class DeleteIncompleteDownloadEvent extends ModelDownloaderEvent {
  final String modelKey;

  const DeleteIncompleteDownloadEvent(this.modelKey);

  @override
  List<Object> get props => [modelKey];
}

/// Event to update download progress
final class UpdateDownloadProgressEvent extends ModelDownloaderEvent {
  final String modelKey;
  final int received;
  final int total;
  final double progress;

  const UpdateDownloadProgressEvent({
    required this.modelKey,
    required this.received,
    required this.total,
    required this.progress,
  });

  @override
  List<Object> get props => [modelKey, received, total, progress];
}

/// Event when download is completed
final class DownloadCompletedEvent extends ModelDownloaderEvent {
  final String modelKey;
  final File file;

  const DownloadCompletedEvent({
    required this.modelKey,
    required this.file,
  });

  @override
  List<Object> get props => [modelKey, file];
}

/// Event when download encounters an error
final class DownloadErrorEvent extends ModelDownloaderEvent {
  final String modelKey;
  final String error;

  const DownloadErrorEvent({
    required this.modelKey,
    required this.error,
  });

  @override
  List<Object> get props => [modelKey, error];
}

/// Event to check download status
final class CheckDownloadStatusEvent extends ModelDownloaderEvent {
  final String modelKey;

  const CheckDownloadStatusEvent(this.modelKey);

  @override
  List<Object> get props => [modelKey];
}

/// Event to clear all downloads
final class ClearDownloadsEvent extends ModelDownloaderEvent {
  const ClearDownloadsEvent();
}

/// Event to select a model for use
final class SelectModelEvent extends ModelDownloaderEvent {
  final AiModel model;

  const SelectModelEvent({required this.model});

  @override
  List<Object> get props => [model];
}
