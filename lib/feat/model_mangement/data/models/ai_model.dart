// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class AiModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String image;
  final String model;
  final String url;
  final String path;
  final String modelType;
  final String modelSize;
  final String modelVersion;
  final String modelAuthor;
  final String modelAuthorImage;
  final String modelAuthorDescription;
  final String modelAuthorWebsite;
  AiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.model,
    required this.url,
    required this.path,
    required this.modelType,
    required this.modelSize,
    required this.modelVersion,
    required this.modelAuthor,
    required this.modelAuthorImage,
    required this.modelAuthorDescription,
    required this.modelAuthorWebsite,
  });

  AiModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? model,
    String? url,
    String? path,
    String? modelType,
    String? modelSize,
    String? modelVersion,
    String? modelAuthor,
    String? modelAuthorImage,
    String? modelAuthorDescription,
    String? modelAuthorWebsite,
  }) {
    return AiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      model: model ?? this.model,
      url: url ?? this.url,
      path: path ?? this.path,
      modelType: modelType ?? this.modelType,
      modelSize: modelSize ?? this.modelSize,
      modelVersion: modelVersion ?? this.modelVersion,
      modelAuthor: modelAuthor ?? this.modelAuthor,
      modelAuthorImage: modelAuthorImage ?? this.modelAuthorImage,
      modelAuthorDescription: modelAuthorDescription ?? this.modelAuthorDescription,
      modelAuthorWebsite: modelAuthorWebsite ?? this.modelAuthorWebsite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'model': model,
      'url': url,
      'path': path,
      'modelType': modelType,
      'modelSize': modelSize,
      'modelVersion': modelVersion,
      'modelAuthor': modelAuthor,
      'modelAuthorImage': modelAuthorImage,
      'modelAuthorDescription': modelAuthorDescription,
      'modelAuthorWebsite': modelAuthorWebsite,
    };
  }

  factory AiModel.fromMap(Map<String, dynamic> map) {
    return AiModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      model: map['model'] as String,
      url: map['url'] as String,
      path: map['path'] as String,
      modelType: map['modelType'] as String,
      modelSize: map['modelSize'] as String,
      modelVersion: map['modelVersion'] as String,
      modelAuthor: map['modelAuthor'] as String,
      modelAuthorImage: map['modelAuthorImage'] as String,
      modelAuthorDescription: map['modelAuthorDescription'] as String,
      modelAuthorWebsite: map['modelAuthorWebsite'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AiModel.fromJson(String source) => AiModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AiModel(id: $id, name: $name, description: $description, image: $image, model: $model, url: $url, path: $path, modelType: $modelType, modelSize: $modelSize, modelVersion: $modelVersion, modelAuthor: $modelAuthor, modelAuthorImage: $modelAuthorImage, modelAuthorDescription: $modelAuthorDescription, modelAuthorWebsite: $modelAuthorWebsite)';
  }

  @override
  bool operator ==(covariant AiModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.image == image &&
        other.model == model &&
        other.url == url &&
        other.path == path &&
        other.modelType == modelType &&
        other.modelSize == modelSize &&
        other.modelVersion == modelVersion &&
        other.modelAuthor == modelAuthor &&
        other.modelAuthorImage == modelAuthorImage &&
        other.modelAuthorDescription == modelAuthorDescription &&
        other.modelAuthorWebsite == modelAuthorWebsite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        image.hashCode ^
        model.hashCode ^
        url.hashCode ^
        path.hashCode ^
        modelType.hashCode ^
        modelSize.hashCode ^
        modelVersion.hashCode ^
        modelAuthor.hashCode ^
        modelAuthorImage.hashCode ^
        modelAuthorDescription.hashCode ^
        modelAuthorWebsite.hashCode;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        model,
        url,
        path,
        modelType,
        modelSize,
        modelVersion,
        modelAuthor,
        modelAuthorImage,
        modelAuthorDescription,
        modelAuthorWebsite
      ];
}
