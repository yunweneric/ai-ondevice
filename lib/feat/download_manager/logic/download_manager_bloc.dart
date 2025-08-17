import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:offline_ai/shared/shared.dart';

part 'download_manager_event.dart';
part 'download_manager_state.dart';

class DownloadManagerBloc extends HydratedBloc<DownloadManagerEvent, DownloadManagerState> {
  final DownloadManagerRepository _repository;

  DownloadManagerBloc()
      : _repository = DownloadManagerRepository(getIt.get<DownloadManagerService>()),
        super(const DownloadManagerState()) {
    on<LoadDownloads>(_onLoadDownloads);
    on<StartDownload>(_onStartDownload);
    on<PauseDownload>(_onPauseDownload);
    on<ResumeDownload>(_onResumeDownload);
    on<CancelDownload>(_onCancelDownload);
    on<DeleteDownload>(_onDeleteDownload);
    on<CheckDownloadStatus>(_onCheckDownloadStatus);
    on<ValidateDownloadFile>(_onValidateDownloadFile);
    on<RefreshDownloadProgress>(_onRefreshDownloadProgress);
    on<ClearDownloadErrors>(_onClearDownloadErrors);
    on<RetryFailedDownload>(_onRetryFailedDownload);
    on<AutoResumeDownloads>(_onAutoResumeDownloads);
  }

  /// Load existing downloads
  Future<void> _onLoadDownloads(
    LoadDownloads event,
    Emitter<DownloadManagerState> emit,
  ) async {
    AppLogger.i('=== Loading Downloads (Bloc) ===');

    try {
      emit(state.copyWith(isLoading: true));
      AppLogger.i('State updated: isLoading = true');

      final downloads = await _repository.getDownloads();
      AppLogger.i('Retrieved downloads from repository: ${downloads.length} downloads');

      // Log each download
      for (final entry in downloads.entries) {
        final taskId = entry.key;
        final downloadTask = entry.value;
        AppLogger.i('Download found:');
        AppLogger.i('  - Task ID: $taskId');
        AppLogger.i('  - File: ${downloadTask.fileName}');
        AppLogger.i('  - Status: ${downloadTask.status}');
        AppLogger.i('  - Progress: ${downloadTask.downloadedBytes} bytes');
        AppLogger.i('  - Progress %: ${(downloadTask.progress * 100).toStringAsFixed(1)}%');
        AppLogger.i('  - Is Active: ${downloadTask.isActive}');
      }

      emit(state.copyWith(
        downloads: downloads,
        isLoading: false,
      ));
      AppLogger.i('State updated: isLoading = false, downloads count: ${downloads.length}');

      // Auto-resume interrupted downloads after loading (only in production)
      if (!kDebugMode) {
        AppLogger.i('Triggering auto-resume for interrupted downloads...');
        add(const AutoResumeDownloads());
      }

      AppLogger.i('=== Downloads Loaded Successfully (Bloc) ===');
    } catch (e) {
      AppLogger.e('=== Load Downloads Failed (Bloc) ===');
      AppLogger.e('Error: $e');

      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      AppLogger.e('State updated with error, isLoading = false');
      AppLogger.e('=== Load Failure Handled (Bloc) ===');
    }
  }

