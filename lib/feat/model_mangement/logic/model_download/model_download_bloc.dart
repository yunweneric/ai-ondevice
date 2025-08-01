import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/model_mangement/data/models/ai_model.dart';
import 'package:offline_ai/feat/model_mangement/logic/model_download/model_download_event.dart';
import 'package:offline_ai/feat/model_mangement/logic/model_download/model_download_state.dart';

class ModelDownloadBloc extends Bloc<ModelDownloadEvent, ModelDownloadState> {
  final ModelDownloadRepository _modelDownloadRepository;
  final Map<String, StreamSubscription<DownloadProgress>> _progressSubscriptions = {};

  ModelDownloadBloc(this._modelDownloadRepository) : super(const ModelDownloadState()) {
    on<StartModelDownload>(_onStartModelDownload);
    on<PauseModelDownload>(_onPauseModelDownload);
    on<ResumeModelDownload>(_onResumeModelDownload);
    on<CancelModelDownload>(_onCancelModelDownload);
    on<DeleteModelDownload>(_onDeleteModelDownload);
    on<LoadModelDownloads>(_onLoadModelDownloads);
    on<CheckModelDownloadStatus>(_onCheckModelDownloadStatus);
    on<ValidateModelFile>(_onValidateModelFile);
    on<CheckStorageSpace>(_onCheckStorageSpace);
    on<RefreshDownloadProgress>(_onRefreshDownloadProgress);
    on<ClearDownloadErrors>(_onClearDownloadErrors);
    on<RetryFailedDownload>(_onRetryFailedDownload);
    on<AutoResumeDownloads>(_onAutoResumeDownloads);
  }

