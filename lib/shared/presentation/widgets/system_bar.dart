import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemBar {
  static hideBottomBar() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  static hideAppBarIcon() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive,
        overlays: []);
  }

  static showBottomBar() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  static setNavBarColor(
      {Color? color, Brightness? brightness, required BuildContext context}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            color ?? Theme.of(context).bottomAppBarTheme.color,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
    );
    showBottomBar();
  }

  static setStatusBarIconColor(
      {Brightness? brightness, required BuildContext context}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: brightness ?? Theme.of(context).brightness,
      ),
    );
  }

  static setStatusBarColor(
      {Color? color, Brightness? brightness, required BuildContext context}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color ?? Theme.of(context).bottomAppBarTheme.color,
        statusBarBrightness: brightness ?? Theme.of(context).brightness,
        statusBarIconBrightness: brightness ?? Theme.of(context).brightness,
      ),
    );
    showBottomBar();
  }
}
