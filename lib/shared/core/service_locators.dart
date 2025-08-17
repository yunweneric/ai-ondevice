import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import '../data/services/gemma_service.dart';

final getIt = GetIt.instance;

class ServiceLocators {
  static Future<void> register() async {
    // final appRouter = appRouter;
    getIt.registerSingleton<GoRouter>(appRouter);

    final options = BaseOptions();
    Dio dioClient = Dio(options)..interceptors.addAll([LoggerInterceptor()]);
    final localNotificationService = LocalNotificationService();
    final downloadService = DownloadService(dioClient, localNotificationService);
    final modelDownloadService = ModelDownloadService(dioClient, localNotificationService);

    getIt.registerSingleton<LocalNotificationService>(localNotificationService);
    getIt.registerSingleton<DownloadService>(downloadService);
    getIt.registerSingleton<ModelDownloadService>(modelDownloadService);

    final downloadRepository = DownloadRepository(downloadService);
    final modelDownloadRepository = ModelDownloadRepository(modelDownloadService);
    getIt.registerSingleton<DownloadRepository>(downloadRepository);
    getIt.registerSingleton<ModelDownloadRepository>(modelDownloadRepository);

    final themeBloc = ThemeBloc();
    final languageBloc = LanguageBloc();
    final bottomNavBarBloc = BottomNavBarBloc();
    final modelDownloadBloc = ModelDownloadBloc(modelDownloadRepository);
    final permissionService = PermissionService();
    final permissionBloc = PermissionBloc(permissionService);

    getIt
      ..registerSingleton<ThemeBloc>(themeBloc)
      ..registerSingleton<LanguageBloc>(languageBloc)
      ..registerSingleton<BottomNavBarBloc>(bottomNavBarBloc)
      ..registerSingleton<ModelDownloadBloc>(modelDownloadBloc)
      ..registerSingleton<PermissionService>(permissionService)
      ..registerSingleton<PermissionBloc>(permissionBloc)
      ..registerSingleton<GemmaService>(GemmaService());

    if (kDebugMode) {
      print('Service Locators registered!');
    }
  }
}
