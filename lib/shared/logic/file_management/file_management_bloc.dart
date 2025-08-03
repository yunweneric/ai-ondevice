import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/shared/data/repositories/file_management_repository.dart';

part 'file_management_event.dart';
part 'file_management_state.dart';

class FileManagementBloc extends Bloc<FileManagementEvent, FileManagementState> {
  final FileManagementRepository _repository;

  FileManagementBloc(this._repository)
      : super(const FileManagementInitial(
          totalSpace: 0,
          freeSpace: 0,
          usedSpace: 0,
          appDataSize: 0,
        )) {
    on<LoadStorageInfoEvent>(_onLoadStorageInfo);
    on<ClearAppCacheEvent>(_onClearAppCache);
    on<ClearAppDocumentsEvent>(_onClearAppDocuments);
    on<ClearAllAppDataEvent>(_onClearAllAppData);
  }

  Future<void> _onLoadStorageInfo(
    LoadStorageInfoEvent event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      // Get current state data or use zeros if initial
      final currentState = state;
      final currentTotalSpace = currentState.totalSpace;
      final currentFreeSpace = currentState.freeSpace;
      final currentUsedSpace = currentState.usedSpace;
      final currentAppDataSize = currentState.appDataSize;

      emit(FileManagementLoading(
        totalSpace: currentTotalSpace,
        freeSpace: currentFreeSpace,
        usedSpace: currentUsedSpace,
        appDataSize: currentAppDataSize,
      ));
      await Future.delayed(const Duration(seconds: 2));

      final totalSpace = await _repository.getTotalSpace();
      final freeSpace = await _repository.getFreeSpace();
      final usedSpace = await _repository.getUsedSpace();
      final appDataSize = await _repository.getAppDataSize();

      emit(FileManagementLoaded(
        totalSpace: totalSpace,
        freeSpace: freeSpace,
        usedSpace: usedSpace,
        appDataSize: appDataSize,
      ));
    } catch (e) {
      // Get current state data for error state
      final currentState = state;
      emit(FileManagementError(
        message: e.toString(),
        totalSpace: currentState.totalSpace,
        freeSpace: currentState.freeSpace,
        usedSpace: currentState.usedSpace,
        appDataSize: currentState.appDataSize,
      ));
    }
  }

  Future<void> _onClearAppCache(
    ClearAppCacheEvent event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      final currentState = state;
      emit(FileManagementClearing(
        totalSpace: currentState.totalSpace,
        freeSpace: currentState.freeSpace,
        usedSpace: currentState.usedSpace,
        appDataSize: currentState.appDataSize,
      ));

      final success = await _repository.clearAppCache();

      if (success) {
        // Reload storage info after clearing
        final totalSpace = await _repository.getTotalSpace();
        final freeSpace = await _repository.getFreeSpace();
        final usedSpace = await _repository.getUsedSpace();
        final appDataSize = await _repository.getAppDataSize();

        emit(FileManagementLoaded(
          totalSpace: totalSpace,
          freeSpace: freeSpace,
          usedSpace: usedSpace,
          appDataSize: appDataSize,
        ));
      } else {
        emit(FileManagementError(
          message: 'Failed to clear app cache',
          totalSpace: currentState.totalSpace,
          freeSpace: currentState.freeSpace,
          usedSpace: currentState.usedSpace,
          appDataSize: currentState.appDataSize,
        ));
      }
    } catch (e) {
      final currentState = state;
      emit(FileManagementError(
        message: e.toString(),
        totalSpace: currentState.totalSpace,
        freeSpace: currentState.freeSpace,
        usedSpace: currentState.usedSpace,
        appDataSize: currentState.appDataSize,
      ));
    }
  }

  Future<void> _onClearAppDocuments(
    ClearAppDocumentsEvent event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      final currentState = state;
      emit(FileManagementClearing(
        totalSpace: currentState.totalSpace,
        freeSpace: currentState.freeSpace,
        usedSpace: currentState.usedSpace,
        appDataSize: currentState.appDataSize,
      ));

      final success = await _repository.clearAppDocuments();

      if (success) {
        // Reload storage info after clearing
        final totalSpace = await _repository.getTotalSpace();
        final freeSpace = await _repository.getFreeSpace();
        final usedSpace = await _repository.getUsedSpace();
        final appDataSize = await _repository.getAppDataSize();

        emit(FileManagementLoaded(
          totalSpace: totalSpace,
          freeSpace: freeSpace,
          usedSpace: usedSpace,
          appDataSize: appDataSize,
        ));
      } else {
        emit(FileManagementError(
          message: 'Failed to clear app documents',
          totalSpace: currentState.totalSpace,
          freeSpace: currentState.freeSpace,
          usedSpace: currentState.usedSpace,
          appDataSize: currentState.appDataSize,
        ));
      }
    } catch (e) {
      final currentState = state;
      emit(FileManagementError(
        message: e.toString(),
        totalSpace: currentState.totalSpace,
        freeSpace: currentState.freeSpace,
        usedSpace: currentState.usedSpace,
        appDataSize: currentState.appDataSize,
      ));
    }
  }

  Future<void> _onClearAllAppData(
    ClearAllAppDataEvent event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      final currentState = state;
      emit(FileManagementClearing(
        totalSpace: currentState.totalSpace,
        freeSpace: currentState.freeSpace,
        usedSpace: currentState.usedSpace,
        appDataSize: currentState.appDataSize,
      ));

      final success = await _repository.clearAllAppData();

      if (success) {
        // Reload storage info after clearing
        final totalSpace = await _repository.getTotalSpace();
        final freeSpace = await _repository.getFreeSpace();
        final usedSpace = await _repository.getUsedSpace();
        final appDataSize = await _repository.getAppDataSize();

        emit(FileManagementLoaded(
          totalSpace: totalSpace,
          freeSpace: freeSpace,
          usedSpace: usedSpace,
          appDataSize: appDataSize,
        ));
      } else {
        emit(FileManagementError(
          message: 'Failed to clear all app data',
          totalSpace: currentState.totalSpace,
          freeSpace: currentState.freeSpace,
          usedSpace: currentState.usedSpace,
          appDataSize: currentState.appDataSize,
        ));
      }
    } catch (e) {
      final currentState = state;
      emit(FileManagementError(
        message: e.toString(),
        totalSpace: currentState.totalSpace,
        freeSpace: currentState.freeSpace,
        usedSpace: currentState.usedSpace,
        appDataSize: currentState.appDataSize,
      ));
    }
  }
}
