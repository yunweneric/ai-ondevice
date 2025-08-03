import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ai/shared/shared.dart';

part 'download_manager_event.dart';
part 'download_manager_state.dart';

class DownloadManagerBloc extends Bloc<DownloadManagerEvent, DownloadManagerState> {
  final DownloadManagerRepository _repository;
  final Map<String, StreamSubscription<DownloadProgress>> _progressSubscriptions = {};

  DownloadManagerBloc(this._repository) : super(const DownloadManagerState()) {
    on<StartDownload>(_onStartDownload);
    on<PauseDownload>(_onPauseDownload);
    on<ResumeDownload>(_onResumeDownload);
    on<CancelDownload>(_onCancelDownload);
    on<DeleteDownload>(_onDeleteDownload);
    on<LoadDownloads>(_onLoadDownloads);
    on<CheckDownloadStatus>(_onCheckDownloadStatus);
    on<ValidateDownloadFile>(_onValidateDownloadFile);
    on<RefreshDownloadProgress>(_onRefreshDownloadProgress);
    on<ClearDownloadErrors>(_onClearDownloadErrors);
    on<RetryFailedDownload>(_onRetryFailedDownload);
    on<AutoResumeDownloads>(_onAutoResumeDownloads);
  }

  /// Start a new download
  Future<void> _onStartDownload(
    StartDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Start the download
      final downloadTask = await _repository.startDownload(
        url: event.url,
        fileName: event.fileName,
        customId: event.customId,
        metadata: event.metadata,
      );

      // Update downloads map
      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
      updatedDownloads[downloadTask.id] = downloadTask;

      emit(state.copyWith(
        downloads: updatedDownloads,
        isLoading: false,
      ));

      // Listen to progress
      _listenToProgress(downloadTask.id);
    } catch (e) {
      // Update error state
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.customId ?? 'unknown'] = e.toString();

      emit(state.copyWith(
        downloadErrors: updatedErrors,
        isLoading: false,
        error: e.toString(),
      ));
      AppLogger.e(e.toString());
    }
  }

  /// Pause a download
  Future<void> _onPauseDownload(
    PauseDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      await _repository.pauseDownload(event.id);

      // Update download task
      final downloadTask = _repository.getDownloadTask(event.id);
      if (downloadTask != null) {
        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
      }

      // Cancel progress subscription
      _progressSubscriptions[event.id]?.cancel();
      _progressSubscriptions.remove(event.id);
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Resume a download
  Future<void> _onResumeDownload(
    ResumeDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      await _repository.resumeDownload(event.id);

      // Update download task
      final downloadTask = _repository.getDownloadTask(event.id);
      if (downloadTask != null) {
        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
      }

      // Listen to progress again
      _listenToProgress(event.id);
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Cancel a download
  Future<void> _onCancelDownload(
    CancelDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      await _repository.cancelDownload(event.id);

      // Remove from downloads
      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
      updatedDownloads.remove(event.id);

      // Remove progress
      final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
      updatedProgress.remove(event.id);

      // Remove errors
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors.remove(event.id);

      emit(state.copyWith(
        downloads: updatedDownloads,
        downloadProgress: updatedProgress,
        downloadErrors: updatedErrors,
      ));

      // Cancel progress subscription
      _progressSubscriptions[event.id]?.cancel();
      _progressSubscriptions.remove(event.id);
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Delete a download
  Future<void> _onDeleteDownload(
    DeleteDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      await _repository.deleteDownload(event.id);

      // Remove from downloads
      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
      updatedDownloads.remove(event.id);

      // Remove progress
      final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
      updatedProgress.remove(event.id);

      // Remove errors
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors.remove(event.id);

      emit(state.copyWith(
        downloads: updatedDownloads,
        downloadProgress: updatedProgress,
        downloadErrors: updatedErrors,
      ));
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Load all downloads
  Future<void> _onLoadDownloads(
    LoadDownloads event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final downloads = _repository.getDownloads();

      // Set up progress listeners for active downloads
      for (final entry in downloads.entries) {
        final taskId = entry.key;
        final downloadTask = entry.value;

        if (downloadTask.isActive) {
          _listenToProgress(taskId);
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

  /// Check download status
  Future<void> _onCheckDownloadStatus(
    CheckDownloadStatus event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      final downloadTask = _repository.getDownloadTask(event.id);

      if (downloadTask != null) {
        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
      }
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Validate download file
  Future<void> _onValidateDownloadFile(
    ValidateDownloadFile event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      final isValid = await _repository.validateDownloadFile(
        event.id,
        event.expectedHash,
      );

      final updatedValidations = Map<String, bool>.from(state.fileValidations);
      updatedValidations[event.id] = isValid;

      emit(state.copyWith(fileValidations: updatedValidations));
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Refresh download progress
  Future<void> _onRefreshDownloadProgress(
    RefreshDownloadProgress event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      final downloadTask = _repository.getDownloadTask(event.id);

      if (downloadTask != null) {
        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
      }
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Clear download errors
  void _onClearDownloadErrors(
    ClearDownloadErrors event,
    Emitter<DownloadManagerState> emit,
  ) {
    emit(state.copyWith(
      downloadErrors: const {},
      error: null,
    ));
  }

  /// Retry failed download
  Future<void> _onRetryFailedDownload(
    RetryFailedDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      final downloadTask = state.getDownloadTask(event.id);
      if (downloadTask == null) return;

      // Clear error
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors.remove(event.id);

      emit(state.copyWith(downloadErrors: updatedErrors));

      // Restart download
      add(StartDownload(
        url: downloadTask.url,
        fileName: downloadTask.fileName,
        customId: event.id,
        metadata: downloadTask.metadata,
      ));
    } catch (e) {
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
    }
  }

  /// Auto-resume interrupted downloads
  Future<void> _onAutoResumeDownloads(
    AutoResumeDownloads event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      await _repository.autoResumeDownloads();

      // Reload downloads to get updated status
      final downloads = _repository.getDownloads();

      // Set up progress listeners for resumed downloads
      for (final entry in downloads.entries) {
        final taskId = entry.key;
        final downloadTask = entry.value;

        if (downloadTask.isActive) {
          _listenToProgress(taskId);
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

  /// Listen to download progress for a task
  void _listenToProgress(String taskId) {
    // Cancel existing subscription
    _progressSubscriptions[taskId]?.cancel();

    // Create new subscription
    final progressStream = _repository.getProgressStream(taskId);
    if (progressStream != null) {
      _progressSubscriptions[taskId] = progressStream.listen(
        (progress) {
          final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
          updatedProgress[taskId] = progress;

          emit(state.copyWith(downloadProgress: updatedProgress));
        },
        onError: (error) {
          final updatedErrors = Map<String, String>.from(state.downloadErrors);
          updatedErrors[taskId] = error.toString();
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
