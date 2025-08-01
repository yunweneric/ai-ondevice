# Permissions Implementation

This document describes the permission handling implementation for the Offline AI app.

## Overview

The app requires the following permissions to function properly:

1. **Storage Permission** - For downloading and saving files to the device
2. **Notification Permission** - For showing download progress and completion notifications

## Implementation Details

### Permission Service (`lib/shared/data/services/permission_service.dart`)

A comprehensive service that handles all permission-related functionality:

- **Storage Permissions**: Handles different storage permissions based on Android version
  - Android 13+ (API 33+): Uses specific media permissions (`READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`)
  - Older Android versions: Uses general storage permission (`READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`)
  - iOS: Uses storage permission

- **Notification Permissions**: Handles notification permission requests

### Permission BLoC (`lib/shared/logic/permission/permission_bloc.dart`)

Manages permission state using BLoC pattern:

- **Events**: `CheckPermissions`, `RequestStoragePermission`, `RequestNotificationPermission`, `RequestAllPermissions`, `OpenAppSettings`
- **States**: `PermissionState` with loading, loaded, and error states

### Permission Screen (`lib/shared/presentation/screens/permission_screen.dart`)

A user-friendly screen that:

- Shows permission status for storage and notifications
- Allows users to request permissions individually or all at once
- Provides option to open app settings if permissions are permanently denied
- Shows visual feedback for granted/denied permissions

## Platform Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)

Added the following permissions:

```xml
<!-- Storage permissions for downloading and saving files -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

<!-- Media permissions for Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Notification permission -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS (`ios/Podfile`)

Added permission macros:

```ruby
config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
  '$(inherited)',
  'PERMISSION_PHOTOS=1',
  'PERMISSION_VIDEOS=1',
  'PERMISSION_AUDIO=1',
  'PERMISSION_STORAGE=1',
  'PERMISSION_NOTIFICATIONS=1',
]
```

### iOS (`ios/Runner/Info.plist`)

Added permission descriptions:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photos to save downloaded images.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs access to save downloaded images to your photo library.</string>

<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs access to documents folder to save downloaded files.</string>
```

## Usage

### In Download Service

The download service automatically checks permissions before starting downloads:

```dart
// Check permissions
final permissionsGranted = await _permissionService.requestDownloadPermissions();
if (!permissionsGranted) {
  throw Exception('Download permissions not granted');
}
```

### In UI

Use the permission screen to request permissions:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const PermissionScreen()),
);
```

### Using Permission BLoC

```dart
BlocProvider(
  create: (context) => PermissionBloc(
    PermissionService(),
    getIt<LocalNotificationService>(),
  ),
  child: BlocBuilder<PermissionBloc, PermissionState>(
    builder: (context, state) {
      // Handle permission state
    },
  ),
);
```

## Testing

Run the permission service tests:

```bash
flutter test test/permission_service_test.dart
```

## Dependencies

The implementation uses the following packages:

- `permission_handler: ^12.0.1` - For cross-platform permission handling
- `flutter_bloc: ^9.1.1` - For state management
- `equatable: ^2.0.7` - For value equality

## Notes

- The implementation handles Android version differences automatically
- Permissions are requested gracefully with user-friendly messages
- The app provides fallback options when permissions are permanently denied
- All permission requests are logged for debugging purposes 