import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

part 'model_downloader_event.dart';
part 'model_downloader_state.dart';

class ModelDownloaderBloc extends HydratedBloc<ModelDownloaderEvent, ModelDownloaderState> {
  final DownloadModelService _downloadService;

  ModelDownloaderBloc(this._downloadService)
      : super(const ModelDownloaderInitial(
          downloads: {},
          totalDownloads: 0,
          activeDownloads: 0,
          selectedModel: null,
        )) {
    on<LoadDownloadsEvent>(_onLoadDownloads);
    on<StartDownloadEvent>(_onStartDownload);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<DeleteDownloadEvent>(_onDeleteDownload);
    on<DeleteIncompleteDownloadEvent>(_onDeleteIncompleteDownload);
    on<UpdateDownloadProgressEvent>(_onUpdateDownloadProgress);
    on<DownloadCompletedEvent>(_onDownloadCompleted);
    on<DownloadErrorEvent>(_onDownloadError);
    on<CheckDownloadStatusEvent>(_onCheckDownloadStatus);
    on<ClearDownloadsEvent>(_onClearDownloads);
    on<SelectModelEvent>(_onSelectModel);
  }

  Future<void> _onLoadDownloads(
      LoadDownloadsEvent event, Emitter<ModelDownloaderState> emit) async {
    try {
      emit(ModelDownloaderLoading(
        downloads: state.downloads,
        totalDownloads: state.totalDownloads,
        activeDownloads: state.activeDownloads,
        selectedModel: state.selectedModel,
      ));

      // Check status of all existing downloads
      final updatedDownloads = <String, DownloadInfo>{};
      int activeCount = 0;

      for (final entry in state.downloads.entries) {
        final model = entry.value.model;
        final status = await _downloadService.getDownloadStatus(model);

        final updatedInfo = entry.value.copyWith(
          status: status,
          isDownloading: false, // Reset downloading state on load
        );

        updatedDownloads[entry.key] = updatedInfo;

        if (status == DownloadStatus.incomplete) {
          activeCount++;
        }
      }

      emit(ModelDownloaderLoaded(
        downloads: updatedDownloads,
        totalDownloads: updatedDownloads.length,
        activeDownloads: activeCount,
        selectedModel: state.selectedModel,
      ));
    } catch (e) {
      emit(ModelDownloaderError(
        message: e.toString(),
        downloads: state.downloads,
        totalDownloads: state.totalDownloads,
        activeDownloads: state.activeDownloads,
        selectedModel: state.selectedModel,
      ));
    }
  }

