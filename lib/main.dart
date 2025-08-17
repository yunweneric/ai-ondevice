import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bootstrap(() => const Application(), env: AppEnv.dev);
}
