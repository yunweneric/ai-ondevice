import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:offline_ai/shared/shared.dart';

part 'permission_event.dart';
part 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final PermissionService _permissionService;

  PermissionBloc(this._permissionService) : super(const PermissionState()) {
    on<CheckPermissions>(_onCheckPermissions);
    on<RequestStoragePermission>(_onRequestStoragePermission);
    on<RequestNotificationPermission>(_onRequestNotificationPermission);
    on<RequestAllPermissions>(_onRequestAllPermissions);
    on<OpenAppSettings>(_onOpenAppSettings);
  }

  Future<void> _onCheckPermissions(
    CheckPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AppPermissionStatus.loading));

      final storagePermission = await _permissionService.areDownloadPermissionsGranted();
      final notificationPermission = await _permissionService.isNotificationPermissionGranted();

      emit(state.copyWith(
        status: AppPermissionStatus.loaded,
        storagePermission: storagePermission,
        notificationPermission: notificationPermission,
      ));

      AppLogger.i('Permissions checked - Storage: $storagePermission, Notification: $notificationPermission');
    } catch (e) {
      AppLogger.e('Error checking permissions: $e');
      emit(state.copyWith(
        status: AppPermissionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRequestStoragePermission(
    RequestStoragePermission event,
    Emitter<PermissionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AppPermissionStatus.loading));

      final granted = await _permissionService.requestDownloadPermissions();

      emit(state.copyWith(
        status: AppPermissionStatus.loaded,
        storagePermission: granted,
      ));

      AppLogger.i('Storage permission request completed: $granted');
    } catch (e) {
      AppLogger.e('Error requesting storage permission: $e');
      emit(state.copyWith(
        status: AppPermissionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRequestNotificationPermission(
    RequestNotificationPermission event,
    Emitter<PermissionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AppPermissionStatus.loading));

      final granted = await _permissionService.requestNotificationPermission();

      emit(state.copyWith(
        status: AppPermissionStatus.loaded,
        // notificationPermission: granted,
        notificationPermission: true,
      ));

      AppLogger.i('Notification permission request completed: $granted');
    } catch (e) {
      AppLogger.e('Error requesting notification permission: $e');
      emit(state.copyWith(
        status: AppPermissionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRequestAllPermissions(
    RequestAllPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AppPermissionStatus.loading));

      final downloadGranted = await _permissionService.requestDownloadPermissions();
      final notificationGranted = await _permissionService.requestNotificationPermission();

      emit(state.copyWith(
        status: AppPermissionStatus.loaded,
        storagePermission: downloadGranted,
        notificationPermission: notificationGranted,
      ));

      AppLogger.i('All permissions requested - Download: $downloadGranted, Notification: $notificationGranted');
    } catch (e) {
      AppLogger.e('Error requesting all permissions: $e');
      emit(state.copyWith(
        status: AppPermissionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onOpenAppSettings(
    OpenAppSettings event,
    Emitter<PermissionState> emit,
  ) async {
    try {
      await _permissionService.openAppSettingsPage();
      AppLogger.i('App settings opened');
    } catch (e) {
      AppLogger.e('Error opening app settings: $e');
      emit(state.copyWith(
        status: AppPermissionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
