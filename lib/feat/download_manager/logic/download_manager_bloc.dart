import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:flutter_downloader/flutter_downloader.dart' hide DownloadTask;

part 'download_manager_event.dart';
part 'download_manager_state.dart';

// Global ReceivePort for isolate communication
ReceivePort _port = ReceivePort();

class DownloadManagerBloc extends HydratedBloc<DownloadManagerEvent, DownloadManagerState> {
  final DownloadManagerRepository _repository;
  final Map<String, StreamSubscription<DownloadProgress>> _progressSubscriptions = {};

  DownloadManagerBloc(this._repository) : super(const DownloadManagerState()) {
    // Set up isolate communication
    _setupIsolateCommunication();

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

  /// Set up isolate communication for download progress
  void _setupIsolateCommunication() {
    AppLogger.i('=== Setting up Isolate Communication (Bloc) ===');

    try {
      // Register port with name
      IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
      AppLogger.i('Port registered with name: downloader_send_port');

      // Listen for messages from background isolate
      _port.listen((dynamic data) {
        AppLogger.log('=== Received Data from Background Isolate (Bloc) ===');
        AppLogger.log('Data type: ${data.runtimeType}');
        AppLogger.log('Data: $data');

        if (data is List && data.length >= 3) {
          String id = data[0];
          int statusCode = data[1];
          int progress = data[2];

          AppLogger.log('=== Received Progress from Background Isolate (Bloc) ===');
          AppLogger.log('Task ID: $id');
          AppLogger.log('Status Code: $statusCode');
          AppLogger.log('Progress: $progress bytes');

          // Convert status code to DownloadTaskStatus
          final status = _convertStatusFromCode(statusCode);
          AppLogger.log('Converted Status: $status');

          // Update progress in state
          _updateProgressFromIsolate(id, status, progress);
        } else {
          AppLogger.e('Invalid data format received from background isolate');
          AppLogger.e('Expected List with 3+ elements, got: $data');
        }
      });

      AppLogger.i('Isolate communication setup completed');
    } catch (e) {
      AppLogger.e('Failed to setup isolate communication: $e');
    }
  }

  /// Convert status code to DownloadTaskStatus
  DownloadTaskStatus _convertStatusFromCode(int statusCode) {
    switch (statusCode) {
      case 0:
        return DownloadTaskStatus.undefined;
      case 1:
        return DownloadTaskStatus.enqueued;
      case 2:
        return DownloadTaskStatus.running;
      case 3:
        return DownloadTaskStatus.complete;
      case 4:
        return DownloadTaskStatus.failed;
      case 5:
        return DownloadTaskStatus.canceled;
      case 6:
        return DownloadTaskStatus.paused;
      default:
        return DownloadTaskStatus.undefined;
    }
  }

  /// Update progress from background isolate
  void _updateProgressFromIsolate(String taskId, DownloadTaskStatus status, int progress) {
    AppLogger.i('=== Updating Progress from Isolate (Bloc) ===');
    AppLogger.i('Task ID: $taskId');
    AppLogger.i('Status: $status');
    AppLogger.i('Progress: $progress bytes');

    // Find the download task
    final downloadTask = state.downloads[taskId];
    if (downloadTask == null) {
      AppLogger.e('Download task not found for progress update: $taskId');
      AppLogger.e('Available task IDs in state: ${state.downloads.keys.toList()}');
      AppLogger.e('This might be a FlutterDownloader task ID vs custom ID mismatch');
      return;
    }

    AppLogger.i('Found download task:');
    AppLogger.i('  - File: ${downloadTask.fileName}');
    AppLogger.i('  - Current status: ${downloadTask.status}');
    AppLogger.i('  - Current progress: ${downloadTask.downloadedBytes} bytes');

    // Update download task
    final updatedTask = downloadTask.copyWith(
      status: _convertDownloadStatus(status),
      downloadedBytes: progress,
    );

    // Update downloads map
    final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
    updatedDownloads[taskId] = updatedTask;

    // Create progress object
    final downloadProgress = DownloadProgress(
      taskId: taskId,
      downloadedBytes: progress,
      totalBytes: downloadTask.totalBytes,
      progress: downloadTask.totalBytes > 0 ? progress / downloadTask.totalBytes : 0.0,
      speed: _calculateSpeed(progress),
      estimatedTimeRemaining: _calculateEstimatedTime(progress, downloadTask.totalBytes),
      timestamp: DateTime.now(),
    );

    // Update progress map
    final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
    updatedProgress[taskId] = downloadProgress;

    // Emit new state
    emit(state.copyWith(
      downloads: updatedDownloads,
      downloadProgress: updatedProgress,
    ));

    AppLogger.i('Progress updated in state:');
    AppLogger.i('  - New status: ${updatedTask.status}');
    AppLogger.i('  - New progress: $progress bytes');
    AppLogger.i('  - Progress %: ${(downloadProgress.progress * 100).toStringAsFixed(1)}%');
    AppLogger.i('  - Speed: ${downloadProgress.speedText}');
    AppLogger.i('  - ETA: ${downloadProgress.timeRemainingText}');

    // Handle completion
    if (status == DownloadTaskStatus.complete) {
      AppLogger.i('Download completed, handling completion for: $taskId');
      _handleDownloadComplete(taskId);
    } else if (status == DownloadTaskStatus.failed) {
      AppLogger.e('Download failed, handling failure for: $taskId');
      _handleDownloadFailed(taskId);
    }

    AppLogger.i('=== Progress Update Complete (Bloc) ===');
  }

  /// Convert flutter_downloader status to our DownloadStatus
  DownloadStatus _convertDownloadStatus(DownloadTaskStatus status) {
    switch (status) {
      case DownloadTaskStatus.undefined:
        return DownloadStatus.idle;
      case DownloadTaskStatus.enqueued:
        return DownloadStatus.downloading;
      case DownloadTaskStatus.running:
        return DownloadStatus.downloading;
      case DownloadTaskStatus.complete:
        return DownloadStatus.completed;
      case DownloadTaskStatus.failed:
        return DownloadStatus.failed;
      case DownloadTaskStatus.canceled:
        return DownloadStatus.cancelled;
      case DownloadTaskStatus.paused:
        return DownloadStatus.paused;
    }
  }

  /// Calculate download speed
  double _calculateSpeed(int downloadedBytes) {
    // Simple implementation - in production you'd track speed over time
    return downloadedBytes.toDouble();
  }

  /// Calculate estimated time remaining
  Duration _calculateEstimatedTime(int downloadedBytes, int totalBytes) {
    if (totalBytes <= 0 || downloadedBytes <= 0) {
      return Duration.zero;
    }
    // Simple calculation - in production you'd use actual speed data
    final remainingBytes = totalBytes - downloadedBytes;
    return Duration(seconds: remainingBytes ~/ 1024); // Rough estimate
  }

  /// Handle download completion
  void _handleDownloadComplete(String taskId) {
    AppLogger.i('Handling download completion for: $taskId');
    // Add any completion logic here
  }

  /// Handle download failure
  void _handleDownloadFailed(String taskId) {
    AppLogger.e('Handling download failure for: $taskId');
    // Add any failure logic here
  }

  /// Start a new download
  Future<void> _onStartDownload(
    StartDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    AppLogger.i('=== Starting Download (Bloc) ===');
    AppLogger.i('Download ID: ${event.customId ?? 'auto-generated'}');
    AppLogger.i('URL: ${event.url}');
    AppLogger.i('FileName: ${event.fileName}');
    AppLogger.i('Metadata: ${event.metadata}');

    try {
      emit(state.copyWith(isLoading: true, error: null));
      AppLogger.i('State updated: isLoading = true');

      // Start the download
      AppLogger.i('Calling repository to start download...');
      final downloadTask = await _repository.startDownload(
        url: event.url,
        fileName: event.fileName,
        customId: event.customId,
        metadata: event.metadata,
      );

      AppLogger.i('Download task created successfully:');
      AppLogger.i('  - Task ID: ${downloadTask.id}');
      AppLogger.i('  - File: ${downloadTask.fileName}');
      AppLogger.i('  - Status: ${downloadTask.status}');
      AppLogger.i('  - Created: ${downloadTask.createdAt}');

      // Update downloads map
      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
      updatedDownloads[downloadTask.id] = downloadTask;
      AppLogger.i('Updated downloads map, total downloads: ${updatedDownloads.length}');

      emit(state.copyWith(
        downloads: updatedDownloads,
        isLoading: false,
      ));
      AppLogger.i('State updated: isLoading = false, downloads count: ${updatedDownloads.length}');

      // Listen to progress
      AppLogger.i('Setting up progress listener for task: ${downloadTask.id}');
      _listenToProgress(downloadTask.id, emit);

      // Also store with FlutterDownloader task ID if different
      if (downloadTask.id != event.customId) {
        AppLogger.i('Storing download with FlutterDownloader task ID: ${downloadTask.id}');
        AppLogger.i('Original custom ID: ${event.customId}');
      }

      AppLogger.i('=== Download Started Successfully (Bloc) ===');
    } catch (e) {
      AppLogger.e('=== Download Start Failed (Bloc) ===');
      AppLogger.e('Error: $e');
      AppLogger.e('Download ID: ${event.customId ?? 'auto-generated'}');
      AppLogger.e('URL: ${event.url}');

      // Update error state
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      final errorId = event.customId ?? 'unknown';
      updatedErrors[errorId] = e.toString();
      AppLogger.e('Error stored for ID: $errorId');

      emit(state.copyWith(
        downloadErrors: updatedErrors,
        isLoading: false,
        error: e.toString(),
      ));
      AppLogger.e('State updated with error, isLoading = false');
      AppLogger.e('=== Download Start Failure Handled (Bloc) ===');
    }
  }

  /// Pause a download
  Future<void> _onPauseDownload(
    PauseDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    AppLogger.i('=== Pausing Download (Bloc) ===');
    AppLogger.i('Download ID: $event.id');

    final currentTask = state.getDownloadTask(event.id);
    if (currentTask != null) {
      AppLogger.i('Current task info:');
      AppLogger.i('  - File: ${currentTask.fileName}');
      AppLogger.i('  - Status: ${currentTask.status}');
      AppLogger.i('  - Progress: ${currentTask.downloadedBytes} bytes');
      AppLogger.i('  - Progress %: ${(currentTask.progress * 100).toStringAsFixed(1)}%');
    }

    try {
      AppLogger.i('Calling repository to pause download...');
      await _repository.pauseDownload(event.id);
      AppLogger.i('Repository pause command completed');

      // Update download task
      final downloadTask = _repository.getDownloadTask(event.id);
      if (downloadTask != null) {
        AppLogger.i('Updated task info:');
        AppLogger.i('  - Status: ${downloadTask.status}');
        AppLogger.i('  - Progress: ${downloadTask.downloadedBytes} bytes');

        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
        AppLogger.i('State updated with paused download');
      } else {
        AppLogger.e('Download task not found after pause: $event.id');
      }

      // Cancel progress subscription
      _progressSubscriptions[event.id]?.cancel();
      _progressSubscriptions.remove(event.id);
      AppLogger.i('Progress subscription cancelled for: $event.id');

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
  Future<void> _onResumeDownload(
    ResumeDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    AppLogger.i('=== Resuming Download (Bloc) ===');
    AppLogger.i('Download ID: $event.id');

    final currentTask = state.getDownloadTask(event.id);
    if (currentTask != null) {
      AppLogger.i('Current task info:');
      AppLogger.i('  - File: ${currentTask.fileName}');
      AppLogger.i('  - Status: ${currentTask.status}');
      AppLogger.i('  - Progress: ${currentTask.downloadedBytes} bytes');
      AppLogger.i('  - Progress %: ${(currentTask.progress * 100).toStringAsFixed(1)}%');
    }

    try {
      AppLogger.i('Calling repository to resume download...');
      await _repository.resumeDownload(event.id);
      AppLogger.i('Repository resume command completed');

      // Update download task
      final downloadTask = _repository.getDownloadTask(event.id);
      if (downloadTask != null) {
        AppLogger.i('Updated task info:');
        AppLogger.i('  - Status: ${downloadTask.status}');
        AppLogger.i('  - Progress: ${downloadTask.downloadedBytes} bytes');

        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
        updatedDownloads[event.id] = downloadTask;
        emit(state.copyWith(downloads: updatedDownloads));
        AppLogger.i('State updated with resumed download');
      } else {
        AppLogger.e('Download task not found after resume: $event.id');
      }

      // Listen to progress again
      AppLogger.i('Setting up progress listener for resumed download: $event.id');
      _listenToProgress(event.id, emit);

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
  Future<void> _onCancelDownload(
    CancelDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    AppLogger.i('=== Cancelling Download (Bloc) ===');
    AppLogger.i('Download ID: $event.id');

    final currentTask = state.getDownloadTask(event.id);
    if (currentTask != null) {
      AppLogger.i('Current task info:');
      AppLogger.i('  - File: ${currentTask.fileName}');
      AppLogger.i('  - Status: ${currentTask.status}');
      AppLogger.i('  - Progress: ${currentTask.downloadedBytes} bytes');
      AppLogger.i('  - Progress %: ${(currentTask.progress * 100).toStringAsFixed(1)}%');
    }

    try {
      AppLogger.i('Calling repository to cancel download...');
      await _repository.cancelDownload(event.id);
      AppLogger.i('Repository cancel command completed');

      // Remove from downloads
      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads);
      final removedTask = updatedDownloads.remove(event.id);
      AppLogger.i('Removed from downloads map: ${removedTask?.fileName ?? 'unknown'}');

      // Remove progress
      final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
      final removedProgress = updatedProgress.remove(event.id);
      AppLogger.i('Removed progress tracking: ${removedProgress != null ? 'yes' : 'no'}');

      // Remove errors
      final updatedErrors = Map<String, String>.from(state.downloadErrors);
      final removedError = updatedErrors.remove(event.id);
      AppLogger.i('Removed error tracking: ${removedError != null ? 'yes' : 'no'}');

      emit(state.copyWith(
        downloads: updatedDownloads,
        downloadProgress: updatedProgress,
        downloadErrors: updatedErrors,
      ));
      AppLogger.i('State updated, remaining downloads: ${updatedDownloads.length}');

      // Cancel progress subscription
      _progressSubscriptions[event.id]?.cancel();
      _progressSubscriptions.remove(event.id);
      AppLogger.i('Progress subscription cancelled for: $event.id');

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
    AppLogger.i('=== Loading Downloads (Bloc) ===');

    try {
      emit(state.copyWith(isLoading: true));
      AppLogger.i('State updated: isLoading = true');

      final downloads = _repository.getDownloads();
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

      // Set up progress listeners for active downloads
      int activeCount = 0;
      for (final entry in downloads.entries) {
        final taskId = entry.key;
        final downloadTask = entry.value;

        if (downloadTask.isActive) {
          AppLogger.i('Setting up progress listener for active download: $taskId');
          _listenToProgress(taskId, emit);
          activeCount++;
        }
      }
      AppLogger.i('Progress listeners set up for $activeCount active downloads');

      emit(state.copyWith(
        downloads: downloads,
        isLoading: false,
      ));
      AppLogger.i('State updated: isLoading = false, downloads count: ${downloads.length}');

      // Auto-resume interrupted downloads after loading
      AppLogger.i('Triggering auto-resume for interrupted downloads...');
      add(const AutoResumeDownloads());

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
          _listenToProgress(taskId, emit);
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
  void _listenToProgress(String taskId, Emitter<DownloadManagerState> emit) {
    AppLogger.i('=== Setting Up Progress Listener (Bloc) ===');
    AppLogger.i('Task ID: $taskId');

    // Cancel existing subscription
    final existingSubscription = _progressSubscriptions[taskId];
    if (existingSubscription != null) {
      AppLogger.i('Cancelling existing progress subscription for: $taskId');
      existingSubscription.cancel();
    }

    // Create new subscription
    final progressStream = _repository.getProgressStream(taskId);
    if (progressStream != null) {
      AppLogger.i('Progress stream available, creating subscription...');

      _progressSubscriptions[taskId] = progressStream.listen(
        (progress) {
          AppLogger.log('=== Progress Update (Bloc) ===');
          AppLogger.log('Task ID: $taskId');
          AppLogger.log('Progress: ${progress.downloadedBytes} bytes');
          AppLogger.log('Total: ${progress.totalBytes} bytes');
          AppLogger.log('Percentage: ${(progress.progress * 100).toStringAsFixed(1)}%');
          AppLogger.log('Speed: ${progress.speedText}');
          AppLogger.log('ETA: ${progress.timeRemainingText}');
          AppLogger.log('Downloaded: ${progress.downloadedSizeText}/${progress.totalSizeText}');

          final updatedProgress = Map<String, DownloadProgress>.from(state.downloadProgress);
          updatedProgress[taskId] = progress;

          emit(state.copyWith(downloadProgress: updatedProgress));
          AppLogger.log('State updated with progress for: $taskId');
        },
        onError: (error) {
          AppLogger.e('=== Progress Stream Error (Bloc) ===');
          AppLogger.e('Task ID: $taskId');
          AppLogger.e('Error: $error');

          final updatedErrors = Map<String, String>.from(state.downloadErrors);
          updatedErrors[taskId] = error.toString();
          emit(state.copyWith(downloadErrors: updatedErrors));
          AppLogger.e('Error stored in state for: $taskId');
        },
        onDone: () {
          AppLogger.i('=== Progress Stream Completed (Bloc) ===');
          AppLogger.i('Task ID: $taskId');
          AppLogger.i('Progress stream finished for: $taskId');
        },
      );

      AppLogger.i('Progress listener set up successfully for: $taskId');
    } else {
      AppLogger.e('Progress stream not available for task: $taskId');
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
