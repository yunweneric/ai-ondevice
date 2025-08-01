import 'package:equatable/equatable.dart';
import 'package:offline_ai/feat/model_mangement/data/models/ai_model.dart';

abstract class ModelDownloadEvent extends Equatable {
  const ModelDownloadEvent();

  @override
  List<Object?> get props => [];
}

/// Start downloading a model
class StartModelDownload extends ModelDownloadEvent {
  final AiModel model;

  const StartModelDownload(this.model);

  @override
  List<Object?> get props => [model];
}

/// Pause downloading a model
class PauseModelDownload extends ModelDownloadEvent {
  final String modelId;

  const PauseModelDownload(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Resume downloading a model
class ResumeModelDownload extends ModelDownloadEvent {
  final String modelId;

  const ResumeModelDownload(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Cancel downloading a model
class CancelModelDownload extends ModelDownloadEvent {
  final String modelId;

  const CancelModelDownload(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Delete a downloaded model
class DeleteModelDownload extends ModelDownloadEvent {
  final String modelId;

  const DeleteModelDownload(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Load all model downloads
class LoadModelDownloads extends ModelDownloadEvent {
  const LoadModelDownloads();
}

/// Check model download status
class CheckModelDownloadStatus extends ModelDownloadEvent {
  final String modelId;

  const CheckModelDownloadStatus(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Validate model file integrity
class ValidateModelFile extends ModelDownloadEvent {
  final String modelId;
  final String expectedHash;

  const ValidateModelFile(this.modelId, this.expectedHash);

  @override
  List<Object?> get props => [modelId, expectedHash];
}

/// Check available storage space
class CheckStorageSpace extends ModelDownloadEvent {
  final AiModel model;

  const CheckStorageSpace(this.model);

  @override
  List<Object?> get props => [model];
}

/// Refresh download progress
class RefreshDownloadProgress extends ModelDownloadEvent {
  final String modelId;

  const RefreshDownloadProgress(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Clear download errors
class ClearDownloadErrors extends ModelDownloadEvent {
  const ClearDownloadErrors();
}

/// Retry failed download
class RetryFailedDownload extends ModelDownloadEvent {
  final String modelId;

  const RetryFailedDownload(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Auto-resume interrupted downloads
class AutoResumeDownloads extends ModelDownloadEvent {
  const AutoResumeDownloads();
}
