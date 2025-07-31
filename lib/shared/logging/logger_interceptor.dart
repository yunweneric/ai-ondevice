import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:offline_ai/shared/shared.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        AppLogger.i({
          'request.uri.path': options.uri.path,
          'base_url': options.baseUrl,
          'method': options.method,
          'body': options.data,
          'headers': options.headers,
        });
      } catch (e) {
        AppLogger.i(['Error logging request: $e']);
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // if (kDebugMode) {
    //   debugPrint('*** Response ***');
    //   try {
    //     if (response.statusCode! > 299) {
    //       AppLogger.log({
    //         'base_url': response.requestOptions.uri,
    //         'method': response.requestOptions.method,
    //         'body': response.data,
    //         'headers': response.requestOptions.headers,
    //         'status': response.statusCode,
    //       }, isError: true);
    //     } else {
    //       AppLogger.log({
    //         'base_url': response.requestOptions.uri,
    //         'method': response.requestOptions.method,
    //         'body': response.data,
    //         'headers': response.requestOptions.headers,
    //         'status': response.statusCode,
    //       });
    //     }
    //   } catch (e) {
    //     AppLogger.log('Error logging response: $e', isError: true);
    //   }
    // }
    super.onResponse(response, handler);
  }
}
