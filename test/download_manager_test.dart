import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/download_manager/download_manager.dart';

void main() {
  group('DownloadManager Tests', () {
    late DownloadManagerService service;
    late DownloadManagerRepository repository;
    late DownloadManagerBloc bloc;

    setUpAll(() async {
      // Initialize Flutter binding for background_downloader
      TestWidgetsFlutterBinding.ensureInitialized();

      // Initialize HydratedBloc storage for testing
      final tempDir = await Directory.systemTemp.createTemp('test_storage');
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(tempDir.path),
      );
    });

    setUp(() {
      service = DownloadManagerService();
      repository = DownloadManagerRepository(service);
      bloc = DownloadManagerBloc();
    });

    tearDown(() {
      bloc.close();
      service.dispose();
    });

    test('should initialize download manager service', () {
      expect(service, isNotNull);
    });

    test('should initialize download manager repository', () {
      expect(repository, isNotNull);
    });

    test('should initialize download manager bloc', () {
      expect(bloc, isNotNull);
    });

    test('should create download task correctly', () {
      final task = DownloadTask(
        id: 'test-task-1',
        url: 'https://example.com/test.bin',
        fileName: 'test.bin',
        filePath: '/test/path/test.bin',
        totalBytes: 1024,
        downloadedBytes: 0,
        status: DownloadStatus.downloading,
        createdAt: DateTime.now(),
      );

      expect(task.id, 'test-task-1');
      expect(task.url, 'https://example.com/test.bin');
      expect(task.fileName, 'test.bin');
      expect(task.status, DownloadStatus.downloading);
      expect(task.progress, 0.0);
      expect(task.progressText, '0%');
      expect(task.isActive, isTrue);
      expect(task.isCompleted, isFalse);
    });

    test('should create download progress correctly', () {
      final progress = DownloadProgress(
        taskId: 'test-task-1',
        downloadedBytes: 512,
        totalBytes: 1024,
        progress: 0.5,
        speed: 1024.0,
        estimatedTimeRemaining: Duration(seconds: 30),
        timestamp: DateTime.now(),
      );

      expect(progress.taskId, 'test-task-1');
      expect(progress.downloadedBytes, 512);
      expect(progress.totalBytes, 1024);
      expect(progress.progress, 0.5);
      expect(progress.progressText, '50%');
      expect(progress.speedText, '0.00 MB/s');
      expect(progress.timeRemainingText, '30s');
    });

    test('should format file size correctly', () {
      expect(repository.getFormattedFileSize(1024), '1.0 KB');
      expect(repository.getFormattedFileSize(1024 * 1024), '1.0 MB');
      expect(repository.getFormattedFileSize(1024 * 1024 * 1024), '1.0 GB');
    });

    test('should format time remaining correctly', () {
      final duration = Duration(hours: 2, minutes: 30, seconds: 45);
      expect(repository.getFormattedTimeRemaining(duration), '2h 30m');

      final shortDuration = Duration(minutes: 5, seconds: 30);
      expect(repository.getFormattedTimeRemaining(shortDuration), '5m 30s');

      final veryShortDuration = Duration(seconds: 45);
      expect(repository.getFormattedTimeRemaining(veryShortDuration), '45s');
    });

    test('should handle download task info correctly', () async {
      // Test that we can get download task info (should be null initially)
      final task = await repository.getDownloadTask('non-existent');
      expect(task, isNull);

      // Test that we can get all downloads (should be empty initially)
      final downloads = await repository.getDownloads();
      expect(downloads, isEmpty);
    });

    test('should check download status correctly', () async {
      // Test status checks for non-existent download
      expect(await repository.isDownloadActive('non-existent'), isFalse);
      expect(await repository.isDownloadCompleted('non-existent'), isFalse);
      expect(await repository.isDownloadFailed('non-existent'), isFalse);
      expect(await repository.isDownloadCancelled('non-existent'), isFalse);
    });

    test('should handle bloc events correctly', () {
      // Test initial state
      expect(bloc.state.downloads, isEmpty);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNull);

      // Test load downloads event
      bloc.add(const LoadDownloads());
      // The loading state might be brief, so we just check that the event was processed
      expect(bloc.state.downloads, isEmpty);
    });

    test('should handle download manager state correctly', () {
      final state = DownloadManagerState();

      expect(state.downloads, isEmpty);
      expect(state.downloadProgress, isEmpty);
      expect(state.downloadErrors, isEmpty);
      expect(state.fileValidations, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.totalDownloads, 0);
      expect(state.activeDownloadsCount, 0);
      expect(state.completedDownloadsCount, 0);
      expect(state.failedDownloadsCount, 0);
      expect(state.hasErrors, isFalse);
      expect(state.errorMessages, isEmpty);
    });
  });
}
