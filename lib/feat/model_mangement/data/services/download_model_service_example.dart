import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

/// Example widget demonstrating how to integrate DownloadModelService with UI
/// This shows a complete implementation with progress tracking, status updates, and error handling
class DownloadModelServiceExample extends StatefulWidget {
  final AiModel model;

  const DownloadModelServiceExample({
    super.key,
    required this.model,
  });

  @override
  State<DownloadModelServiceExample> createState() => _DownloadModelServiceExampleState();
}

class _DownloadModelServiceExampleState extends State<DownloadModelServiceExample> {
  final DownloadModelService _downloadService = getIt.get<DownloadModelService>();

  // Download state
  bool _isDownloading = false;
  DownloadStatus _downloadStatus = DownloadStatus.notDownloaded;
  bool _hasError = false;
  String _errorMessage = '';

  // Progress state
  double _downloadProgress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String _status = 'Ready';

  // File info
  File? _downloadedFile;
  String _fileSize = '';

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  @override
  void dispose() {
    // Cancel any ongoing download when widget is disposed
    if (_isDownloading) {
      _downloadService.cancelDownload();
    }
    super.dispose();
  }

  /// Check if the model is already downloaded
  Future<void> _checkDownloadStatus() async {
    try {
      final downloadStatus = await _downloadService.getDownloadStatus(widget.model);
      setState(() {
        _downloadStatus = downloadStatus;
      });

      if (downloadStatus == DownloadStatus.complete) {
        final file = await _downloadService.getDownloadedModelFile(widget.model);
        if (file != null) {
          setState(() {
            _downloadedFile = file;
            _fileSize = _formatBytes(file.lengthSync());
            _status = 'Already Downloaded';
          });
        }
      } else if (downloadStatus == DownloadStatus.incomplete) {
        // Check if resume is supported
        final supportsResume = await _downloadService.supportsResumeDownload(widget.model.url);
        setState(() {
          _status =
              supportsResume ? 'Download Incomplete (Resume Available)' : 'Download Incomplete';
        });
      }
    } catch (e) {
      AppLogger.e('Error checking download status: $e');
    }
  }

  /// Start downloading the model
  Future<void> _startDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _hasError = false;
      _errorMessage = '';
      _downloadProgress = 0.0;
      _receivedBytes = 0;
      _totalBytes = 0;
      _status = 'Starting download...';
    });

    try {
      await _downloadService.downloadModel(
        model: widget.model,
        onProgress: (received, total, progress) {
          setState(() {
            _downloadProgress = progress;
            _receivedBytes = received;
            _totalBytes = total;
            _status = 'Downloading... ${(progress * 100).toStringAsFixed(1)}%';
          });
        },
        onComplete: (file) {
          setState(() {
            _isDownloading = false;
            _downloadStatus = DownloadStatus.complete;
            _downloadedFile = file;
            _fileSize = _formatBytes(file.lengthSync());
            _status = 'Download Complete!';
            _downloadProgress = 1.0;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.model.name} downloaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (error) {
          setState(() {
            _isDownloading = false;
            _hasError = true;
            _errorMessage = error;
            _status = 'Download Failed';
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _hasError = true;
        _errorMessage = e.toString();
        _status = 'Download Failed';
      });
    }
  }

  /// Cancel ongoing download
  Future<void> _cancelDownload() async {
    final cancelled = await _downloadService.cancelDownload();

    if (cancelled) {
      setState(() {
        _isDownloading = false;
        _status = 'Download Cancelled';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active download to cancel'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  /// Delete downloaded model
  Future<void> _deleteModel() async {
    try {
      final deleted = await _downloadService.deleteDownloadedModel(widget.model);
      if (deleted) {
        setState(() {
          _downloadStatus = DownloadStatus.notDownloaded;
          _downloadedFile = null;
          _fileSize = '';
          _status = 'Ready';
          _downloadProgress = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.model.name} deleted successfully'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Delete incomplete download
  Future<void> _deleteIncompleteDownload() async {
    try {
      final deleted = await _downloadService.deleteIncompleteDownload(widget.model);
      if (deleted) {
        setState(() {
          _downloadStatus = DownloadStatus.notDownloaded;
          _downloadedFile = null;
          _fileSize = '';
          _status = 'Ready';
          _downloadProgress = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incomplete download deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete incomplete download: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];

    // Calculate the appropriate suffix index
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    // Ensure we don't go out of bounds
    if (i >= suffixes.length) {
      i = suffixes.length - 1;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Card(
        margin: EdgeInsets.all(16.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Model Header
              Row(
                children: [
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.model.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.model.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Model Details
              Row(
                children: [
                  _buildInfoChip('Type', widget.model.modelType),
                  SizedBox(width: 8.w),
                  _buildInfoChip('Size', widget.model.fileName),
                  SizedBox(width: 8.w),
                  _buildInfoChip('Version', widget.model.modelVersion),
                ],
              ),

              SizedBox(height: 16.h),

              // Download Status
              _buildStatusSection(theme),

              SizedBox(height: 16.h),

              // Progress Bar (only show when downloading)
              if (_isDownloading) ...[
                _buildProgressSection(theme),
                SizedBox(height: 16.h),
              ],

              // Action Buttons
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  /// Build status section showing current download state
  Widget _buildStatusSection(ThemeData theme) {
    Color statusColor;
    IconData statusIcon;

    if (_isDownloading) {
      statusColor = Colors.blue;
      statusIcon = Icons.download;
    } else if (_downloadStatus == DownloadStatus.complete) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (_downloadStatus == DownloadStatus.incomplete) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else if (_hasError) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_downloadStatus == DownloadStatus.complete && _fileSize.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'File size: $_fileSize',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor.withOpacity(0.8),
                    ),
                  ),
                ],
                if (_hasError && _errorMessage.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    _errorMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress section with download details
  Widget _buildProgressSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Download Progress',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_downloadProgress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: _downloadProgress,
          backgroundColor: theme.primaryColor.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_formatBytes(_receivedBytes)} / ${_formatBytes(_totalBytes)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build action buttons based on current state
  Widget _buildActionButtons(ThemeData theme) {
    if (_isDownloading) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _downloadService.isDownloading ? _cancelDownload : null,
              icon: const Icon(Icons.stop),
              label: const Text('Cancel Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      );
    } else if (_downloadStatus == DownloadStatus.complete) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle model usage - navigate to chat or other functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Using ${widget.model.name}...'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Use Model'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _deleteModel,
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      );
    } else if (_downloadStatus == DownloadStatus.incomplete) {
      return FutureBuilder<bool>(
        future: _downloadService.supportsResumeDownload(widget.model.url),
        builder: (context, snapshot) {
          final supportsResume = snapshot.data ?? false;

          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: Icon(supportsResume ? Icons.play_arrow : Icons.refresh),
                  label: Text(supportsResume ? 'Resume Download' : 'Retry Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: supportsResume ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deleteIncompleteDownload,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Incomplete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _hasError ? _startDownload : _startDownload,
              icon: Icon(_hasError ? Icons.refresh : Icons.download),
              label: Text(_hasError ? 'Retry Download' : 'Download Model'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      );
    }
  }

  /// Build info chip for model details
  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

/// Example of how to use the widget in a list or grid
class DownloadModelServiceExampleList extends StatelessWidget {
  final List<AiModel> models;

  const DownloadModelServiceExampleList({
    super.key,
    required this.models,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: models.length,
      itemBuilder: (context, index) {
        return DownloadModelServiceExample(model: models[index]);
      },
    );
  }
}
