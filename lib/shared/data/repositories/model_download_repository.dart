import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/model_mangement/data/models/ai_model.dart';

class ModelDownloadRepository {
  final ModelDownloadService _modelDownloadService;

  ModelDownloadRepository(this._modelDownloadService);

  /// Download an AI model
  Future<DownloadInfo> downloadModel({
    required AiModel model,
    String? customId,
  }) async {
    return await _modelDownloadService.downloadModel(
      model: model,
      customId: customId,
    );
  }

  /// Resume downloading a model
  Future<void> resumeModelDownload(String modelId) async {
    await _modelDownloadService.resumeModelDownload(modelId);
  }

  /// Auto-resume model downloads that were interrupted
  Future<void> autoResumeModelDownloads() async {
    await _modelDownloadService.autoResumeModelDownloads();
  }

  /// Pause downloading a model
  Future<void> pauseModelDownload(String modelId) async {
    await _modelDownloadService.pauseModelDownload(modelId);
  }

  /// Cancel downloading a model
  Future<void> cancelModelDownload(String modelId) async {
    await _modelDownloadService.cancelModelDownload(modelId);
  }

  /// Get model download info
  DownloadInfo? getModelDownloadInfo(String modelId) {
    return _modelDownloadService.getModelDownloadInfo(modelId);
  }

  /// Get model download progress stream
  Stream<DownloadProgress>? getModelProgressStream(String modelId) {
    return _modelDownloadService.getModelProgressStream(modelId);
  }

  /// Check if model is being downloaded
  bool isModelDownloading(String modelId) {
    return _modelDownloadService.isModelDownloading(modelId);
  }

  /// Check if model download is paused
  bool isModelDownloadPaused(String modelId) {
    return _modelDownloadService.isModelDownloadPaused(modelId);
  }

  /// Check if model download is completed
  bool isModelDownloadCompleted(String modelId) {
    return _modelDownloadService.isModelDownloadCompleted(modelId);
  }

  /// Check if model download failed
  bool isModelDownloadFailed(String modelId) {
    return _modelDownloadService.isModelDownloadFailed(modelId);
  }

  /// Get all model downloads
  Map<String, DownloadInfo> getModelDownloads() {
    return _modelDownloadService.getModelDownloads();
  }

  /// Delete model download and file
  Future<void> deleteModelDownload(String modelId) async {
    await _modelDownloadService.deleteModelDownload(modelId);
  }

  /// Get model file path
  String? getModelFilePath(String modelId) {
    return _modelDownloadService.getModelFilePath(modelId);
  }

  /// Check if model file exists
  Future<bool> isModelFileExists(String modelId) async {
    return await _modelDownloadService.isModelFileExists(modelId);
  }

  /// Get model file size
  Future<int?> getModelFileSize(String modelId) async {
    return await _modelDownloadService.getModelFileSize(modelId);
  }

  /// Validate model file integrity
  Future<bool> validateModelFile(String modelId, String expectedHash) async {
    return await _modelDownloadService.validateModelFile(modelId, expectedHash);
  }

  /// Check if there's enough space for model
  Future<bool> hasEnoughSpaceForModel(AiModel model) async {
    return await _modelDownloadService.hasEnoughSpaceForModel(model);
  }

  /// Get download speed for a model
  double getModelDownloadSpeed(String modelId) {
    return _modelDownloadService.getModelDownloadSpeed(modelId);
  }

  /// Get estimated time remaining for model download
  Duration getModelDownloadEstimatedTime(String modelId) {
    return _modelDownloadService.getModelDownloadEstimatedTime(modelId);
  }

  /// Get formatted download progress for model
  String getModelDownloadProgressText(String modelId) {
    return _modelDownloadService.getModelDownloadProgressText(modelId);
  }

  /// Get formatted download speed for model
  String getModelDownloadSpeedText(String modelId) {
    return _modelDownloadService.getModelDownloadSpeedText(modelId);
  }

  /// Get formatted file size
  String getFormattedFileSize(int bytes) {
    return _modelDownloadService.getFormattedFileSize(bytes);
  }

  /// Get formatted time remaining
  String getFormattedTimeRemaining(Duration duration) {
    return _modelDownloadService.getFormattedTimeRemaining(duration);
  }
}