  /// Start a new download
  Future<void> _onStartDownload(StartDownload event, Emitter<DownloadManagerState> emit) async {
    AppLogger.i('=== Starting Download (Bloc) ===');
    AppLogger.i('URL: ${event.url}');
    AppLogger.i('File: ${event.fileName}');
    AppLogger.i('Custom ID: ${event.customId}');

    try {
      // Start the download with progress callback
      final downloadTask = await _repository.startDownload(
        url: event.url,
        fileName: event.fileName,
        customId: event.customId,
        metadata: event.metadata,
        onProgress: (progress) {
          // Update progress in state
          final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
          updatedProgress[event.customId ?? 'unknown'] = DownloadProgress(
            taskId: event.customId ?? 'unknown',
            downloadedBytes: 0, // Will be calculated from progress
            totalBytes: 0, // Will be updated when download completes
            progress: progress,
            speed: 0.0,
            estimatedTimeRemaining: Duration.zero,
            timestamp: DateTime.now(),
          );

          emit(state.copyWith(downloadProgress: updatedProgress));
          AppLogger.log('Progress updated: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      AppLogger.i('Download started successfully');
      AppLogger.i('Task ID: ${downloadTask.id}');
      AppLogger.i('Status: ${downloadTask.status}');

      // Update state with new download
      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
      updatedDownloads[downloadTask.id] = downloadTask;

      emit(state.copyWith(downloads: updatedDownloads));
      AppLogger.i('State updated with new download');

      AppLogger.i('=== Download Started Successfully (Bloc) ===');
    } catch (e) {
      AppLogger.e('=== Start Download Failed (Bloc) ===');
      AppLogger.e('Error: $e');
      AppLogger.e('URL: ${event.url}');
      AppLogger.e('File: ${event.fileName}');

      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.customId ?? 'unknown'] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
      AppLogger.e('Error stored for download');
      AppLogger.e('=== Start Failure Handled (Bloc) ===');
    }
  }

  /// Pause a download
  Future<void> _onPauseDownload(PauseDownload event, Emitter<DownloadManagerState> emit) async {
    AppLogger.i('=== Pausing Download (Bloc) ===');
    AppLogger.i('Download ID: ${event.id}');

    try {
      await _repository.pauseDownload(event.id);
      AppLogger.i('Repository pause command completed');

      // Update download task
      final downloadTask = _repository.getDownloadTask(event.id);
      if (downloadTask != null) {
        AppLogger.i('Updated task info:');
        AppLogger.i('  - Status: ${downloadTask.status}');
        AppLogger.i('  - Progress: ${downloadTask.progress * 100}%');

        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
        AppLogger.i('State updated with paused download');
      } else {
        AppLogger.e('Download task not found after pause: $event.id');
      }

      AppLogger.i('=== Download Paused Successfully (Bloc) ===');
    } catch (e) {
      AppLogger.e('=== Pause Download Failed (Bloc) ===');
      AppLogger.e('Error: $e');
      AppLogger.e('Download ID: $event.id');

      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
      AppLogger.e('Error stored for download: $event.id');
      AppLogger.e('=== Pause Failure Handled (Bloc) ===');
    }
  }

  /// Resume a download
  Future<void> _onResumeDownload(ResumeDownload event, Emitter<DownloadManagerState> emit) async {
    AppLogger.i('=== Resuming Download (Bloc) ===');
    AppLogger.i('Download ID: $event.id');

    try {
      AppLogger.i('Calling repository to resume download...');
      await _repository.resumeDownload(event.id);
      AppLogger.i('Repository resume command completed');

      // Update download task
      final downloadTask = _repository.getDownloadTask(event.id);
      if (downloadTask != null) {
        AppLogger.i('Updated task info:');
        AppLogger.i('  - Status: ${downloadTask.status}');
        AppLogger.i('  - Progress: ${downloadTask.progress * 100}%');

        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
        AppLogger.i('State updated with resumed download');
      } else {
        AppLogger.e('Download task not found after resume: $event.id');
      }

      AppLogger.i('=== Download Resumed Successfully (Bloc) ===');
    } catch (e) {
      AppLogger.e('=== Resume Download Failed (Bloc) ===');
      AppLogger.e('Error: $e');
      AppLogger.e('Download ID: $event.id');

      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
      AppLogger.e('Error stored for download: $event.id');
      AppLogger.e('=== Resume Failure Handled (Bloc) ===');
    }
  }

  /// Cancel a download
  Future<void> _onCancelDownload(CancelDownload event, Emitter<DownloadManagerState> emit) async {
    AppLogger.i('=== Cancelling Download (Bloc) ===');
    AppLogger.i('Download ID: $event.id');

    try {
      await _repository.cancelDownload(event.id);
      AppLogger.i('Repository cancel command completed');

      // Update download task
      final downloadTask = _repository.getDownloadTask(event.id);
      if (downloadTask != null) {
        AppLogger.i('Updated task info:');
        AppLogger.i('  - Status: ${downloadTask.status}');
        AppLogger.i('  - Progress: ${downloadTask.progress * 100}%');

        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
        AppLogger.i('State updated with cancelled download');
      } else {
        AppLogger.e('Download task not found after cancel: $event.id');
      }

      AppLogger.i('=== Download Cancelled Successfully (Bloc) ===');
    } catch (e) {
      AppLogger.e('=== Cancel Download Failed (Bloc) ===');
      AppLogger.e('Error: $e');
      AppLogger.e('Download ID: $event.id');

      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
      AppLogger.e('Error stored for download: $event.id');
      AppLogger.e('=== Cancel Failure Handled (Bloc) ===');
    }
  }

  /// Delete a download
  Future<void> _onDeleteDownload(DeleteDownload event, Emitter<DownloadManagerState> emit) async {
    AppLogger.i('=== Deleting Download (Bloc) ===');
    AppLogger.i('Download ID: $event.id');

    try {
      await _repository.deleteDownload(event.id);
      AppLogger.i('Repository delete command completed');

      // Remove from state
      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
      updatedDownloads.remove(event.id);

      // Remove progress
      final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
      updatedProgress.remove(event.id);

      // Remove error
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors.remove(event.id);

      emit(state.copyWith(
        downloads: updatedDownloads,
        downloadProgress: updatedProgress,
        downloadErrors: updatedErrors,
      ));

      AppLogger.i('State updated with deleted download');
      AppLogger.i('=== Download Deleted Successfully (Bloc) ===');
    } catch (e) {
      AppLogger.e('=== Delete Download Failed (Bloc) ===');
      AppLogger.e('Error: $e');
      AppLogger.e('Download ID: $event.id');

      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      updatedErrors[event.id] = e.toString();
      emit(state.copyWith(downloadErrors: updatedErrors));
      AppLogger.e('Error stored for download: $event.id');
      AppLogger.e('=== Delete Failure Handled (Bloc) ===');
    }
  }

  /// Auto-resume downloads
  Future<void> _onAutoResumeDownloads(
      AutoResumeDownloads event, Emitter<DownloadManagerState> emit) async {
    AppLogger.i('=== Auto-Resuming Downloads (Bloc) ===');

    try {
      emit(state.copyWith(isLoading: true));

      await _repository.autoResumeDownloads();

      // Reload downloads to get updated status
      final downloads = await _repository.getDownloads();

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

  /// Get download for a model by model ID
  DownloadTask? getDownloadForModel(String modelId) {
    for (final entry in state.downloads.entries) {
      final download = entry.value;
      if (download.metadata?['modelId'] == modelId) {
        return download;
      }
    }
    return null;
  }

  /// Get download task ID for a model
  String? getDownloadTaskIdForModel(String modelId) {
    for (final entry in state.downloads.entries) {
      final download = entry.value;
      if (download.metadata?['modelId'] == modelId) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get progress for a model
  DownloadProgress? getProgressForModel(String modelId) {
    final taskId = getDownloadTaskIdForModel(modelId);
    if (taskId != null) {
      return state.getDownloadProgress(taskId);
    }
    return null;
  }

  /// Get error for a model
  String? getErrorForModel(String modelId) {
    final taskId = getDownloadTaskIdForModel(modelId);
    if (taskId != null) {
      return state.getDownloadError(taskId);
    }
    return null;
  }

  @override
  Future<void> close() {
    // No progress subscriptions to clean up
    return super.close();
  }

  @override
  DownloadManagerState? fromJson(Map<String, dynamic> json) {
    try {
      final downloadsJson = json['downloads'] as Map<String, dynamic>? ?? {};
      final downloadProgressJson = json['downloadProgress'] as Map<String, dynamic>? ?? {};
      final downloadErrorsJson = json['downloadErrors'] as Map<String, dynamic>? ?? {};
      final fileValidationsJson = json['fileValidations'] as Map<String, dynamic>? ?? {};

      // Convert downloads
      final downloads = <String, DownloadTask>{};
      for (final entry in downloadsJson.entries) {
        final taskJson = entry.value as Map<String, dynamic>;
        downloads[entry.key] = DownloadTask.fromMap(taskJson);
      }

      // Convert download progress
      final downloadProgress = <String, DownloadProgress>{};
      for (final entry in downloadProgressJson.entries) {
        final progressJson = entry.value as Map<String, dynamic>;
        downloadProgress[entry.key] = DownloadProgress.fromMap(progressJson);
      }

      // Convert download errors (simple string map)
      final downloadErrors = Map<String, String>.from(downloadErrorsJson);

      // Convert file validations (simple bool map)
      final fileValidations = <String, bool>{};
      for (final entry in fileValidationsJson.entries) {
        fileValidations[entry.key] = entry.value as bool;
      }

      return DownloadManagerState(
        downloads: downloads,
        downloadProgress: downloadProgress,
        downloadErrors: downloadErrors,
        fileValidations: fileValidations,
        isLoading: json['isLoading'] as bool? ?? false,
        error: json['error'] as String?,
      );
    } catch (e) {
      AppLogger.e('Error deserializing DownloadManagerState: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(DownloadManagerState state) {
    try {
      // Convert downloads to JSON
      final downloadsJson = <String, dynamic>{};
      for (final entry in state.downloads.entries) {
        downloadsJson[entry.key] = entry.value.toMap();
      }

      // Convert download progress to JSON
      final downloadProgressJson = <String, dynamic>{};
      for (final entry in state.downloadProgress.entries) {
        downloadProgressJson[entry.key] = entry.value.toMap();
      }

      // Convert download errors (simple string map)
      final downloadErrorsJson = state.downloadErrors;

      // Convert file validations (simple bool map)
      final fileValidationsJson = state.fileValidations;

      return {
        'downloads': downloadsJson,
        'downloadProgress': downloadProgressJson,
        'downloadErrors': downloadErrorsJson,
        'fileValidations': fileValidationsJson,
        'isLoading': state.isLoading,
        'error': state.error,
      };
    } catch (e) {
      AppLogger.e('Error serializing DownloadManagerState: $e');
      return null;
    }
  }
}
