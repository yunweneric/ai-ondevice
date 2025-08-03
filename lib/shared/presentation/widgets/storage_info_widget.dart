import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ai/shared/shared.dart';

class StorageInfoWidget extends StatefulWidget {
  const StorageInfoWidget({super.key});

  @override
  State<StorageInfoWidget> createState() => _StorageInfoContentState();
}

class _StorageInfoContentState extends State<StorageInfoWidget> {
  @override
  void initState() {
    super.initState();
    // Load storage info when widget initializes
    getIt.get<FileManagementBloc>().add(LoadStorageInfoEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<FileManagementBloc, FileManagementState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Storage',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: state is FileManagementLoading
                        ? null
                        : () {
                            context.read<FileManagementBloc>().add(LoadStorageInfoEvent());
                          },
                    icon: state is FileManagementLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.refresh,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                    tooltip: 'Refresh storage info',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStorageContent(context, state, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStorageContent(BuildContext context, FileManagementState state, ThemeData theme) {
    if (state is FileManagementLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is FileManagementError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error: ${state.message}',
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is FileManagementLoaded) {
      final usedSpace = state.usedSpace;
      final totalSpace = state.totalSpace;
      final usagePercentage = totalSpace > 0 ? (usedSpace / totalSpace) : 0.0;
      final availablePercentage = 1.0 - usagePercentage;

      return Column(
        children: [
          // Main storage card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: usagePercentage.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Storage details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Used',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          UtilHelper.formatBytes(usedSpace),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          UtilHelper.formatBytes(totalSpace),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(usagePercentage * 100).toStringAsFixed(1)}% used',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          _buildActionButtons(context, state),
        ],
      );
    }

    // Initial state
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FileManagementState state) {
    final theme = Theme.of(context);

    if (state is FileManagementClearing) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Clearing data...'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildActionButton(
          context: context,
          title: 'Clear Cache',
          subtitle: 'Free up temporary files',
          icon: Icons.cleaning_services,
          onPressed: () => _showClearCacheDialog(context),
          theme: theme,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context: context,
          title: 'Clear Documents',
          subtitle: 'Remove saved files',
          icon: Icons.folder_delete,
          onPressed: () => _showClearDocumentsDialog(context),
          theme: theme,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context: context,
          title: 'Clear All Data',
          subtitle: 'Remove all app data',
          icon: Icons.delete_forever,
          onPressed: () => _showClearAllDataDialog(context),
          theme: theme,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDestructive ? theme.colorScheme.errorContainer : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? theme.colorScheme.error.withValues(alpha: 0.2)
              : theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? theme.colorScheme.error : theme.textTheme.titleSmall?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Cache'),
        content: const Text(
          'This will clear all cached files. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FileManagementBloc>().add(ClearAppCacheEvent());
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearDocumentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Documents'),
        content: const Text(
          'This will clear all app documents. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FileManagementBloc>().add(ClearAppDocumentsEvent());
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All App Data'),
        content: const Text(
          'This will clear all app data including cache and documents. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FileManagementBloc>().add(ClearAllAppDataEvent());
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
