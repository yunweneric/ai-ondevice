import 'dart:convert';
import 'package:equatable/equatable.dart';

class DownloadProgress extends Equatable {
  final String taskId;
  final int downloadedBytes;
  final int totalBytes;
  final double progress;
  final double speed; // bytes per second
  final Duration estimatedTimeRemaining;
  final DateTime timestamp;

  const DownloadProgress({
    required this.taskId,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.progress,
    required this.speed,
    required this.estimatedTimeRemaining,
    required this.timestamp,
  });

  DownloadProgress copyWith({
    String? taskId,
    int? downloadedBytes,
    int? totalBytes,
    double? progress,
    double? speed,
    Duration? estimatedTimeRemaining,
    DateTime? timestamp,
  }) {
    return DownloadProgress(
      taskId: taskId ?? this.taskId,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      estimatedTimeRemaining: estimatedTimeRemaining ?? this.estimatedTimeRemaining,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskId': taskId,
      'downloadedBytes': downloadedBytes,
      'totalBytes': totalBytes,
      'progress': progress,
      'speed': speed,
      'estimatedTimeRemaining': estimatedTimeRemaining.inMilliseconds,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory DownloadProgress.fromMap(Map<String, dynamic> map) {
    return DownloadProgress(
      taskId: map['taskId'] as String,
      downloadedBytes: map['downloadedBytes'] as int,
      totalBytes: map['totalBytes'] as int,
      progress: map['progress'] as double,
      speed: map['speed'] as double,
      estimatedTimeRemaining: Duration(milliseconds: map['estimatedTimeRemaining'] as int),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory DownloadProgress.fromJson(String source) => DownloadProgress.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DownloadProgress(taskId: $taskId, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, progress: $progress, speed: $speed, estimatedTimeRemaining: $estimatedTimeRemaining, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant DownloadProgress other) {
    if (identical(this, other)) return true;

    return other.taskId == taskId &&
        other.downloadedBytes == downloadedBytes &&
        other.totalBytes == totalBytes &&
        other.progress == progress &&
        other.speed == speed &&
        other.estimatedTimeRemaining == estimatedTimeRemaining &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return taskId.hashCode ^
        downloadedBytes.hashCode ^
        totalBytes.hashCode ^
        progress.hashCode ^
        speed.hashCode ^
        estimatedTimeRemaining.hashCode ^
        timestamp.hashCode;
  }

  @override
  List<Object?> get props => [
        taskId,
        downloadedBytes,
        totalBytes,
        progress,
        speed,
        estimatedTimeRemaining,
        timestamp,
      ];

  /// Get progress as a percentage string
  String get progressText {
    return '${(progress * 100).toInt()}%';
  }

  /// Get speed in MB/s
  String get speedText {
    if (speed <= 0) return '0 MB/s';
    final speedMBps = (speed / 1024 / 1024).toStringAsFixed(2);
    return '$speedMBps MB/s';
  }

  /// Get formatted time remaining
  String get timeRemainingText {
    final duration = estimatedTimeRemaining;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get formatted file size
  String get downloadedSizeText {
    return _formatBytes(downloadedBytes);
  }

  /// Get formatted total size
  String get totalSizeText {
    return _formatBytes(totalBytes);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
    }
  }
}
