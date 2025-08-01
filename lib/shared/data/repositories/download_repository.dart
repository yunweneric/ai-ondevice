import 'package:offline_ai/shared/shared.dart';

class DownloadRepository {
  final DownloadService _downloadService;

  DownloadRepository(this._downloadService);

  /// Get all downloads
  Map<String, DownloadInfo> get downloads => _downloadService.downloads;

  /// Get download info by ID
  DownloadInfo? getDownloadInfo(String id) => _downloadService.getDownloadInfo(id);

  /// Get progress stream for a download
  Stream<DownloadProgress>? getProgressStream(String id) => _downloadService.getProgressStream(id);

  /// Start a new download
  Future<DownloadInfo> startDownload({
    required String url,
    required String fileName,
    String? customId,
  }) async {
    return await _downloadService.startDownload(
      url: url,
      fileName: fileName,
      customId: customId,
    );
  }

  /// Resume a paused download
  Future<void> resumeDownload(String id) async {
    await _downloadService.resumeDownload(id);
  }

  /// Pause a download
  Future<void> pauseDownload(String id) async {
    await _downloadService.pauseDownload(id);
  }

  /// Cancel a download
  Future<void> cancelDownload(String id) async {
    await _downloadService.cancelDownload(id);
  }

  /// Delete a completed download
  Future<void> deleteDownload(String id) async {
    await _downloadService.deleteDownload(id);
  }
}
