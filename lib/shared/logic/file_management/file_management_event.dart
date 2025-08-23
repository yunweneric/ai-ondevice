part of 'file_management_bloc.dart';

sealed class FileManagementEvent extends Equatable {}

class LoadStorageInfoEvent extends FileManagementEvent {
  @override
  List<Object?> get props => [];
}

class ClearAppCacheEvent extends FileManagementEvent {
  @override
  List<Object?> get props => [];
}

class ClearAppDocumentsEvent extends FileManagementEvent {
  @override
  List<Object?> get props => [];
}

class ClearAllAppDataEvent extends FileManagementEvent {
  @override
  List<Object?> get props => [];
} 