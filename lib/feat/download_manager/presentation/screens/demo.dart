import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:offline_ai/shared/logging/logger.dart';
import 'dart:isolate';
import 'dart:ui';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  double _progress = 0.0;
  String _status = 'Ready';
  bool _isDownloading = false;
  List<String> _queuedTasks = [];
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _initDownloader();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  void _initDownloader() async {
    try {
      AppLogger.i('Initializing flutter_downloader...');

      // Register the port for communication between isolates
      IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
      _port.listen((dynamic data) {
        String id = data[0];
        DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
        int progress = data[2];

        AppLogger.i('Download update: Task $id, Status: $status, Progress: $progress%');

        setState(() {
          if (status == DownloadTaskStatus.complete) {
            _status = 'Download completed!';
            _isDownloading = false;
            _progress = 1.0;
          } else if (status == DownloadTaskStatus.failed) {
            _status = 'Download failed';
            _isDownloading = false;
          } else if (status == DownloadTaskStatus.running) {
            _progress = progress / 100.0;
            _status = 'Downloading... ${progress}%';
          } else if (status == DownloadTaskStatus.enqueued) {
            _status = 'Download queued';
          }
        });

        _checkQueuedTasks();
      });

      // Register the callback
      FlutterDownloader.registerCallback(downloadCallback);
      AppLogger.i('flutter_downloader initialized successfully');
      _checkQueuedTasks();
    } catch (e) {
      AppLogger.e('Error initializing flutter_downloader: $e');
    }
  }

  void _checkQueuedTasks() async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      final queued = tasks
              ?.where((task) =>
                  task.status == DownloadTaskStatus.enqueued ||
                  task.status == DownloadTaskStatus.running)
              .toList() ??
          [];

      setState(() {
        _queuedTasks =
            queued.map((task) => 'Task ${task.taskId} - ${_getStatusString(task.status)}').toList();
      });

      AppLogger.i('Queued tasks: ${queued.length}');
      for (final task in queued) {
        AppLogger.i('  - Task ${task.taskId}: ${_getStatusString(task.status)}');
      }
    } catch (e) {
      AppLogger.e('Error checking queued tasks: $e');
    }
  }

  String _getStatusString(DownloadTaskStatus status) {
    switch (status) {
      case DownloadTaskStatus.enqueued:
        return 'Queued';
      case DownloadTaskStatus.running:
        return 'Running';
      case DownloadTaskStatus.complete:
        return 'Complete';
      case DownloadTaskStatus.failed:
        return 'Failed';
      case DownloadTaskStatus.canceled:
        return 'Canceled';
      case DownloadTaskStatus.paused:
        return 'Paused';
      default:
        return 'Unknown';
    }
  }

  initDownload() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsPath = '${directory.path}';

      AppLogger.i('Starting download to: $downloadsPath');

      setState(() {
        _isDownloading = true;
        _progress = 0.0;
        _status = 'Starting...';
      });

      final taskId = await FlutterDownloader.enqueue(
        url: 'https://httpbin.org/bytes/1024', // 1KB test file
        savedDir: downloadsPath,
        fileName: 'test_file.bin',
        showNotification: true,
        openFileFromNotification: true,
      );

      AppLogger.i('Download task created with ID: $taskId');
    } catch (e) {
      AppLogger.e('Download error: $e');
      setState(() {
        _status = 'Error: $e';
        _isDownloading = false;
      });
    }
  }

  void _downloadLargeFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsPath = '${directory.path}';

      AppLogger.i('Starting large file download to: $downloadsPath');

      setState(() {
        _isDownloading = true;
        _progress = 0.0;
        _status = 'Starting large download...';
      });

      final taskId = await FlutterDownloader.enqueue(
        url: 'https://ash-speed.hetzner.com/1GB.bin',
        savedDir: downloadsPath,
        fileName: '1GB.bin',
        showNotification: true,
        openFileFromNotification: true,
      );

      AppLogger.i('Large download task created with ID: $taskId');
    } catch (e) {
      AppLogger.e('Large download error: $e');
      setState(() {
        _status = 'Error: $e';
        _isDownloading = false;
      });
    }
  }

  void _clearQueue() async {
    try {
      await FlutterDownloader.cancelAll();
      setState(() {
        _queuedTasks.clear();
        _isDownloading = false;
        _status = 'Queue cleared';
      });
      AppLogger.i('Download queue cleared');
    } catch (e) {
      AppLogger.e('Error clearing queue: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Demo (flutter_downloader)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                'Progress: ${(_progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (_queuedTasks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Queued Tasks:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ...(_queuedTasks.map((task) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(task, style: Theme.of(context).textTheme.bodyMedium),
                  ))),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _clearQueue,
                    child: const Text('Clear Queue'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _checkQueuedTasks,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ],
            const Spacer(),
            Center(
              child: Column(
                children: [
                  FloatingActionButton.extended(
                    onPressed: _isDownloading ? null : initDownload,
                    label: Text(_isDownloading ? 'Downloading...' : 'Test Download (1KB)'),
                    icon: Icon(_isDownloading ? Icons.downloading : Icons.download),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isDownloading ? null : () => _downloadLargeFile(),
                    child: const Text('Download Large File (1GB)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
