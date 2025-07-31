import 'package:dio/dio.dart';
import 'package:offline_ai/shared/shared.dart';

class AppException implements Exception {
  AppException({required this.error, this.message});
  final dynamic error;
  final String? message;

  Map<String, dynamic> toJson() {
    return {'error': error};
  }

  static String getMessage(dynamic e) {
    String message =
        "There was an error processing your request. Please try again later!";
    if (e.runtimeType == DioException) {
      return e.message;
    }

    AppLogger.e(['AppException', message]);
    return message;
  }
}
