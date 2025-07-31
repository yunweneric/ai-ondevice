import 'package:offline_ai/shared/shared.dart';

class AppConfig {
  static int totalAiToken = const int.fromEnvironment('TOTAL_AI_TOKEN');
  static String appMode = const String.fromEnvironment('APP_MODE');
  static String appName = const String.fromEnvironment('APP_NAME');

  static const String logoUrl = "https://www.togeva.com/logos/JPG/white.jpg";

  AppConfig._();
  static final AppConfig instance = AppConfig._();
  late AppEnv env;

  factory AppConfig() {
    return instance;
  }

  Future<void> init({required AppEnv env}) async {
    instance.env = env;
  }

  void logVariables() {
    AppLogger.i({
      "env": env,
      "totalAiToken": totalAiToken,
      "appMode": appMode,
      "appName": appName,
    });
  }
}
