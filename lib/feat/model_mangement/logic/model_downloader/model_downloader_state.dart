part of 'model_downloader_bloc.dart';

sealed class ModelDownloaderState extends Equatable {
  final Map<String, DownloadInfo> downloads;
  final int totalDownloads;
  final int activeDownloads;
  final DownloadInfo? selectedModel;

  const ModelDownloaderState({
    required this.downloads,
    required this.totalDownloads,
    required this.activeDownloads,
    required this.selectedModel,
  });

  @override
  List<Object?> get props => [downloads, totalDownloads, activeDownloads, selectedModel];
}

/// Initial state
final class ModelDownloaderInitial extends ModelDownloaderState {
  const ModelDownloaderInitial({
    required super.downloads,
    required super.totalDownloads,
    required super.activeDownloads,
    required super.selectedModel,
  });
}

/// Loading state
final class ModelDownloaderLoading extends ModelDownloaderState {
  const ModelDownloaderLoading({
    required super.downloads,
    required super.totalDownloads,
    required super.activeDownloads,
    required super.selectedModel,
  });
}

/// Loaded state with all downloads
final class ModelDownloaderLoaded extends ModelDownloaderState {
  const ModelDownloaderLoaded({
    required super.downloads,
    required super.totalDownloads,
    required super.activeDownloads,
    required super.selectedModel,
  });
}

/// Downloading state with current download info
final class ModelDownloaderDownloading extends ModelDownloaderState {
  final DownloadInfo currentDownload;

  const ModelDownloaderDownloading({
    required super.downloads,
    required super.totalDownloads,
    required super.activeDownloads,
    required this.currentDownload,
    required super.selectedModel,
  });

  @override
  List<Object?> get props => [...super.props, currentDownload];
}

/// Error state
final class ModelDownloaderError extends ModelDownloaderState {
  final String message;

  const ModelDownloaderError({
    required this.message,
    required super.downloads,
    required super.totalDownloads,
    required super.activeDownloads,
    required super.selectedModel,
  });

  @override
  List<Object?> get props => [...super.props, message];
}