  /// Start downloading a model
  Future<void> _onStartModelDownload(
    StartModelDownload event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Check storage space first
      final hasSpace = await _modelDownloadRepository.hasEnoughSpaceForModel(event.model);
      if (!hasSpace) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Not enough storage space for ${event.model.name}',
        ));
        return;
      }

      // Start the download
      final downloadInfo = await _modelDownloadRepository.downloadModel(model: event.model);

      // Update downloads map
      final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
      updatedDownloads[event.model.id] = downloadInfo;

      // Update storage space check
      final updatedStorageChecks = Map<String, bool>.from(state.storageSpaceChecks);
      updatedStorageChecks[event.model.id] = hasSpace;

      emit(state.copyWith(
        downloads: updatedDownloads,
        storageSpaceChecks: updatedStorageChecks,
        isLoading: false,
      ));

      // Listen to progress
      _listenToProgress(event.model.id);
    } catch (e) {
      // Update error state
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.model.id] = e.toString();

      emit(state.copyWith(
        downloadErrors: updatedErrors,
        isLoading: false,
        error: e.toString(),
      ));
      AppLogger.e(e.toString());
    }
  }

  /// Pause downloading a model
  Future<void> _onPauseModelDownload(
    PauseModelDownload event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      await _modelDownloadRepository.pauseModelDownload(event.modelId);

      // Update download info
      final downloadInfo = _modelDownloadRepository.getModelDownloadInfo(event.modelId);
      if (downloadInfo != null) {
        final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
        updatedDownloads[event.modelId] = downloadInfo;
        emit(state.copyWith(downloads: updatedDownloads));
      }

      // Cancel progress subscription
      _progressSubscriptions[event.modelId]?.cancel();
      _progressSubscriptions.remove(event.modelId);
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.modelId] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Resume downloading a model
  Future<void> _onResumeModelDownload(
    ResumeModelDownload event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      await _modelDownloadRepository.resumeModelDownload(event.modelId);

      // Update download info
      final downloadInfo = _modelDownloadRepository.getModelDownloadInfo(event.modelId);
      if (downloadInfo != null) {
        final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
        updatedDownloads[event.modelId] = downloadInfo;
        emit(state.copyWith(downloads: updatedDownloads));
      }

      // Listen to progress again
      _listenToProgress(event.modelId);
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.modelId] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Cancel downloading a model
  Future<void> _onCancelModelDownload(
    CancelModelDownload event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      await _modelDownloadRepository.cancelModelDownload(event.modelId);

      // Remove from downloads
      final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
      updatedDownloads.remove(event.modelId);

      // Remove progress
      final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
      updatedProgress.remove(event.modelId);

      // Remove errors
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors.remove(event.modelId);

      emit(state.copyWith(
        downloads: updatedDownloads,
        downloadProgress: updatedProgress,
        downloadErrors: updatedErrors,
      ));

      // Cancel progress subscription
      _progressSubscriptions[event.modelId]?.cancel();
      _progressSubscriptions.remove(event.modelId);
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.modelId] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Delete a downloaded model
  Future<void> _onDeleteModelDownload(
    DeleteModelDownload event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      await _modelDownloadRepository.deleteModelDownload(event.modelId);

      // Remove from downloads
      final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
      updatedDownloads.remove(event.modelId);

      // Remove progress
      final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
      updatedProgress.remove(event.modelId);

      // Remove errors
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors.remove(event.modelId);

      emit(state.copyWith(
        downloads: updatedDownloads,
        downloadProgress: updatedProgress,
        downloadErrors: updatedErrors,
      ));
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.modelId] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Load all model downloads
  Future<void> _onLoadModelDownloads(
    LoadModelDownloads event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final downloads = _modelDownloadRepository.getModelDownloads();

      // Set up progress listeners for active downloads
      for (final entry in downloads.entries) {
        final modelId = entry.key;
        final downloadInfo = entry.value;

        if (downloadInfo.status == DownloadStatus.downloading) {
          _listenToProgress(modelId);
        }
      }

      emit(state.copyWith(
        downloads: downloads,
        isLoading: false,
      ));

      // Auto-resume interrupted downloads after loading
      add(const AutoResumeDownloads());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Check model download status
  Future<void> _onCheckModelDownloadStatus(
    CheckModelDownloadStatus event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      final downloadInfo = _modelDownloadRepository.getModelDownloadInfo(event.modelId);

      if (downloadInfo != null) {
        final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
        updatedDownloads[event.modelId] = downloadInfo;
        emit(state.copyWith(downloads: updatedDownloads));
      }
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.modelId] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Validate model file integrity
  Future<void> _onValidateModelFile(
    ValidateModelFile event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      final isValid = await _modelDownloadRepository.validateModelFile(
        event.modelId,
        event.expectedHash,
      );

      final updatedValidations = Map<String, bool>.from(state.fileValidations);
      updatedValidations[event.modelId] = isValid;

      emit(state.copyWith(fileValidations: updatedValidations));
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.modelId] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Check available storage space
  Future<void> _onCheckStorageSpace(
    CheckStorageSpace event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      final hasSpace = await _modelDownloadRepository.hasEnoughSpaceForModel(event.model);

      final updatedStorageChecks = Map<String, bool>.from(state.storageSpaceChecks);
      updatedStorageChecks[event.model.id] = hasSpace;

      emit(state.copyWith(storageSpaceChecks: updatedStorageChecks));
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.model.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Refresh download progress
  Future<void> _onRefreshDownloadProgress(
    RefreshDownloadProgress event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      final downloadInfo = _modelDownloadRepository.getModelDownloadInfo(event.modelId);

      if (downloadInfo != null) {
        final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
        updatedDownloads[event.modelId] = downloadInfo;
        emit(state.copyWith(downloads: updatedDownloads));
      }
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.modelId] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Clear download errors
  void _onClearDownloadErrors(
    ClearDownloadErrors event,
    Emitter<ModelDownloadState> emit,
  ) {
    emit(state.copyWith(
      downloadErrors: const {},
      error: null,
    ));
  }

  /// Retry failed download
  Future<void> _onRetryFailedDownload(
    RetryFailedDownload event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      final downloadInfo = state.getDownloadInfo(event.modelId);
      if (downloadInfo == null) return;

      // Clear error
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors.remove(event.modelId);

      emit(state.copyWith(downloadErrors: updatedErrors));

      // Restart download
      add(StartModelDownload(AiModel(
        id: event.modelId,
        name: downloadInfo.fileName,
        description: '',
        image: '',
        model: '',
        url: downloadInfo.url,
        path: '',
        modelType: '',
        modelSize: '',
        modelVersion: '',
        modelAuthor: '',
        modelAuthorImage: '',
        modelAuthorDescription: '',
        modelAuthorWebsite: '',
      )));
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.modelId] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Auto-resume interrupted downloads
  Future<void> _onAutoResumeDownloads(
    AutoResumeDownloads event,
    Emitter<ModelDownloadState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      await _modelDownloadRepository.autoResumeModelDownloads();

      // Reload downloads to get updated status
      final downloads = _modelDownloadRepository.getModelDownloads();

      // Set up progress listeners for resumed downloads
      for (final entry in downloads.entries) {
        final modelId = entry.key;
        final downloadInfo = entry.value;

        if (downloadInfo.status == DownloadStatus.downloading) {
          _listenToProgress(modelId);
        }
      }

      emit(state.copyWith(
        downloads: downloads,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Listen to download progress for a model
  void _listenToProgress(String modelId) {
    // Cancel existing subscription
    _progressSubscriptions[modelId]?.cancel();

    // Create new subscription
    final progressStream = _modelDownloadRepository.getModelProgressStream(modelId);
    if (progressStream != null) {
      _progressSubscriptions[modelId] = progressStream.listen(
        (progress) {
          final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
          updatedProgress[modelId] = progress;

          emit(state.copyWith(downloadProgress: updatedProgress));
        },
        onError: (error) {
          final updatedErrors = Map<String, String>.from(state.downloadErrors);
          updatedErrors[modelId] = error.toString();
          emit(state.copyWith(downloadErrors: updatedErrors));
        },
      );
    }
  }

  @override
  Future<void> close() {
    // Cancel all progress subscriptions
    for (final subscription in _progressSubscriptions.values) {
      subscription.cancel();
    }
    _progressSubscriptions.clear();

    return super.close();
  }
}
