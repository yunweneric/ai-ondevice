import 'package:dio/dio.dart';

class DownloadService {
  final Dio _dio;

  DownloadService(this._dio);

  Future<Response<dynamic>> downloadFile(String url) async {
    final response = await _dio.get(url);
    return response;
  }
}
