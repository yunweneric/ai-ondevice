import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/model_mangement/data/models/ai_model.dart';

/// Example usage of the download services
class DownloadUsageExample {
  final ModelDownloadRepository _modelDownloadRepository;
  final DownloadRepository _downloadRepository;

  DownloadUsageExample(this._modelDownloadRepository, this._downloadRepository);

  /// Example: Download an AI model
  Future<void> downloadAIModel(AiModel model) async {
    try {
      // Check if there's enough space
      final hasSpace = await _modelDownloadRepository.hasEnoughSpaceForModel(model);
      if (!hasSpace) {
        throw Exception('Not enough storage space for model: ${model.name}');
      }

      // Start the download
      final downloadInfo = await _modelDownloadRepository.downloadModel(model: model);
      print('Started downloading: ${downloadInfo.fileName}');

      // Listen to progress
      final progressStream = _modelDownloadRepository.getModelProgressStream(model.id);
      progressStream?.listen((progress) {
        final progressText = _modelDownloadRepository.getModelDownloadProgressText(model.id);
        final speedText = _modelDownloadRepository.getModelDownloadSpeedText(model.id);
        final timeRemaining = _modelDownloadRepository.getFormattedTimeRemaining(progress.estimatedTimeRemaining);

        print('Progress: $progressText | Speed: $speedText | Time remaining: $timeRemaining');
      });
    } catch (e) {
      print('Error downloading model: $e');
    }
  }

  /// Example: Pause a model download
  Future<void> pauseModelDownload(String modelId) async {
    try {
      await _modelDownloadRepository.pauseModelDownload(modelId);
      print('Model download paused');
    } catch (e) {
      print('Error pausing download: $e');
    }
  }

  /// Example: Resume a model download
  Future<void> resumeModelDownload(String modelId) async {
    try {
      await _modelDownloadRepository.resumeModelDownload(modelId);
      print('Model download resumed');
    } catch (e) {
      print('Error resuming download: $e');
    }
  }

  /// Example: Cancel a model download
  Future<void> cancelModelDownload(String modelId) async {
    try {
      await _modelDownloadRepository.cancelModelDownload(modelId);
      print('Model download cancelled');
    } catch (e) {
      print('Error cancelling download: $e');
    }
  }

  /// Example: Check download status
  void checkDownloadStatus(String modelId) {
    final isDownloading = _modelDownloadRepository.isModelDownloading(modelId);
    final isPaused = _modelDownloadRepository.isModelDownloadPaused(modelId);
    final isCompleted = _modelDownloadRepository.isModelDownloadCompleted(modelId);
    final isFailed = _modelDownloadRepository.isModelDownloadFailed(modelId);

    print('Download status for model $modelId:');
    print('- Downloading: $isDownloading');
    print('- Paused: $isPaused');
    print('- Completed: $isCompleted');
    print('- Failed: $isFailed');
  }

  /// Example: Get all model downloads
  void listAllModelDownloads() {
    final downloads = _modelDownloadRepository.getModelDownloads();
    print('All model downloads:');

    for (final entry in downloads.entries) {
      final modelId = entry.key;
      final downloadInfo = entry.value;
      final progressText = _modelDownloadRepository.getModelDownloadProgressText(modelId);

      print('- Model $modelId: ${downloadInfo.status} | Progress: $progressText');
    }
  }

  /// Example: Download a generic file
  Future<void> downloadGenericFile(String url, String fileName) async {
    try {
      final downloadInfo = await _downloadRepository.startDownload(
        url: url,
        fileName: fileName,
      );
      print('Started downloading: ${downloadInfo.fileName}');

      // Listen to progress
      final progressStream = _downloadRepository.getProgressStream(downloadInfo.id);
      progressStream?.listen((progress) {
        final progressPercent = (progress.progress * 100).toInt();
        final speedMBps = (progress.speed / 1024 / 1024).toStringAsFixed(2);

        print('Progress: $progressPercent% | Speed: $speedMBps MB/s');
      });
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  /// Example: Check if model file exists
  Future<void> checkModelFile(String modelId) async {
    final exists = await _modelDownloadRepository.isModelFileExists(modelId);
    final fileSize = await _modelDownloadRepository.getModelFileSize(modelId);

    if (exists && fileSize != null) {
      final formattedSize = _modelDownloadRepository.getFormattedFileSize(fileSize);
      print('Model file exists: $formattedSize');
    } else {
      print('Model file does not exist');
    }
  }

  /// Example: Validate model file integrity
  Future<void> validateModelFile(String modelId, String expectedHash) async {
    final isValid = await _modelDownloadRepository.validateModelFile(modelId, expectedHash);
    print('Model file validation: ${isValid ? 'Valid' : 'Invalid'}');
  }
}