  Future<void> _onStartDownload(
    StartDownloadEvent event,
    Emitter<ModelDownloaderState> emit,
  ) async {
    try {
      final modelKey = _generateModelKey(event.model);

      // Check if download already exists
      if (state.downloads.containsKey(modelKey)) {
        final existingDownload = state.downloads[modelKey]!;
        if (existingDownload.isDownloading) {
          AppLogger.i('Download already in progress for ${event.model.name}');
          return;
        }
      }

      // Create new download info
      final downloadInfo = DownloadInfo(
        model: event.model,
        status: DownloadStatus.notDownloaded,
        isDownloading: true,
        progress: 0.0,
        receivedBytes: 0,
        totalBytes: 0,
        startTime: DateTime.now(),
        lastUpdateTime: DateTime.now(),
      );

      // Update state
      final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
      updatedDownloads[modelKey] = downloadInfo;

      emit(ModelDownloaderDownloading(
        downloads: updatedDownloads,
        totalDownloads: updatedDownloads.length,
        activeDownloads: state.activeDownloads + 1,
        currentDownload: downloadInfo,
        selectedModel: state.selectedModel,
      ));

      AppLogger.i('Starting download for ${event.model.name}');

      // Start actual download
      await _downloadService.downloadModel(
        model: event.model,
        onProgress: (received, total, progress) {
          add(UpdateDownloadProgressEvent(
            modelKey: modelKey,
            received: received,
            total: total,
            progress: progress,
          ));
        },
        onComplete: (file) {
          add(DownloadCompletedEvent(modelKey: modelKey, file: file));
        },
        onError: (error) {
          add(DownloadErrorEvent(modelKey: modelKey, error: error));
        },
      );
    } catch (e) {
      emit(ModelDownloaderError(
        message: 'Failed to start download: $e',
        downloads: state.downloads,
        totalDownloads: state.totalDownloads,
        activeDownloads: state.activeDownloads,
        selectedModel: state.selectedModel,
      ));
    }
  }

  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<ModelDownloaderState> emit,
  ) async {
    try {
      final modelKey = _generateModelKey(event.model);

      if (!state.downloads.containsKey(modelKey)) {
        AppLogger.i('Download not found for cancellation: $modelKey');
        return;
      }

      // Cancel the download
      final cancelled = await _downloadService.cancelDownload();

      if (cancelled) {
        // Update download info
        final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
        final downloadInfo = updatedDownloads[modelKey]!;

        updatedDownloads[modelKey] = downloadInfo.copyWith(
          isDownloading: false,
          status: DownloadStatus.incomplete,
          lastUpdateTime: DateTime.now(),
        );

        emit(ModelDownloaderLoaded(
          downloads: updatedDownloads,
          totalDownloads: updatedDownloads.length,
          activeDownloads: state.activeDownloads - 1,
          selectedModel: state.selectedModel,
        ));

        AppLogger.i('Download cancelled successfully: $modelKey');
      }
    } catch (e) {
      AppLogger.e('Error cancelling download: $e');
    }
  }

  Future<void> _onDeleteDownload(
    DeleteDownloadEvent event,
    Emitter<ModelDownloaderState> emit,
  ) async {
    try {
      final modelKey = _generateModelKey(event.model);

      if (!state.downloads.containsKey(modelKey)) {
        AppLogger.i('Download not found for deletion: $modelKey');
        return;
      }

      // Delete the downloaded file
      final downloadInfo = state.downloads[modelKey]!;
      final deleted = await _downloadService.deleteDownloadedModel(downloadInfo.model);

      if (deleted) {
        // Remove from downloads
        final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
        updatedDownloads.remove(modelKey);

        final newActiveDownloads = downloadInfo.status == DownloadStatus.incomplete
            ? state.activeDownloads - 1
            : state.activeDownloads;

        emit(ModelDownloaderLoaded(
          downloads: updatedDownloads,
          totalDownloads: updatedDownloads.length,
          activeDownloads: newActiveDownloads,
          selectedModel: state.selectedModel,
        ));

        AppLogger.i('Download deleted successfully: $modelKey');
      }
    } catch (e) {
      AppLogger.e('Error deleting download: $e');
    }
  }

  Future<void> _onDeleteIncompleteDownload(
    DeleteIncompleteDownloadEvent event,
    Emitter<ModelDownloaderState> emit,
  ) async {
    try {
      final modelKey = event.modelKey;

      if (!state.downloads.containsKey(modelKey)) {
        AppLogger.i('Download not found for incomplete deletion: $modelKey');
        return;
      }

      // Delete the incomplete download
      final downloadInfo = state.downloads[modelKey]!;
      final deleted = await _downloadService.deleteIncompleteDownload(downloadInfo.model);

      if (deleted) {
        // Remove from downloads
        final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
        updatedDownloads.remove(modelKey);

        final newActiveDownloads = state.activeDownloads - 1;

        emit(ModelDownloaderLoaded(
          downloads: updatedDownloads,
          totalDownloads: updatedDownloads.length,
          activeDownloads: newActiveDownloads,
          selectedModel: state.selectedModel,
        ));

        AppLogger.i('Incomplete download deleted successfully: $modelKey');
      }
    } catch (e) {
      AppLogger.e('Error deleting incomplete download: $e');
    }
  }

  void _onUpdateDownloadProgress(
    UpdateDownloadProgressEvent event,
    Emitter<ModelDownloaderState> emit,
  ) {
    try {
      final modelKey = event.modelKey;

      if (!state.downloads.containsKey(modelKey)) {
        AppLogger.i('Download not found for progress update: $modelKey');
        return;
      }

      // Update download info with progress
      final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
      final downloadInfo = updatedDownloads[modelKey]!;

      updatedDownloads[modelKey] = downloadInfo.copyWith(
        progress: event.progress,
        receivedBytes: event.received,
        totalBytes: event.total,
        lastUpdateTime: DateTime.now(),
        status: DownloadStatus.downloading,
      );

      emit(ModelDownloaderDownloading(
        downloads: updatedDownloads,
        totalDownloads: updatedDownloads.length,
        activeDownloads: state.activeDownloads,
        currentDownload: updatedDownloads[modelKey]!,
        selectedModel: state.selectedModel,
      ));
    } catch (e) {
      AppLogger.e('Error updating download progress: $e');
    }
  }

  void _onDownloadCompleted(
    DownloadCompletedEvent event,
    Emitter<ModelDownloaderState> emit,
  ) {
    try {
      final modelKey = event.modelKey;
      final file = event.file;

      if (!state.downloads.containsKey(modelKey)) {
        AppLogger.i('Download not found for completion: $modelKey');
        return;
      }

      // Update download info as completed
      final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
      final downloadInfo = updatedDownloads[modelKey]!;

      final downloadInfoData = downloadInfo.copyWith(
        status: DownloadStatus.complete,
        isDownloading: false,
        progress: 1.0,
        lastUpdateTime: DateTime.now(),
        completedTime: DateTime.now(),
        model: downloadInfo.model.copyWith(path: file.path),
      );

      updatedDownloads[modelKey] = downloadInfoData;

      emit(ModelDownloaderLoaded(
        downloads: updatedDownloads,
        totalDownloads: updatedDownloads.length,
        activeDownloads: state.activeDownloads - 1,
        selectedModel: downloadInfoData,
      ));

      AppLogger.i('Download completed successfully: $modelKey');
    } catch (e) {
      AppLogger.e('Error handling download completion: $e');
    }
  }

  void _onDownloadError(
    DownloadErrorEvent event,
    Emitter<ModelDownloaderState> emit,
  ) {
    try {
      final modelKey = event.modelKey;

      if (!state.downloads.containsKey(modelKey)) {
        AppLogger.i('Download not found for error handling: $modelKey');
        return;
      }

      // Update download info with error
      final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
      final downloadInfo = updatedDownloads[modelKey]!;

      updatedDownloads[modelKey] = downloadInfo.copyWith(
        status: DownloadStatus.incomplete,
        isDownloading: false,
        lastUpdateTime: DateTime.now(),
        errorMessage: event.error,
      );

      emit(ModelDownloaderLoaded(
        downloads: updatedDownloads,
        totalDownloads: updatedDownloads.length,
        activeDownloads: state.activeDownloads - 1,
        selectedModel: state.selectedModel,
      ));

      AppLogger.e('Download failed: $modelKey - ${event.error}');
    } catch (e) {
      AppLogger.e('Error handling download error: $e');
    }
  }

  Future<void> _onCheckDownloadStatus(
    CheckDownloadStatusEvent event,
    Emitter<ModelDownloaderState> emit,
  ) async {
    try {
      final modelKey = event.modelKey;

      if (!state.downloads.containsKey(modelKey)) {
        AppLogger.i('Download not found for status check: $modelKey');
        return;
      }

      // Check current status
      final downloadInfo = state.downloads[modelKey]!;
      final status = await _downloadService.getDownloadStatus(downloadInfo.model);

      if (status != downloadInfo.status) {
        // Update status if changed
        final updatedDownloads = Map<String, DownloadInfo>.from(state.downloads);
        updatedDownloads[modelKey] = downloadInfo.copyWith(
          status: status,
          lastUpdateTime: DateTime.now(),
        );

        // Recalculate active downloads
        int activeCount = 0;
        for (final info in updatedDownloads.values) {
          if (info.status == DownloadStatus.incomplete) {
            activeCount++;
          }
        }

        emit(ModelDownloaderLoaded(
          downloads: updatedDownloads,
          totalDownloads: updatedDownloads.length,
          activeDownloads: activeCount,
          selectedModel: state.selectedModel,
        ));
      }
    } catch (e) {
      AppLogger.e('Error checking download status: $e');
    }
  }

  /// Generate a unique key for a model
  String _generateModelKey(AiModel model) {
    return '${model.name}_${model.modelVersion}_${model.modelType}';
  }

  /// Get download info for a specific model
  DownloadInfo? getDownloadInfo(AiModel model) {
    final modelKey = _generateModelKey(model);
    return state.downloads[modelKey];
  }

  /// Check if a model is currently downloading
  bool isModelDownloading(AiModel model) {
    final downloadInfo = getDownloadInfo(model);
    return downloadInfo?.isDownloading ?? false;
  }

  /// Check if a model download is complete
  bool isModelDownloaded(AiModel model) {
    final downloadInfo = getDownloadInfo(model);
    return downloadInfo?.status == DownloadStatus.complete;
  }

  /// Check if a model has an incomplete download
  bool hasIncompleteDownload(AiModel model) {
    final downloadInfo = getDownloadInfo(model);
    return downloadInfo?.status == DownloadStatus.incomplete;
  }

  /// Select a model for use
  void selectModel(AiModel model) {
    add(SelectModelEvent(model: model));
  }

  Future<void> _onSelectModel(
    SelectModelEvent event,
    Emitter<ModelDownloaderState> emit,
  ) async {
    try {
      // Check if the model is downloaded
      if (!isModelDownloaded(event.model)) {
        AppLogger.i('Cannot select model ${event.model.name} - not downloaded yet');
        return;
      }

      // Get the download info for the selected model
      final downloadInfo = getDownloadInfo(event.model);
      if (downloadInfo == null) {
        AppLogger.i('Download info not found for model ${event.model.name}');
        return;
      }

      // Update the selected model
      emit(ModelDownloaderLoaded(
        downloads: state.downloads,
        totalDownloads: state.totalDownloads,
        activeDownloads: state.activeDownloads,
        selectedModel: downloadInfo,
      ));

      AppLogger.i('Model ${event.model.name} selected successfully');
    } catch (e) {
      AppLogger.e('Error selecting model: $e');
    }
  }

  Future<void> _onClearDownloads(
    ClearDownloadsEvent event,
    Emitter<ModelDownloaderState> emit,
  ) async {
    try {
      final models = state.downloads.values.toList();
      await _downloadService.clearDownloadDirectory();
      for (final model in models) {
        await _downloadService.deleteDownloadedModel(model.model);
      }
      emit(const ModelDownloaderInitial(
        downloads: {},
        totalDownloads: 0,
        activeDownloads: 0,
        selectedModel: null,
      ));
      AppLogger.i('Downloads cleared successfully');
    } catch (e) {
      AppLogger.e('Error clearing downloads: $e');
    }
  }

  @override
  Map<String, dynamic>? toJson(ModelDownloaderState state) {
    try {
      final downloadsJson = <String, dynamic>{};
      for (final entry in state.downloads.entries) {
        downloadsJson[entry.key] = entry.value.toJson();
      }

      return {
        'downloads': downloadsJson,
        'totalDownloads': state.totalDownloads,
        'activeDownloads': state.activeDownloads,
        'selectedModel': state.selectedModel?.toJson(),
      };
    } catch (e) {
      AppLogger.e('Error serializing ModelDownloaderState: $e');
      return null;
    }
  }

  @override
  ModelDownloaderState? fromJson(Map<String, dynamic> json) {
    try {
      final downloadsMap = <String, DownloadInfo>{};
      final downloadsJson = json['downloads'] as Map<String, dynamic>?;

      if (downloadsJson != null) {
        for (final entry in downloadsJson.entries) {
          final downloadJson = entry.value as Map<String, dynamic>;
          downloadsMap[entry.key] = DownloadInfo.fromJson(downloadJson);
        }
      }

      final selectedModel = json['selectedModel'] != null
          ? DownloadInfo.fromJson(json['selectedModel'] as Map<String, dynamic>)
          : null;

      return ModelDownloaderLoaded(
        downloads: downloadsMap,
        totalDownloads: json['totalDownloads'] as int? ?? 0,
        activeDownloads: json['activeDownloads'] as int? ?? 0,
        selectedModel: selectedModel,
      );
    } catch (e) {
      AppLogger.e('Error deserializing ModelDownloaderState: $e');
      return const ModelDownloaderInitial(
        downloads: {},
        totalDownloads: 0,
        activeDownloads: 0,
        selectedModel: null,
      );
    }
  }
}
