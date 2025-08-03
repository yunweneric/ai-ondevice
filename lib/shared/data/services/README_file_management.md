# File Management Feature

This feature provides comprehensive file management capabilities for the offline AI app, including device space monitoring and file clearing operations.

## Components

### 1. FileManagementService
Located at `lib/shared/data/services/file_management_service.dart`

**Key Features:**
- Get total device space
- Get free device space  
- Get used device space
- Get app data size (cache + documents)
- Clear app cache
- Clear app documents
- Clear all app data
- Format bytes to human-readable strings

**Usage:**
```dart
final service = FileManagementService();

// Get storage information
final totalSpace = await service.getTotalSpace();
final freeSpace = await service.getFreeSpace();
final usedSpace = await service.getUsedSpace();
final appDataSize = await service.getAppDataSize();

// Clear operations
final cacheCleared = await service.clearAppCache();
final documentsCleared = await service.clearAppDocuments();
final allCleared = await service.clearAllAppData();

// Format bytes
final formatted = UtilHelper.formatBytes(1048576); // "1.00 MB"
```

### 2. FileManagementRepository
Located at `lib/shared/data/repositories/file_management_repository.dart`

**Purpose:** Abstracts the service layer and provides a clean interface for the BLoC.

**Usage:**
```dart
final repository = getIt<FileManagementRepository>();
final totalSpace = await repository.getTotalSpace();
final formatted = UtilHelper.formatBytes(1024);
```

### 3. FileManagementBloc
Located at `lib/shared/logic/file_management/file_management_bloc.dart`

**Events:**
- `LoadStorageInfoEvent` - Load device storage information
- `ClearAppCacheEvent` - Clear app cache
- `ClearAppDocumentsEvent` - Clear app documents  
- `ClearAllAppDataEvent` - Clear all app data

**States:**
- `FileManagementInitial` - Initial state
- `FileManagementLoading` - Loading storage info
- `FileManagementClearing` - Clearing data
- `FileManagementLoaded` - Storage info loaded with data
- `FileManagementError` - Error state with message

**Usage:**
```dart
final bloc = getIt<FileManagementBloc>();

// Load storage info
bloc.add(LoadStorageInfoEvent());

// Clear operations
bloc.add(ClearAppCacheEvent());
bloc.add(ClearAppDocumentsEvent());
bloc.add(ClearAllAppDataEvent());
```

### 4. StorageInfoWidget
Located at `lib/shared/presentation/widgets/storage_info_widget.dart`

**Purpose:** A complete UI widget that displays storage information and provides clearing options.

**Features:**
- Shows total, free, used, and app data space
- Provides buttons to clear cache, documents, or all data
- Confirmation dialogs for destructive operations
- Loading states and error handling
- Uses theme colors and follows app design patterns

**Usage:**
```dart
// In any screen
const StorageInfoWidget()
```

## Integration

The file management feature is automatically registered in the service locator (`lib/shared/core/service_locators.dart`):

```dart
// Services
final fileManagementService = FileManagementService();
getIt.registerSingleton<FileManagementService>(fileManagementService);

// Repository
final fileManagementRepository = FileManagementRepository(fileManagementService);
getIt.registerSingleton<FileManagementRepository>(fileManagementRepository);

// BLoC
final fileManagementBloc = FileManagementBloc(fileManagementRepository);
getIt.registerSingleton<FileManagementBloc>(fileManagementBloc);
```

## Dependencies

The feature uses these existing dependencies:
- `disk_space_plus` - For device space information
- `path_provider` - For app directories
- `get_it` - For dependency injection
- `flutter_bloc` - For state management

## Testing

Tests are available at `test/file_management_test.dart` covering:
- Service functionality
- Repository abstraction
- Byte formatting
- Storage information retrieval

## Best Practices

1. **Always use the BLoC for UI operations** - Don't call the service directly from UI
2. **Handle loading states** - Show appropriate loading indicators
3. **Confirm destructive operations** - Always show confirmation dialogs for clearing operations
4. **Use theme colors** - Follow the app's design system
5. **Log operations** - All operations are logged using AppLogger
6. **Error handling** - Proper error states and user feedback

## Example Integration in Settings

```dart
// In settings screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Other settings sections...
          const StorageInfoWidget(),
        ],
      ),
    );
  }
} 