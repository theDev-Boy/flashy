import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drive_provider.dart';
import '../file_browser/file_icon_widget.dart';
import 'storage_bar.dart';

class FlashyDiskCard extends ConsumerWidget {
  const FlashyDiskCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final driveState = ref.watch(driveProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!authState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final quota = driveState.quota;
    final usedBytes = int.tryParse(quota?.storageQuota?.usage ?? '0') ?? 0;
    final totalBytes = int.tryParse(quota?.storageQuota?.limit ?? '0') ?? (15 * 1024 * 1024 * 1024);
    final userEmail = authState.user?.email ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FileIconWidget.flashyDiskIcon(isDark: isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.flashyDisk,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () => _showMenu(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StorageBar(
            usedBytes: usedBytes,
            totalBytes: totalBytes,
            fillColor: isDark ? AppColors.flashyDiskBoltDark : AppColors.blue,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/flashy-disk'),
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text(AppStrings.openDisk, style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/flashy-disk'),
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text(AppStrings.uploadHere, style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Open Flashy Disk'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/flashy-disk');
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Upload Files Here'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/flashy-disk');
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Storage Details'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/settings/account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Now'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(driveProvider.notifier).fetchQuota();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(authProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
