import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize flutter_downloader
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true, // Allow HTTP connections
  );
  
  bootstrap(() => const Application(), env: AppEnv.dev);
}
