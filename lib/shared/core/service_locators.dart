import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/feat/chat/chat.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

class ServiceLocators {
  static Future<void> register() async {
    // final appRouter = appRouter;
    getIt.registerSingleton<GoRouter>(appRouter);
    final sharedPreferences = await SharedPreferences.getInstance();

    final options = BaseOptions();
    final dioClient = Dio(options)..interceptors.addAll([LoggerInterceptor()]);
    final localNotificationService = LocalNotificationService();
    final fileManagementService = FileManagementService();
    final localStorageService = LocalStorageService(sharedPreferences);
    getIt.registerSingleton<Dio>(dioClient);
    getIt.registerSingleton<LocalNotificationService>(localNotificationService);
    getIt.registerSingleton<FileManagementService>(fileManagementService);
    getIt.registerSingleton<LocalStorageService>(localStorageService);
    final fileManagementRepository = FileManagementRepository(fileManagementService);
    final downloadModelService = DownloadModelService();
    final flutterGemmaService = FlutterGemmaService();

    getIt.registerSingleton<FileManagementRepository>(fileManagementRepository);
    getIt.registerSingleton<DownloadModelService>(downloadModelService);

    final themeBloc = ThemeBloc();
    final languageBloc = LanguageBloc();
    final bottomNavBarBloc = BottomNavBarBloc();
    final fileManagementBloc = FileManagementBloc(fileManagementRepository);
    final modelDownloaderBloc = ModelDownloaderBloc(downloadModelService);
    final permissionService = PermissionService();
    final permissionBloc = PermissionBloc(permissionService);

    getIt
      ..registerSingleton<ThemeBloc>(themeBloc)
      ..registerSingleton<LanguageBloc>(languageBloc)
      ..registerSingleton<BottomNavBarBloc>(bottomNavBarBloc)
      ..registerSingleton<FileManagementBloc>(fileManagementBloc)
      ..registerSingleton<ModelDownloaderBloc>(modelDownloaderBloc)
      ..registerSingleton<PermissionService>(permissionService)
      ..registerSingleton<PermissionBloc>(permissionBloc)
      ..registerSingleton<FlutterGemmaService>(flutterGemmaService);

    if (kDebugMode) {
      print('Service Locators registered!');
    }
  }
}
