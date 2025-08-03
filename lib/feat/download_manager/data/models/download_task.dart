import 'dart:convert';
import 'package:equatable/equatable.dart';

enum DownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

class DownloadTask extends Equatable {
  final String id;
  final String url;
  final String fileName;
  final String filePath;
  final int totalBytes;
  final int downloadedBytes;
  final DownloadStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    required this.filePath,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.metadata,
  });

  DownloadTask copyWith({
    String? id,
    String? url,
    String? fileName,
    String? filePath,
    int? totalBytes,
    int? downloadedBytes,
    DownloadStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'url': url,
      'fileName': fileName,
      'filePath': filePath,
      'totalBytes': totalBytes,
      'downloadedBytes': downloadedBytes,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory DownloadTask.fromMap(Map<String, dynamic> map) {
    return DownloadTask(
      id: map['id'] as String,
      url: map['url'] as String,
      fileName: map['fileName'] as String,
      filePath: map['filePath'] as String,
      totalBytes: map['totalBytes'] as int,
      downloadedBytes: map['downloadedBytes'] as int,
      status: DownloadStatus.values[map['status'] as int],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      completedAt: map['completedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int) : null,
      errorMessage: map['errorMessage'] as String?,
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata'] as Map) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DownloadTask.fromJson(String source) => DownloadTask.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DownloadTask(id: $id, url: $url, fileName: $fileName, filePath: $filePath, totalBytes: $totalBytes, downloadedBytes: $downloadedBytes, status: $status, createdAt: $createdAt, completedAt: $completedAt, errorMessage: $errorMessage, metadata: $metadata)';
  }

  @override
  bool operator ==(covariant DownloadTask other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.url == url &&
        other.fileName == fileName &&
        other.filePath == filePath &&
        other.totalBytes == totalBytes &&
        other.downloadedBytes == downloadedBytes &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.errorMessage == errorMessage &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        url.hashCode ^
        fileName.hashCode ^
        filePath.hashCode ^
        totalBytes.hashCode ^
        downloadedBytes.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        completedAt.hashCode ^
        errorMessage.hashCode ^
        metadata.hashCode;
  }

  @override
  List<Object?> get props => [
        id,
        url,
        fileName,
        filePath,
        totalBytes,
        downloadedBytes,
        status,
        createdAt,
        completedAt,
        errorMessage,
        metadata,
      ];

  /// Get download progress as a percentage (0.0 to 1.0)
  double get progress {
    if (totalBytes == 0) return 0.0;
    return downloadedBytes / totalBytes;
  }

  /// Get progress as a percentage string
  String get progressText {
    return '${(progress * 100).toInt()}%';
  }

  /// Check if download is active (downloading or paused)
  bool get isActive => status == DownloadStatus.downloading || status == DownloadStatus.paused;

  /// Check if download is completed
  bool get isCompleted => status == DownloadStatus.completed;

  /// Check if download failed
  bool get isFailed => status == DownloadStatus.failed;

  /// Check if download is cancelled
  bool get isCancelled => status == DownloadStatus.cancelled;
}
