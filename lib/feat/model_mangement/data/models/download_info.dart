import 'package:equatable/equatable.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';

/// Information about a model download
class DownloadInfo extends Equatable {
  final AiModel model;
  final DownloadStatus status;
  final bool isDownloading;
  final double progress;
  final int receivedBytes;
  final int totalBytes;
  final DateTime startTime;
  final DateTime lastUpdateTime;
  final DateTime? completedTime;
  final String? errorMessage;

  const DownloadInfo({
    required this.model,
    required this.status,
    required this.isDownloading,
    required this.progress,
    required this.receivedBytes,
    required this.totalBytes,
    required this.startTime,
    required this.lastUpdateTime,
    this.completedTime,
    this.errorMessage,
  });

  DownloadInfo copyWith({
    AiModel? model,
    DownloadStatus? status,
    bool? isDownloading,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    DateTime? startTime,
    DateTime? lastUpdateTime,
    DateTime? completedTime,
    String? errorMessage,
  }) {
    return DownloadInfo(
      model: model ?? this.model,
      status: status ?? this.status,
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      startTime: startTime ?? this.startTime,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      completedTime: completedTime ?? this.completedTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': {
        'id': model.id,
        'name': model.name,
        'description': model.description,
        'fileName': model.fileName,
        'url': model.url,
        'path': model.path,
        'modelType': model.modelType,
        'modelVersion': model.modelVersion,
        'modelAuthor': model.modelAuthor,
        'modelAuthorImage': model.modelAuthorImage,
        'modelAuthorDescription': model.modelAuthorDescription,
        'modelAuthorWebsite': model.modelAuthorWebsite,
        'size': model.size,
      },
      'status': status.name,
      'isDownloading': isDownloading,
      'progress': progress,
      'receivedBytes': receivedBytes,
      'totalBytes': totalBytes,
      'startTime': startTime.toIso8601String(),
      'lastUpdateTime': lastUpdateTime.toIso8601String(),
      'completedTime': completedTime?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  factory DownloadInfo.fromJson(Map<String, dynamic> json) {
    final modelJson = json['model'] as Map<String, dynamic>;
    final model = AiModel(
      id: modelJson['id'] as String? ?? '',
      name: modelJson['name'] as String,
      description: modelJson['description'] as String,
      fileName: modelJson['fileName'] as String,
      url: modelJson['url'] as String,
      path: modelJson['path'] as String? ?? '',
      modelType: modelJson['modelType'] as String,
      modelVersion: modelJson['modelVersion'] as String,
      modelAuthor: modelJson['modelAuthor'] as String? ?? '',
      modelAuthorImage: modelJson['modelAuthorImage'] as String? ?? '',
      modelAuthorDescription: modelJson['modelAuthorDescription'] as String? ?? '',
      modelAuthorWebsite: modelJson['modelAuthorWebsite'] as String? ?? '',
      size: modelJson['size'] as String,
    );

    return DownloadInfo(
      model: model,
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.notDownloaded,
      ),
      isDownloading: json['isDownloading'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      receivedBytes: json['receivedBytes'] as int? ?? 0,
      totalBytes: json['totalBytes'] as int? ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      lastUpdateTime: DateTime.parse(json['lastUpdateTime'] as String),
      completedTime:
          json['completedTime'] != null ? DateTime.parse(json['completedTime'] as String) : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  List<Object?> get props => [
        model,
        status,
        isDownloading,
        progress,
        receivedBytes,
        totalBytes,
        startTime,
        lastUpdateTime,
        completedTime,
        errorMessage,
      ];
}
