import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/shared/shared.dart';

final getIt = GetIt.instance;

class ServiceLocators {
  static Future<void> register() async {
    // final appRouter = appRouter;
    getIt.registerSingleton<GoRouter>(appRouter);

    final options = BaseOptions();
    Dio dioClient = Dio(options)..interceptors.addAll([LoggerInterceptor()]);
    final downloadService = DownloadService(dioClient);
    final localNotificationService = LocalNotificationService();

    getIt.registerSingleton<DownloadService>(downloadService);
    getIt.registerSingleton<LocalNotificationService>(localNotificationService);

    final downloadRepository = DownloadRepository(downloadService);
    getIt.registerSingleton<DownloadRepository>(downloadRepository);

    final themeBloc = ThemeBloc();
    final languageBloc = LanguageBloc();
    final bottomNavBarBloc = BottomNavBarBloc();

    getIt
      ..registerSingleton<ThemeBloc>(themeBloc)
      ..registerSingleton<LanguageBloc>(languageBloc)
      ..registerSingleton<BottomNavBarBloc>(bottomNavBarBloc);

    if (kDebugMode) {
      print('Service Locators registered!');
    }
  }
}
