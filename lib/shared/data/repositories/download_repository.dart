import 'package:offline_ai/shared/shared.dart';

class DownloadRepository {
  final DownloadService _downloadService;

  DownloadRepository(this._downloadService);

  Future<dynamic> downloadFile(String url) async {
    final response = await _downloadService.downloadFile(url);
    return response;
  }
}
