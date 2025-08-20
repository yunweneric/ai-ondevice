// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class AiModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String fileName;
  final String url;
  final String path;
  final String modelType;
  final String modelVersion;
  final String modelAuthor;
  final String modelAuthorImage;
  final String modelAuthorDescription;
  final String modelAuthorWebsite;
  final String size;
  const AiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.fileName,
    required this.url,
    required this.path,
    required this.modelType,
    required this.modelVersion,
    required this.modelAuthor,
    required this.modelAuthorImage,
    required this.modelAuthorDescription,
    required this.modelAuthorWebsite,
    required this.size,
  });

  AiModel copyWith({
    String? id,
    String? name,
    String? description,
    String? fileName,
    String? url,
    String? path,
    String? modelType,
    String? modelVersion,
    String? modelAuthor,
    String? modelAuthorImage,
    String? modelAuthorDescription,
    String? modelAuthorWebsite,
    String? size,
  }) {
    return AiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      url: url ?? this.url,
      path: path ?? this.path,
      modelType: modelType ?? this.modelType,
      modelVersion: modelVersion ?? this.modelVersion,
      modelAuthor: modelAuthor ?? this.modelAuthor,
      modelAuthorImage: modelAuthorImage ?? this.modelAuthorImage,
      modelAuthorDescription: modelAuthorDescription ?? this.modelAuthorDescription,
      modelAuthorWebsite: modelAuthorWebsite ?? this.modelAuthorWebsite,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'fileName': fileName,
      'url': url,
      'path': path,
      'modelType': modelType,
      'modelVersion': modelVersion,
      'modelAuthor': modelAuthor,
      'modelAuthorImage': modelAuthorImage,
      'modelAuthorDescription': modelAuthorDescription,
      'modelAuthorWebsite': modelAuthorWebsite,
      'size': size,
    };
  }

  factory AiModel.fromMap(Map<String, dynamic> map) {
    return AiModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      fileName: map['fileName'] as String,
      url: map['url'] as String,
      path: map['path'] as String,
      modelType: map['modelType'] as String,
      modelVersion: map['modelVersion'] as String,
      modelAuthor: map['modelAuthor'] as String,
      modelAuthorImage: map['modelAuthorImage'] as String,
      modelAuthorDescription: map['modelAuthorDescription'] as String,
      modelAuthorWebsite: map['modelAuthorWebsite'] as String,
      size: map['size'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AiModel.fromJson(String source) =>
      AiModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AiModel(id: $id, name: $name, description: $description, fileName: $fileName, url: $url, path: $path, modelType: $modelType, modelVersion: $modelVersion, modelAuthor: $modelAuthor, modelAuthorImage: $modelAuthorImage, modelAuthorDescription: $modelAuthorDescription, modelAuthorWebsite: $modelAuthorWebsite, size: $size)';
  }

  @override
  bool operator ==(covariant AiModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.fileName == fileName &&
        other.url == url &&
        other.path == path &&
        other.modelType == modelType &&
        other.modelVersion == modelVersion &&
        other.modelAuthor == modelAuthor &&
        other.modelAuthorImage == modelAuthorImage &&
        other.modelAuthorDescription == modelAuthorDescription &&
        other.modelAuthorWebsite == modelAuthorWebsite &&
        other.size == size;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        fileName.hashCode ^
        url.hashCode ^
        path.hashCode ^
        modelType.hashCode ^
        modelVersion.hashCode ^
        modelAuthor.hashCode ^
        modelAuthorImage.hashCode ^
        modelAuthorDescription.hashCode ^
        modelAuthorWebsite.hashCode ^
        size.hashCode;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        fileName,
        url,
        path,
        modelType,
        modelVersion,
        modelAuthor,
        modelAuthorImage,
        modelAuthorDescription,
        modelAuthorWebsite,
        size
      ];
}

class AllAiModels {
  static List<AiModel> models = [
    const AiModel(
      id: '1',
      name: 'Gemma 270m',
      description: 'A powerful general-purpose AI model for text and reasoning tasks.',
      fileName: 'gemma3-270m-it-q8.task',
      size: '0.3GB',
      url:
          'https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma3-270m-it-q8.task',
      path: '/models/gemini-pro.tflite',
      modelType: 'Text',
      modelVersion: '1.0.0',
      modelAuthor: 'Google DeepMind',
      modelAuthorImage: 'assets/images/google.png',
      modelAuthorDescription: 'Google DeepMind is a leading AI research lab.',
      modelAuthorWebsite: 'https://deepmind.google/',
    ),
    const AiModel(
      id: '2',
      name: 'Gemma 2n',
      description: 'An AI model specialized in user experience and interface suggestions.',
      fileName: 'gemma3-270m-it-q8.task',
      size: '0.3GB',
      url: 'https://ash-speed.hetzner.com/1GB.bin',
      path: '/models/ux-pilot.tflite',
      modelType: 'Text',
      modelVersion: '2.1.0',
      modelAuthor: 'UXAI Labs',
      modelAuthorImage: 'assets/images/uxai.png',
      modelAuthorDescription: 'UXAI Labs focuses on AI for user experience.',
      modelAuthorWebsite: 'https://uxai.example.com/',
    ),
    const AiModel(
      id: '3',
      name: 'Vision Lite',
      description: 'A lightweight vision model for image recognition and classification.',
      fileName: 'gemma3-270m-it-q8.task',
      size: '0.3GB',
      url: 'https://ash-speed.hetzner.com/1GB.bin',
      path: '/models/vision-lite.tflite',
      modelType: 'Vision',
      modelVersion: '0.9.5',
      modelAuthor: 'OpenVision',
      modelAuthorImage: 'assets/images/openvision.png',
      modelAuthorDescription: 'OpenVision develops open-source vision models.',
      modelAuthorWebsite: 'https://openvision.ai/',
    ),
  ];
}
