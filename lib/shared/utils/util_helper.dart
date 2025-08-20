// import 'dart:io';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class UtilHelper {
  /// Get download directory path
  static Future<Directory?> getDownloadDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/models');

      if (!downloadDir.existsSync()) {
        await downloadDir.create(recursive: true);
      }

      return downloadDir;
    } catch (e) {
      AppLogger.e('Error getting download directory: $e');
      return null;
    }
  }

  static hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static double? parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    return double.tryParse("$value");
  }

  static String dummyUrl(i) {
    return "https://avatar.iran.liara.run/public/$i";
  }

  static Future<File> loadPdfFromAssets(String assetPath, String filename) async {
    final byteData = await rootBundle.load(assetPath);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');

    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return file;
  }

  static int getWeekOfYear(DateTime date) {
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    int daysSinceFirstDay = date.difference(firstDayOfYear).inDays;

    return (daysSinceFirstDay ~/ 7) + 1;
  }

  static DateTime getFirstDateOfWeek(DateTime date) {
    int daysSinceMonday = (date.weekday - DateTime.monday) % 7;
    return date.subtract(Duration(days: daysSinceMonday));
  }

  static bool isSameDay(DateTime submissionDate, DateTime dueDate) {
    return submissionDate.year == dueDate.year &&
        submissionDate.month == dueDate.month &&
        submissionDate.day == dueDate.day;
  }

  static bool isValidSubmissionDate(DateTime createdAt, DateTime submissionDate) {
    return createdAt.isBefore(submissionDate) || isSameDay(createdAt, submissionDate);
  }

  static Future<double> getFileSizeInKB(File file) async {
    try {
      final bytes = await file.length();
      return bytes / 1024;
    } catch (e) {
      AppLogger.e(e);
      throw Exception('Could not get file size');
    }
  }

  /// Format bytes to human readable string (KB, MB, GB)
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Format bytes to human readable string (KB, MB, GB) without space
  static String formatBytesCompact(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  /// Format bytes to GB (legacy function for backward compatibility)
  static String formatGB(int bytes) {
    return formatBytes(bytes);
  }

  /// Format bytes to MB (legacy function for backward compatibility)
  static String formatFile(int bytes) {
    return formatBytes(bytes);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  static
      // Helper functions
      String generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  static String? currentRoute() {
    final currentRoute = getIt.get<GoRouter>().state.path;
    return currentRoute;
  }

  static GoRoute buildAnimatedRoute({
    required String path,
    required Function(BuildContext context, GoRouterState state) builder,
  }) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: builder(context, state),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    );
  }

  static String activeRoute = getIt.get<GoRouter>().state.path ?? "----";

  static String getFirstLetter(String str) {
    return str.substring(0, 1);
  }

  static String formatName(String str) {
    if (str.isEmpty) return 'Friend';
    return "${str.substring(0, 1).toUpperCase()}${str.substring(1)}";
  }

  static String capitalize(String string) {
    if (string.isEmpty) {
      return string;
    }
    return string
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
        .join(' ');
  }

  static bool validateEmail(String value) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(p);
    return (!regex.hasMatch(value)) ? false : true;
  }

  static bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return !uri!.hasAbsolutePath ? true : false;
  }

  static bool isURL(String str) {
    final pattern = RegExp(
        r'^(http(s)?:\/\/)?(www\.)?[a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$');
    return pattern.hasMatch(str);
  }

  static String formatDate(DateTime date, {String? format, required BuildContext context}) {
    String formattedDate =
        DateFormat(format ?? 'dd MMMM yyyy', context.locale.languageCode).format(date);
    return formattedDate;
  }

  static String formatCurrency(double? amount, {String? currency, required BuildContext context}) {
    if (amount == null) return currency == null ? '0' : "0$currency";
    final formatter = NumberFormat("#,##0", context.locale.languageCode);
    try {
      final formatted = formatter.format(amount);
      return currency == null ? formatted : " $currency$formatted";
    } catch (e) {
      return "----";
    }
  }

  static Future<void> openUrl(String? link) async {
    if (link == null) {
      throw Exception('Could not launch $link');
    }

    final uri = Uri.parse(link);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  static String generateUniqueId({String prefix = ' "FWH-', int length = 7}) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    Random random = Random();
    final items = List.generate(length - 4, (index) => chars[random.nextInt(chars.length)]);
    return prefix + items.join();
  }

  static Future<bool> isFileDownloaded(String filename) async {
    String dirPath = (await getApplicationSupportDirectory()).path;
    String filePath = "$dirPath/$filename";
    return File(filePath).existsSync();
  }

  static Future<String> getStoragePath(String subFolder) async {
    Directory baseDir;

    final newSubFolder = UtilHelper.capitalize(subFolder);

    final docsDir = await getApplicationDocumentsDirectory();
    baseDir = Directory('${docsDir.path}/$newSubFolder');

    // Create directory if it doesn't exist
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    return baseDir.path;
  }

  static String getMimeType(String ext) {
    final lowerExt = ext.toLowerCase().replaceAll('.', '');

    switch (lowerExt) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/pdf'; // More general fallback
    }
  }
}
