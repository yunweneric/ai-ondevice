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
    final localNotificationService = LocalNotificationService();
    final downloadManagerService = DownloadManagerService(localNotificationService);
    final fileManagementService = FileManagementService();

    getIt.registerSingleton<LocalNotificationService>(localNotificationService);
    getIt.registerSingleton<DownloadManagerService>(downloadManagerService);
    getIt.registerSingleton<FileManagementService>(fileManagementService);

    final downloadManagerRepository = DownloadManagerRepository(downloadManagerService);
    final fileManagementRepository = FileManagementRepository(fileManagementService);

    getIt.registerSingleton<DownloadManagerRepository>(downloadManagerRepository);
    getIt.registerSingleton<FileManagementRepository>(fileManagementRepository);

    final themeBloc = ThemeBloc();
    final languageBloc = LanguageBloc();
    final bottomNavBarBloc = BottomNavBarBloc();
    final downloadManagerBloc = DownloadManagerBloc(downloadManagerRepository);
    final fileManagementBloc = FileManagementBloc(fileManagementRepository);
    final permissionService = PermissionService();
    final permissionBloc = PermissionBloc(permissionService);

    getIt
      ..registerSingleton<ThemeBloc>(themeBloc)
      ..registerSingleton<LanguageBloc>(languageBloc)
      ..registerSingleton<BottomNavBarBloc>(bottomNavBarBloc)
      ..registerSingleton<DownloadManagerBloc>(downloadManagerBloc)
      ..registerSingleton<FileManagementBloc>(fileManagementBloc)
      ..registerSingleton<PermissionService>(permissionService)
      ..registerSingleton<PermissionBloc>(permissionBloc);

    if (kDebugMode) {
      print('Service Locators registered!');
    }
  }
}
