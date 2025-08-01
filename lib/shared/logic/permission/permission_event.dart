part of 'permission_bloc.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object?> get props => [];
}

class CheckPermissions extends PermissionEvent {
  const CheckPermissions();
}

class RequestStoragePermission extends PermissionEvent {
  const RequestStoragePermission();
}

class RequestNotificationPermission extends PermissionEvent {
  const RequestNotificationPermission();
}

class RequestAllPermissions extends PermissionEvent {
  const RequestAllPermissions();
}

class OpenAppSettings extends PermissionEvent {
  const OpenAppSettings();
}
