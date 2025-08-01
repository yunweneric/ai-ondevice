part of 'permission_bloc.dart';

class PermissionState extends Equatable {
  final AppPermissionStatus status;
  final bool storagePermission;
  final bool notificationPermission;
  final String? errorMessage;

  const PermissionState({
    this.status = AppPermissionStatus.initial,
    this.storagePermission = false,
    this.notificationPermission = false,
    this.errorMessage,
  });

  PermissionState copyWith({
    AppPermissionStatus? status,
    bool? storagePermission,
    bool? notificationPermission,
    String? errorMessage,
  }) {
    return PermissionState(
      status: status ?? this.status,
      storagePermission: storagePermission ?? this.storagePermission,
      notificationPermission: notificationPermission ?? this.notificationPermission,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get allPermissionsGranted => storagePermission;

  @override
  List<Object?> get props => [
        status,
        storagePermission,
        notificationPermission,
        errorMessage,
      ];
}
