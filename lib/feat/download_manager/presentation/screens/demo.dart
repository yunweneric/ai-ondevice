import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final DownloadManagerService _downloadService = getIt<DownloadManagerService>();
  final DownloadManagerBloc _downloadBloc = getIt<DownloadManagerBloc>();

  List<DownloadTask> _downloads = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDownloadManager();
  }

  Future<void> _initializeDownloadManager() async {
    try {
      AppLogger.i('Initializing download manager demo...');

      // Initialize the download service
      await _downloadService.initialize();

      // Load existing downloads
      _loadDownloads();

      // Listen to download updates
      _downloadBloc.stream.listen((state) {
        _loadDownloads();
      });

      setState(() {
        _isInitialized = true;
      });

      AppLogger.i('Download manager demo initialized successfully');
    } catch (e) {
      AppLogger.e('Error initializing download manager demo: $e');
    }
  }

  void _loadDownloads() {
    setState(() {
      _downloads = _downloadService.downloads;
    });
  }

  Future<void> _startTestDownload() async {
    try {
      AppLogger.i('Starting test download...');

      final task = await _downloadService.startDownload(
        url: 'https://httpbin.org/bytes/1024', // 1KB test file
        fileName: 'test_file_${DateTime.now().millisecondsSinceEpoch}.bin',
        metadata: {
          'type': 'test',
          'description': 'Small test file for demo',
        },
      );

      AppLogger.i('Test download started: ${task.fileName}');
      _loadDownloads();
    } catch (e) {
      AppLogger.e('Error starting test download: $e');
      _showErrorSnackBar('Failed to start download: $e');
    }
  }

  Future<void> _startLargeDownload() async {
    try {
      AppLogger.i('Starting large file download...');

      final task = await _downloadService.startDownload(
        url: 'https://ash-speed.hetzner.com/1GB.bin',
        fileName: 'large_file_${DateTime.now().millisecondsSinceEpoch}.bin',
        metadata: {
          'type': 'large',
          'description': 'Large file for testing resume functionality',
        },
      );

      AppLogger.i('Large download started: ${task.fileName}');
      _loadDownloads();
    } catch (e) {
      AppLogger.e('Error starting large download: $e');
      _showErrorSnackBar('Failed to start download: $e');
    }
  }

  Future<void> _pauseDownload(String id) async {
    try {
      await _downloadService.pauseDownload(id);
      AppLogger.i('Download paused: $id');
      _loadDownloads();
    } catch (e) {
      AppLogger.e('Error pausing download: $e');
      _showErrorSnackBar('Failed to pause download: $e');
    }
  }

  Future<void> _resumeDownload(String id) async {
    try {
      await _downloadService.resumeDownload(id);
      AppLogger.i('Download resumed: $id');
      _loadDownloads();
    } catch (e) {
      AppLogger.e('Error resuming download: $e');
      _showErrorSnackBar('Failed to resume download: $e');
    }
  }

  Future<void> _cancelDownload(String id) async {
    try {
      await _downloadService.cancelDownload(id);
      AppLogger.i('Download cancelled: $id');
      _loadDownloads();
    } catch (e) {
      AppLogger.e('Error cancelling download: $e');
      _showErrorSnackBar('Failed to cancel download: $e');
    }
  }

  Future<void> _deleteDownload(String id) async {
    try {
      await _downloadService.deleteDownload(id);
      AppLogger.i('Download deleted: $id');
      _loadDownloads();
    } catch (e) {
      AppLogger.e('Error deleting download: $e');
      _showErrorSnackBar('Failed to delete download: $e');
    }
  }

  Future<void> _clearAllDownloads() async {
    try {
      await _downloadService.clearAllDownloads();
      AppLogger.i('All downloads cleared');
      _loadDownloads();
    } catch (e) {
      AppLogger.e('Error clearing downloads: $e');
      _showErrorSnackBar('Failed to clear downloads: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.idle:
        return 'Idle';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.idle:
        return Colors.grey;
      case DownloadStatus.downloading:
        return Colors.blue;
      case DownloadStatus.paused:
        return Colors.orange;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.cancelled:
        return Colors.grey;
    }
  }

  Widget _buildDownloadCard(DownloadTask download) {
    final isActive = download.isActive;
    final isCompleted = download.isCompleted;
    final isFailed = download.isFailed;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.fileName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${_getStatusText(download.status)}',
                        style: TextStyle(
                          color: _getStatusColor(download.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (download.totalBytes > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_formatBytes(download.downloadedBytes)} / ${_formatBytes(download.totalBytes)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (download.metadata != null && download.metadata!['type'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      download.metadata!['type'].toString().toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            if (isActive && download.totalBytes > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: download.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(download.status)),
              ),
              const SizedBox(height: 8),
              Text(
                '${(download.progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (download.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: ${download.errorMessage}',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isActive && download.status == DownloadStatus.downloading)
                  ElevatedButton.icon(
                    onPressed: () => _pauseDownload(download.id),
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (download.status == DownloadStatus.paused)
                  ElevatedButton.icon(
                    onPressed: () => _resumeDownload(download.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (isActive)
                  ElevatedButton.icon(
                    onPressed: () => _cancelDownload(download.id),
                    icon: const Icon(Icons.stop),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (isCompleted || isFailed || download.status == DownloadStatus.cancelled)
                  ElevatedButton.icon(
                    onPressed: () => _deleteDownload(download.id),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  Map<String, dynamic> _getDownloadStats() {
    return _downloadService.getDownloadStats();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final stats = _getDownloadStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Manager Demo'),
        actions: [
          if (_downloads.isNotEmpty)
            IconButton(
              onPressed: _clearAllDownloads,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear All Downloads',
            ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Download Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total', stats['total'].toString(), Colors.blue),
                    _buildStatItem('Downloading', stats['downloading'].toString(), Colors.orange),
                    _buildStatItem('Completed', stats['completed'].toString(), Colors.green),
                    _buildStatItem('Failed', stats['failed'].toString(), Colors.red),
                  ],
                ),
              ],
            ),
          ),

          // Downloads List
          Expanded(
            child: _downloads.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No downloads yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start a download to see it here',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _downloads.length,
                    itemBuilder: (context, index) {
                      return _buildDownloadCard(_downloads[index]);
                    },
                  ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startTestDownload,
                    icon: const Icon(Icons.download),
                    label: const Text('Test Download (1KB)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startLargeDownload,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Large File (1GB)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
