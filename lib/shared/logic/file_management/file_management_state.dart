part of 'file_management_bloc.dart';

sealed class FileManagementState extends Equatable {
  final int totalSpace;
  final int freeSpace;
  final int usedSpace;
  final int appDataSize;
  const FileManagementState({
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
    required this.appDataSize,
  });

  @override
  List<Object?> get props => [totalSpace, freeSpace, usedSpace, appDataSize];
}

class FileManagementInitial extends FileManagementState {
  const FileManagementInitial({
    required super.totalSpace,
    required super.freeSpace,
    required super.usedSpace,
    required super.appDataSize,
  });
}

class FileManagementLoading extends FileManagementState {
  const FileManagementLoading({
    required super.totalSpace,
    required super.freeSpace,
    required super.usedSpace,
    required super.appDataSize,
  });
}

class FileManagementClearing extends FileManagementState {
  const FileManagementClearing({
    required super.totalSpace,
    required super.freeSpace,
    required super.usedSpace,
    required super.appDataSize,
  });
}

class FileManagementLoaded extends FileManagementState {
  const FileManagementLoaded({
    required super.totalSpace,
    required super.freeSpace,
    required super.usedSpace,
    required super.appDataSize,
  });
}

class FileManagementError extends FileManagementState {
  final String message;

  const FileManagementError({
    required this.message,
    required super.totalSpace,
    required super.freeSpace,
    required super.usedSpace,
    required super.appDataSize,
  });

  @override
  List<Object?> get props => [message];
}
