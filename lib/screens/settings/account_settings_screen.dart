import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drive_provider.dart';
import '../../widgets/home/storage_bar.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final driveState = ref.watch(driveProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = authState.user;

    final quota = driveState.quota;
    final usedBytes = int.tryParse(quota?.storageQuota?.usage ?? '0') ?? 0;
    final totalBytes = int.tryParse(quota?.storageQuota?.limit ?? '0') ?? (15 * 1024 * 1024 * 1024);

    return Scaffold(
      appBar: AppBar(title: const Text('Account'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Storage Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Google Drive Storage',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  StorageBar(
                    usedBytes: usedBytes,
                    totalBytes: totalBytes,
                    fillColor: isDark ? AppColors.flashyDiskBoltDark : AppColors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(usedBytes / (1024*1024*1024)).toStringAsFixed(1)} GB used of '
                    '${(totalBytes / (1024*1024*1024)).toStringAsFixed(0)} GB total',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Switch Account
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).switchAccount(),
              icon: const Icon(Icons.swap_horiz),
              label: Text(AppStrings.switchAccount),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sign Out
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSignOutDialog(context, ref),
              icon: const Icon(Icons.logout),
              label: Text(AppStrings.signOut),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.signOutConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.email ?? ''),
            const SizedBox(height: 8),
            const Text(AppStrings.signOutConfirmBody),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
            },
            child: Text(AppStrings.signOut,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
