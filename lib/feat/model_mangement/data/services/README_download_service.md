# DownloadModelService

A comprehensive service for downloading AI models with progress tracking using Dio HTTP client.

## Features

- **Progress Tracking**: Real-time download progress with callbacks
- **Storage Management**: Automatic storage space checking
- **File Management**: Smart file naming and organization
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Resume Support**: Check if model is already downloaded
- **Cleanup**: Delete downloaded models when needed

## Usage

### Basic Download with Progress Tracking

```dart
import 'package:offline_ai/feat/model_mangement/model_management.dart';

// Get the service instance
final downloadService = getIt.get<DownloadModelService>();

// Start download with progress tracking
await downloadService.downloadModel(
  model: aiModel,
  onProgress: (received, total, progress, speed) {
    // Update UI with progress information
    print('Progress: ${(progress * 100).toStringAsFixed(1)}%');
    print('Speed: ${speed.toStringAsFixed(2)} MB/s');
  },
  onComplete: (file) {
    // Handle successful download
    print('Download completed: ${file.path}');
  },
  onError: (error) {
    // Handle download errors
    print('Download failed: $error');
  },
);
```

### Check Download Status

```dart
// Check if model is already downloaded
final isDownloaded = await downloadService.isModelDownloaded(aiModel);

if (isDownloaded) {
  // Get the downloaded file
  final file = await downloadService.getDownloadedModelFile(aiModel);
  if (file != null) {
    print('Model file: ${file.path}');
    print('File size: ${file.lengthSync()} bytes');
  }
}
```

### Delete Downloaded Model

```dart
// Delete a downloaded model
final deleted = await downloadService.deleteDownloadedModel(aiModel);
if (deleted) {
  print('Model deleted successfully');
}
```

### Cancel Ongoing Download

```dart
// Cancel any ongoing download
downloadService.cancelDownload();
```

## Callback Functions

### DownloadProgressCallback
```dart
typedef DownloadProgressCallback = void Function(
  int received,    // Bytes received so far
  int total,       // Total bytes to download
  double progress, // Progress as decimal (0.0 to 1.0)
  double speed,    // Download speed in MB/s
);
```

### DownloadCompleteCallback
```dart
typedef DownloadCompleteCallback = void Function(File file);
```

### DownloadErrorCallback
```dart
typedef DownloadErrorCallback = void Function(String error);
```

## Configuration Options

### Custom Filename
```dart
await downloadService.downloadModel(
  model: aiModel,
  customFileName: 'my_custom_model.bin',
  onProgress: onProgress,
  onComplete: onComplete,
  onError: onError,
);
```

### Overwrite Existing Files
```dart
await downloadService.downloadModel(
  model: aiModel,
  overwrite: true, // Will overwrite if file exists
  onProgress: onProgress,
  onComplete: onComplete,
  onError: onError,
);
```

## File Organization

Models are downloaded to the app's documents directory under a `models` subfolder:
- **iOS**: `Documents/models/`
- **Android**: `Documents/models/`

### File Naming Convention
Files are automatically named using the pattern:
```
{ModelName}_{Version}.{Extension}
```

Example: `Gemma_3n_1.0.0.bin`

## Storage Management

The service automatically:
- Checks available storage space before downloading
- Estimates model size based on model information
- Requires 2x the estimated size for safety
- Falls back to default sizes if estimation fails

### Size Estimation
- **LLM/Large models**: 2GB
- **Medium models**: 1GB  
- **Small models**: 500MB
- **Custom sizes**: Parsed from `modelSize` field

## Error Handling

The service handles various error scenarios:

- **Network errors**: Connection timeouts, network issues
- **Storage errors**: Insufficient space, permission issues
- **File errors**: Corrupted downloads, write failures
- **Server errors**: HTTP status codes, redirect issues

### Common Error Messages
- "Connection timeout. Please check your internet connection."
- "Insufficient storage space for model: {modelName}"
- "Download failed with status: {statusCode}"
- "Downloaded file is empty or corrupted"

## Integration with UI

### Progress Bar Example
```dart
class DownloadProgressWidget extends StatefulWidget {
  @override
  _DownloadProgressWidgetState createState() => _DownloadProgressWidgetState();
}

class _DownloadProgressWidgetState extends State<DownloadProgressWidget> {
  double _progress = 0.0;
  String _status = 'Ready';
  
  void _startDownload(AiModel model) {
    final downloadService = getIt.get<DownloadModelService>();
    
    downloadService.downloadModel(
      model: model,
      onProgress: (received, total, progress, speed) {
        setState(() {
          _progress = progress;
          _status = '${(progress * 100).toStringAsFixed(1)}% - ${speed.toStringAsFixed(2)} MB/s';
        });
      },
      onComplete: (file) {
        setState(() {
          _status = 'Download Complete!';
        });
      },
      onError: (error) {
        setState(() {
          _status = 'Error: $error';
        });
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: _progress),
        Text(_status),
        ElevatedButton(
          onPressed: () => _startDownload(model),
          child: Text('Download Model'),
        ),
      ],
    );
  }
}
```

## Dependencies

- **Dio**: HTTP client for downloads
- **path_provider**: Platform-specific directory access
- **getIt**: Dependency injection
- **AppLogger**: Logging service

## Service Registration

The service is automatically registered in `ServiceLocators` and can be accessed via:

```dart
final downloadService = getIt.get<DownloadModelService>();
```

## Best Practices

1. **Always handle errors**: Implement proper error handling in your UI
2. **Show progress**: Use the progress callback to update your UI
3. **Check storage**: Verify sufficient space before starting downloads
4. **Handle cancellation**: Provide users with the ability to cancel downloads
5. **Validate downloads**: Verify downloaded files are complete and valid
6. **Clean up**: Remove unused models to free up storage space

## Example Implementation

See `download_model_service_example.dart` for complete usage examples and integration patterns.
