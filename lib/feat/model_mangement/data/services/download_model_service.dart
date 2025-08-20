import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';

/// Callback function type for download progress
typedef DownloadProgressCallback = void Function(
  int received,
  int total,
  double progress,
);

/// Callback function type for download completion
typedef DownloadCompleteCallback = void Function(File file);

/// Callback function type for download error
typedef DownloadErrorCallback = void Function(String error);

/// Download status enum
enum DownloadStatus {
  notDownloaded,
  incomplete,
  complete,
  downloading,
  paused,
}

/// Service for downloading AI models with progress tracking
class DownloadModelService {
  final Dio _dio;
  final FileManagementService _fileManagementService;

  // Cancel token for current download
  CancelToken? _currentCancelToken;

  DownloadModelService({
    Dio? dio,
    FileManagementService? fileManagementService,
  })  : _dio = dio ?? getIt.get<Dio>(),
        _fileManagementService = fileManagementService ?? getIt.get<FileManagementService>();

  /// Download a model with progress tracking
  Future<File?> downloadModel({
    required AiModel model,
    required DownloadProgressCallback onProgress,
    required DownloadCompleteCallback onComplete,
    required DownloadErrorCallback onError,
    bool overwrite = false,
    bool resumeDownload = true,
  }) async {
    try {
      AppLogger.i('Starting download for model: ${model.name}');

      // Get actual file size from server
      final actualFileSize = await _getFileSizeFromServer(model.url);
      if (actualFileSize <= 0) {
        AppLogger.i('Could not determine file size from server, using estimated size');
      }

      // Check available storage space
      final hasEnoughSpace = await _checkStorageSpace(model, actualFileSize);
      if (!hasEnoughSpace) {
        final error = 'Insufficient storage space for model: ${model.name}';
        AppLogger.e(error);
        onError(error);
        return null;
      }

      // Get download directory
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) {
        const error = 'Failed to get download directory';
        AppLogger.e(error);
        onError(error);
        return null;
      }

      // Generate filename
      final filePath = '${downloadDir.path}/${model.fileName}';

      // Check if file already exists and handle resume
      final existingFile = File(filePath);
      int resumeFromByte = 0;

      if (existingFile.existsSync()) {
        if (!overwrite) {
          // Check if it's a complete download
          final isComplete = await _isDownloadComplete(model, existingFile);
          if (isComplete) {
            AppLogger.i('Model already exists and is complete: $filePath');
            onComplete(existingFile);
            return existingFile;
          }
        }

        // Check if we can resume the download
        if (resumeDownload) {
          final partialFile = await _getPartialDownloadFile(model);
          if (partialFile != null) {
            // Check if server supports resume downloads
            final supportsResume = await _supportsResumeDownload(model.url);
            if (supportsResume) {
              final partialFileSize = await partialFile.length();

              // Validate that the partial file size is reasonable
              if (partialFileSize > 0) {
                // Try to get the expected total file size from the server
                try {
                  final expectedTotalSize = await _getFileSizeFromServer(model.url);
                  if (expectedTotalSize > 0 && partialFileSize >= expectedTotalSize) {
                    AppLogger.i(
                        'Partial file is already complete (${_formatBytes(partialFileSize)} >= ${_formatBytes(expectedTotalSize)})');
                    await partialFile.delete();
                    resumeFromByte = 0;
                  } else {
                    resumeFromByte = partialFileSize;
                    AppLogger.i('Resuming download from byte: $resumeFromByte');

                    // Log the partial file details
                    AppLogger.i('Partial file size: ${_formatBytes(partialFileSize)}');
                    AppLogger.i('Partial file path: ${partialFile.path}');
                    if (expectedTotalSize > 0) {
                      AppLogger.i('Expected total size: ${_formatBytes(expectedTotalSize)}');
                    }
                  }
                } catch (e) {
                  AppLogger.i('Could not verify total file size, proceeding with resume: $e');
                  resumeFromByte = partialFileSize;
                  AppLogger.i('Resuming download from byte: $resumeFromByte');
                  AppLogger.i('Partial file size: ${_formatBytes(partialFileSize)}');
                  AppLogger.i('Partial file path: ${partialFile.path}');
                }
              } else {
                AppLogger.i('Partial file is empty, starting fresh download');
                await partialFile.delete();
                resumeFromByte = 0;
              }
            } else {
              AppLogger.i('Server does not support resume downloads, starting fresh');
              // Delete partial file if server doesn't support resume
              await partialFile.delete();
              resumeFromByte = 0;
            }
          }
        }
      }

      // Create directory if it doesn't exist
      if (!downloadDir.existsSync()) {
        await downloadDir.create(recursive: true);
      }

      // Create cancel token for this download
      _currentCancelToken = CancelToken();

      // Prepare headers for resume download
      final headers = <String, dynamic>{
        'User-Agent': 'OfflineAI/1.0',
      };

      // Add range header for resume download
      if (resumeFromByte > 0) {
        headers['Range'] = 'bytes=$resumeFromByte-';
        AppLogger.i('Resuming download with Range header: bytes=$resumeFromByte-');
      }

      // Log download details before starting
      AppLogger.i('Starting download for model: ${model.name}');
      AppLogger.i('Download URL: ${model.url}');
      AppLogger.i('Target file: $filePath');
      AppLogger.i('Resume from byte: $resumeFromByte');
      AppLogger.i('Request headers: $headers');

      // Log existing file info for resume downloads
      if (resumeFromByte > 0) {
        final existingFile = File(filePath);
        if (await existingFile.exists()) {
          final existingSize = await existingFile.length();
          AppLogger.i('Existing file size: ${_formatBytes(existingSize)}');
          if (existingSize != resumeFromByte) {
            AppLogger.i(
                'Warning: Existing file size ($existingSize) differs from resume point ($resumeFromByte)');
          }
        }
      }

      // For resume downloads, we need to handle the file differently
      Response response;
      if (resumeFromByte > 0) {
        // Resume download: download to a temporary file first, then append
        final tempFilePath = '${filePath}_temp';
        AppLogger.i('Resume download: Using temporary file: $tempFilePath');

        response = await _dio.download(
          model.url,
          tempFilePath,
          cancelToken: _currentCancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              // Adjust progress calculation for resume downloads
              final adjustedReceived = received + resumeFromByte;
              final adjustedTotal = total + resumeFromByte;
              final progress = adjustedReceived / adjustedTotal;

              AppLogger.i(
                  'Download progress: ${(progress * 100).toStringAsFixed(1)}% (resumed from ${_formatBytes(resumeFromByte)})');
              onProgress(adjustedReceived, adjustedTotal, progress);
            }
          },
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            maxRedirects: 5,
            headers: headers,
          ),
        );

        // After successful download, append the temp file to the original file
        if (response.statusCode == 206) {
          final tempFile = File(tempFilePath);
          final originalFile = File(filePath);

          if (await tempFile.exists()) {
            final tempFileSize = await tempFile.length();
            AppLogger.i('Appending ${_formatBytes(tempFileSize)} bytes to existing file');

            try {
              // Read the temp file and append to original
              final tempBytes = await tempFile.readAsBytes();
              final raf = originalFile.openSync(mode: FileMode.append);
              raf.writeFromSync(tempBytes);
              raf.closeSync();

              // Verify the append was successful
              final newFileSize = await originalFile.length();
              final expectedSize = resumeFromByte + tempBytes.length;

              if (newFileSize != expectedSize) {
                throw Exception(
                    'File append verification failed: expected $expectedSize, got $newFileSize');
              }

              // Clean up temp file
              await tempFile.delete();

              AppLogger.i(
                  'Resume download completed: Appended ${_formatBytes(tempBytes.length)} bytes to existing file');
              AppLogger.i('Final file size: ${_formatBytes(newFileSize)}');
            } catch (e) {
              // Clean up temp file on error
              if (await tempFile.exists()) {
                await tempFile.delete();
              }
              throw Exception('Failed to append resume download: $e');
            }
          } else {
            throw Exception('Temporary file not found after resume download');
          }
        }
      } else {
        // Full download: use normal Dio download
        response = await _dio.download(
          model.url,
          filePath,
          cancelToken: _currentCancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              AppLogger.i('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
              onProgress(received, total, progress);
            }
          },
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            maxRedirects: 5,
            headers: headers,
          ),
        );
      }

      // Log response details
      AppLogger.i('Download response received - Status: ${response.statusCode}');
      AppLogger.i('Response headers: ${response.headers}');

      // Validate Content-Range header for partial downloads
      if (response.statusCode == 206) {
        final contentRange = response.headers.value('content-range');
        if (contentRange != null) {
          AppLogger.i('Content-Range header: $contentRange');
          // Parse Content-Range: bytes start-end/total
          // Example: bytes 1000-1999/5000
          final rangeMatch = RegExp(r'bytes (\d+)-(\d+)/(\d+)').firstMatch(contentRange);
          if (rangeMatch != null) {
            final start = int.parse(rangeMatch.group(1)!);
            final end = int.parse(rangeMatch.group(2)!);
            final total = int.parse(rangeMatch.group(3)!);
            AppLogger.i('Partial content range: $start-$end of $total bytes');

            // Verify the range matches our resume point
            if (start != resumeFromByte) {
              AppLogger.i('Warning: Resume point mismatch. Expected: $resumeFromByte, got: $start');
            }
          }
        } else {
          AppLogger.i('Warning: 206 response received but no Content-Range header found');
        }
      }

      // Check for successful download status codes
      // 200 = OK (full download)
      // 206 = Partial Content (resume download)
      // 304 = Not Modified (cached version is still valid)
      if (response.statusCode == 200 || response.statusCode == 206 || response.statusCode == 304) {
        final downloadedFile = File(filePath);

        // Verify file was created and has content
        if (await downloadedFile.exists() && await downloadedFile.length() > 0) {
          final fileSize = await downloadedFile.length();
          final statusDescription = response.statusCode == 200
              ? 'Full download'
              : response.statusCode == 206
                  ? 'Resume download'
                  : 'Cached download (304)';

          AppLogger.i('Model downloaded successfully: ${downloadedFile.path}');
          AppLogger.i('File size: ${_formatBytes(fileSize)}');
          AppLogger.i('Download type: $statusDescription (HTTP ${response.statusCode})');

          // For resume downloads, verify the final file size makes sense
          if (response.statusCode == 206 && resumeFromByte > 0) {
            final expectedMinSize = resumeFromByte;
            if (fileSize < expectedMinSize) {
              AppLogger.e(
                  'Resume download error: Final file size ($fileSize) is less than resume point ($expectedMinSize)');
              throw Exception('Resume download failed: File size mismatch');
            }

            // Calculate how many bytes were actually downloaded in this session
            final bytesDownloaded = fileSize - expectedMinSize;
            AppLogger.i(
                'Resume download verified: Final size $fileSize >= resume point $expectedMinSize');
            AppLogger.i('Bytes downloaded in this session: ${_formatBytes(bytesDownloaded)}');
          }

          // Clean up cancel token on successful completion
          _currentCancelToken = null;

          onComplete(downloadedFile);
          return downloadedFile;
        } else {
          throw Exception('Downloaded file is empty or corrupted');
        }
      } else {
        // Log the response details for debugging
        AppLogger.e('Download failed with status: ${response.statusCode}');
        AppLogger.e('Response headers: ${response.headers}');

        // Provide more specific error messages based on status code
        String errorMessage;
        switch (response.statusCode) {
          case 401:
            errorMessage =
                'Download failed: Unauthorized (401) - Check if the model URL requires authentication';
            break;
          case 403:
            errorMessage = 'Download failed: Forbidden (403) - Access denied to the model file';
            break;
          case 404:
            errorMessage =
                'Download failed: Not Found (404) - Model file not found at the specified URL';
            break;
          case 500:
            errorMessage =
                'Download failed: Internal Server Error (500) - Server error, try again later';
            break;
          case 503:
            errorMessage =
                'Download failed: Service Unavailable (503) - Server temporarily unavailable';
            break;
          default:
            errorMessage = 'Download failed with HTTP status: ${response.statusCode}';
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Check if download was cancelled
      if (e.type == DioExceptionType.cancel) {
        AppLogger.i('Download was cancelled');
        onError('Download was cancelled');
      } else {
        final error = _handleDioError(e);
        AppLogger.e('Dio error during download: $error');
        onError(error);
      }

      // Clean up cancel token on error
      _currentCancelToken = null;
      return null;
    } catch (e) {
      final error = 'Unexpected error during download: $e';
      AppLogger.e(error);
      onError(error);

      // Clean up cancel token on error
      _currentCancelToken = null;
      return null;
    }
  }

  /// Cancel ongoing download
  Future<bool> cancelDownload() async {
    try {
      if (_currentCancelToken != null && !_currentCancelToken!.isCancelled) {
        _currentCancelToken!.cancel('Download cancelled by user');
        AppLogger.i('Download cancelled using CancelToken');

        // Clean up the cancel token
        _currentCancelToken = null;
        return true;
      } else {
        AppLogger.i('No active download to cancel');
        return false;
      }
    } catch (e) {
      AppLogger.e('Error cancelling download: $e');
      return false;
    }
  }

  /// Check if there's an active download
  bool get isDownloading => _currentCancelToken != null && !_currentCancelToken!.isCancelled;

  /// Check if server supports resume downloads
  Future<bool> supportsResumeDownload(String url) async {
    return await _supportsResumeDownload(url);
  }

  /// Check if model file exists and exactly matches remote file size (strict checking)
  Future<bool> checkModelExistenceStrict(AiModel model) async {
    try {
      AppLogger.i('Checking model existence with strict size matching: ${model.name}');

      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) return false;

      final filePath = '${downloadDir.path}/${model.fileName}';
      final file = File(filePath);

      // Check if local file exists
      if (!await file.exists()) {
        AppLogger.i('Local file does not exist: $filePath');
        return false;
      }

      // Get remote file size
      final remoteFileSize = await _getFileSizeFromServer(model.url);
      if (remoteFileSize <= 0) {
        AppLogger.i('Could not determine remote file size for strict checking');
        return false;
      }

      // Get local file size
      final localFileSize = await file.length();

      // Strict comparison - sizes must match exactly
      final isExactMatch = localFileSize == remoteFileSize;

      if (isExactMatch) {
        AppLogger.i(
            'Model ${model.name} exists and matches remote size exactly: ${_formatBytes(localFileSize)}');
      } else {
        AppLogger.i(
            'Model ${model.name} size mismatch. Local: ${_formatBytes(localFileSize)}, Remote: ${_formatBytes(remoteFileSize)}');
      }

      return isExactMatch;
    } catch (e) {
      AppLogger.e('Error checking model existence strictly: $e');
      return false;
    }
  }

  /// Dispose the service and cancel any ongoing downloads
  void dispose() {
    try {
      if (_currentCancelToken != null && !_currentCancelToken!.isCancelled) {
        _currentCancelToken!.cancel('Service disposed');
        AppLogger.i('Download cancelled due to service disposal');
      }
      _currentCancelToken = null;
    } catch (e) {
      AppLogger.e('Error during service disposal: $e');
    }
  }

  /// Check if model is already downloaded and complete
  Future<bool> isModelDownloaded(AiModel model) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) return false;

      final filePath = '${downloadDir.path}/${model.fileName}';
      final file = File(filePath);

      if (!await file.exists()) return false;

      final fileSize = await file.length();
      if (fileSize <= 0) return false;

      // Check if the file size matches the expected model size
      final expectedSize = await _getFileSizeFromServer(model.url);
      final actualSize = fileSize;

      if (expectedSize <= 0) {
        // Fallback to estimated size if server size unavailable
        final estimatedSize = _estimateModelSize(model);
        final tolerance = estimatedSize * 0.01;
        final isComplete = (actualSize - estimatedSize).abs() <= tolerance;

        if (!isComplete) {
          AppLogger.i(
              'Model ${model.name} exists but appears incomplete. Expected: ${_formatBytes(estimatedSize)}, Actual: ${_formatBytes(actualSize)}');
        }
        return isComplete;
      } else {
        // Use actual server file size
        final tolerance = expectedSize * 0.01;
        final isComplete = (actualSize - expectedSize).abs() <= tolerance;

        if (!isComplete) {
          AppLogger.i(
              'Model ${model.name} exists but appears incomplete. Expected: ${_formatBytes(expectedSize)}, Actual: ${_formatBytes(actualSize)}');
        }
        return isComplete;
      }
    } catch (e) {
      AppLogger.e('Error checking if model is downloaded: $e');
      return false;
    }
  }

  /// Get downloaded model file if it's complete
  Future<File?> getDownloadedModelFile(AiModel model) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) return null;

      final filePath = '${downloadDir.path}/${model.fileName}';
      final file = File(filePath);

      if (!await file.exists()) return null;

      final fileSize = await file.length();
      if (fileSize <= 0) return null;

      // Check if the file size matches the expected model size
      final expectedSize = await _getFileSizeFromServer(model.url);
      final actualSize = fileSize;

      if (expectedSize <= 0) {
        // Fallback to estimated size if server size unavailable
        final estimatedSize = _estimateModelSize(model);
        final tolerance = estimatedSize * 0.01;
        final isComplete = (actualSize - estimatedSize).abs() <= tolerance;

        if (isComplete) {
          return file;
        } else {
          AppLogger.i(
              'Model ${model.name} file exists but appears incomplete. Expected: ${_formatBytes(estimatedSize)}, Actual: ${_formatBytes(actualSize)}');
          return null;
        }
      } else {
        // Use actual server file size
        final tolerance = expectedSize * 0.01;
        final isComplete = (actualSize - expectedSize).abs() <= tolerance;

        if (isComplete) {
          return file;
        } else {
          AppLogger.i(
              'Model ${model.name} file exists but appears incomplete. Expected: ${_formatBytes(expectedSize)}, Actual: ${_formatBytes(actualSize)}');
          return null;
        }
      }
    } catch (e) {
      AppLogger.e('Error getting downloaded model file: $e');
      return null;
    }
  }

  /// Check if there's an incomplete download for the model
  Future<bool> hasIncompleteDownload(AiModel model) async {
    try {
      final incompleteFile = await _getIncompleteDownloadFile(model);
      return incompleteFile != null;
    } catch (e) {
      AppLogger.e('Error checking for incomplete download: $e');
      return false;
    }
  }

  /// Check if a file download is complete
  Future<bool> _isDownloadComplete(AiModel model, File file) async {
    try {
      final fileSize = await file.length();
      if (fileSize <= 0) return false;

      final expectedSize = await _getFileSizeFromServer(model.url);
      if (expectedSize <= 0) {
        // Fallback to estimated size
        final estimatedSize = _estimateModelSize(model);
        final tolerance = estimatedSize * 0.01;
        return (fileSize - estimatedSize).abs() <= tolerance;
      } else {
        // Use actual server file size
        final tolerance = expectedSize * 0.01;
        return (fileSize - expectedSize).abs() <= tolerance;
      }
    } catch (e) {
      AppLogger.e('Error checking download completion: $e');
      return false;
    }
  }

  /// Get partial download file for resume functionality
  Future<File?> _getPartialDownloadFile(AiModel model) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) return null;

      final filePath = '${downloadDir.path}/${model.fileName}';
      final file = File(filePath);

      if (!await file.exists()) return null;

      final fileSize = await file.length();
      if (fileSize <= 0) return null;

      // Check if this is a partial download (not complete)
      final isComplete = await _isDownloadComplete(model, file);
      return isComplete ? null : file;
    } catch (e) {
      AppLogger.e('Error getting partial download file: $e');
      return null;
    }
  }

  /// Get download status for a model
  Future<DownloadStatus> getDownloadStatus(AiModel model) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) return DownloadStatus.notDownloaded;

      final filePath = '${downloadDir.path}/${model.fileName}';
      final file = File(filePath);

      if (!await file.exists()) return DownloadStatus.notDownloaded;

      final fileSize = await file.length();
      if (fileSize <= 0) return DownloadStatus.notDownloaded;

      // Check if the file size matches the expected model size
      final expectedSize = await _getFileSizeFromServer(model.url);
      final actualSize = fileSize;

      if (expectedSize <= 0) {
        // Fallback to estimated size if server size unavailable
        final estimatedSize = _estimateModelSize(model);
        final tolerance = estimatedSize * 0.01;
        final isComplete = (actualSize - estimatedSize).abs() <= tolerance;

        return isComplete ? DownloadStatus.complete : DownloadStatus.incomplete;
      } else {
        // Use actual server file size
        final tolerance = expectedSize * 0.01;
        final isComplete = (actualSize - expectedSize).abs() <= tolerance;

        return isComplete ? DownloadStatus.complete : DownloadStatus.incomplete;
      }
    } catch (e) {
      AppLogger.e('Error getting download status: $e');
      return DownloadStatus.notDownloaded;
    }
  }

  /// Delete downloaded model (complete or incomplete)
  Future<bool> deleteDownloadedModel(AiModel model) async {
    try {
      // First try to get the complete downloaded file

      final file = await getDownloadedModelFile(model);
      if (file != null) {
        await file.delete();
        AppLogger.i('Complete model deleted: ${file.path}');
        return true;
      }

      // If no complete file, check for incomplete downloads
      final incompleteFile = await _getIncompleteDownloadFile(model);
      if (incompleteFile != null) {
        await incompleteFile.delete();
        AppLogger.i('Incomplete model deleted: ${incompleteFile.path}');
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.e('Error deleting model: $e');
      return false;
    }
  }

  /// Delete incomplete download specifically
  Future<bool> deleteIncompleteDownload(AiModel model) async {
    try {
      final incompleteFile = await _getIncompleteDownloadFile(model);
      if (incompleteFile != null) {
        await incompleteFile.delete();
        AppLogger.i('Incomplete download deleted: ${incompleteFile.path}');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('Error deleting incomplete download: $e');
      return false;
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    return await UtilHelper.getDownloadDirectory();
  }

  /// Get incomplete download file if it exists
  Future<File?> _getIncompleteDownloadFile(AiModel model) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) return null;

      final filePath = '${downloadDir.path}/${model.fileName}';
      final file = File(filePath);

      if (!await file.exists()) return null;

      final fileSize = await file.length();
      if (fileSize <= 0) return null;

      // Check if this is an incomplete download
      final expectedSize = await _getFileSizeFromServer(model.url);
      final actualSize = fileSize;

      if (expectedSize <= 0) {
        // Fallback to estimated size if server size unavailable
        final estimatedSize = _estimateModelSize(model);
        final tolerance = estimatedSize * 0.01;
        final isComplete = (actualSize - estimatedSize).abs() <= tolerance;

        // Return file if it's incomplete
        return isComplete ? null : file;
      } else {
        // Use actual server file size
        final tolerance = expectedSize * 0.01;
        final isComplete = (actualSize - expectedSize).abs() <= tolerance;

        // Return file if it's incomplete
        return isComplete ? null : file;
      }
    } catch (e) {
      AppLogger.e('Error getting incomplete download file: $e');
      return null;
    }
  }

  /// Check if there's enough storage space for the model
  Future<bool> _checkStorageSpace(AiModel model, int actualFileSize) async {
    try {
      final freeSpace = await _fileManagementService.getFreeSpace();

      // Use actual file size if available, otherwise estimate
      final modelSize = actualFileSize > 0 ? actualFileSize : _estimateModelSize(model);

      // Require at least 2x the model size for safety
      final requiredSpace = modelSize * 2;

      AppLogger.i(
          'Storage check: Free space: ${_formatBytes(freeSpace)}, Required: ${_formatBytes(requiredSpace)}');

      return freeSpace >= requiredSpace;
    } catch (e) {
      AppLogger.e('Error checking storage space: $e');
      // If we can't check, assume there's enough space
      return true;
    }
  }

  /// Get the actual file size from the server using Dio
  Future<int> _getFileSizeFromServer(String url) async {
    try {
      AppLogger.i('Fetching file size from server: $url');

      final response = await _dio.head(
        url,
        options: Options(
          headers: {
            'User-Agent': 'OfflineAI/1.0',
          },
        ),
      );

      final contentLength = response.headers.value('content-length');
      if (contentLength != null && contentLength.isNotEmpty) {
        final size = int.tryParse(contentLength);
        if (size != null && size > 0) {
          AppLogger.i('File size from server: ${_formatBytes(size)}');
          return size;
        }
      }

      // Fallback: try to get size from content-range header
      final contentRange = response.headers.value('content-range');
      if (contentRange != null && contentRange.isNotEmpty) {
        final match = RegExp(r'bytes \d+-\d+/(\d+)').firstMatch(contentRange);
        if (match != null) {
          final size = int.tryParse(match.group(1)!);
          if (size != null && size > 0) {
            AppLogger.i('File size from content-range: ${_formatBytes(size)}');
            return size;
          }
        }
      }

      AppLogger.i('Could not determine file size from server headers');
      return -1;
    } on DioException catch (e) {
      AppLogger.e('Error fetching file size: ${_handleDioError(e)}');
      return -1;
    } catch (e) {
      AppLogger.e('Unexpected error fetching file size: $e');
      return -1;
    }
  }

  /// Check if server supports resume downloads
  Future<bool> _supportsResumeDownload(String url) async {
    try {
      AppLogger.i('Checking if server supports resume downloads: $url');

      final response = await _dio.head(
        url,
        options: Options(
          headers: {
            'User-Agent': 'OfflineAI/1.0',
            'Range': 'bytes=0-1023', // Request first 1KB
          },
        ),
      );

      // Check if server responds with 206 Partial Content
      if (response.statusCode == 206) {
        AppLogger.i('Server supports resume downloads (206 Partial Content)');
        return true;
      }

      // Check for Accept-Ranges header
      final acceptRanges = response.headers.value('accept-ranges');
      if (acceptRanges != null && acceptRanges.toLowerCase() == 'bytes') {
        AppLogger.i('Server supports resume downloads (Accept-Ranges: bytes)');
        return true;
      }

      AppLogger.i('Server does not support resume downloads');
      return false;
    } on DioException catch (e) {
      AppLogger.e('Error checking resume support: ${_handleDioError(e)}');
      return false;
    } catch (e) {
      AppLogger.e('Unexpected error checking resume support: $e');
      return false;
    }
  }

  /// Estimate model size based on model information (fallback method)
  int _estimateModelSize(AiModel model) {
    try {
      // Try to parse model size from model field (filename might contain size info)
      if (model.fileName.isNotEmpty) {
        final sizeStr = model.fileName.toLowerCase();
        if (sizeStr.contains('gb')) {
          final value = double.tryParse(sizeStr.replaceAll('gb', '').trim()) ?? 1.0;
          return (value * 1024 * 1024 * 1024).round();
        } else if (sizeStr.contains('mb')) {
          final value = double.tryParse(sizeStr.replaceAll('mb', '').trim()) ?? 100.0;
          return (value * 1024 * 1024).round();
        } else if (sizeStr.contains('kb')) {
          final value = double.tryParse(sizeStr.replaceAll('kb', '').trim()) ?? 100000.0;
          return (value * 1024).round();
        }
      }

      // Default fallback sizes based on model type
      switch (model.modelType.toLowerCase()) {
        case 'llm':
        case 'large':
          return 2 * 1024 * 1024 * 1024; // 2GB
        case 'medium':
          return 1 * 1024 * 1024 * 1024; // 1GB
        case 'small':
          return 500 * 1024 * 1024; // 500MB
        default:
          return 1 * 1024 * 1024 * 1024; // 1GB default
      }
    } catch (e) {
      AppLogger.e('Error estimating model size: $e');
      return 1 * 1024 * 1024 * 1024; // 1GB fallback
    }
  }

  /// Handle Dio-specific errors
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Download may be too slow.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Download was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.unknown:
      default:
        return 'Unknown error occurred: ${e.message}';
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

  Future<void> clearDownloadDirectory() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir != null) {
        await downloadDir.delete(recursive: true);
        AppLogger.i('Download directory cleared successfully');
      }
    } catch (e) {
      AppLogger.e('Error clearing download directory: $e');
    }
  }
}
