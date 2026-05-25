import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../services/permission_service.dart';

class DeviceLocationsList extends StatelessWidget {
  const DeviceLocationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final locations = [
      _LocationItem(
        icon: Icons.phone_android,
        label: AppStrings.internalStorage,
        subtitle: 'Browse all files',
        path: '/storage/emulated/0/',
        color: AppColors.blue,
        bgColor: isDark ? AppColors.fileIconDocDark : AppColors.fileIconDocLight,
      ),
      _LocationItem(
        icon: Icons.download,
        label: AppStrings.downloads,
        subtitle: 'Recent files',
        path: '/storage/emulated/0/Download/',
        color: AppColors.green,
        bgColor: isDark ? AppColors.fileIconAudioDark : AppColors.fileIconAudioLight,
      ),
      _LocationItem(
        icon: Icons.photo_library,
        label: AppStrings.photosVideos,
        subtitle: 'Media files',
        path: '/storage/emulated/0/DCIM/',
        color: AppColors.purple,
        bgColor: isDark ? AppColors.fileIconImageDark : AppColors.fileIconImageLight,
      ),
      _LocationItem(
        icon: Icons.music_note,
        label: AppStrings.music,
        subtitle: 'Audio files',
        path: '/storage/emulated/0/Music/',
        color: AppColors.green,
        bgColor: isDark ? AppColors.fileIconAudioDark : AppColors.fileIconAudioLight,
      ),
      _LocationItem(
        icon: Icons.description,
        label: AppStrings.documents,
        subtitle: 'PDFs, docs, spreadsheets',
        path: '/storage/emulated/0/Documents/',
        color: AppColors.blue,
        bgColor: isDark ? AppColors.fileIconDocDark : AppColors.fileIconDocLight,
      ),
      _LocationItem(
        icon: Icons.android,
        label: AppStrings.apkFiles,
        subtitle: 'App packages',
        path: '/storage/emulated/0/',
        color: AppColors.green,
        bgColor: isDark ? AppColors.fileIconApkDark : AppColors.fileIconApkLight,
      ),
      _LocationItem(
        icon: Icons.storage,
        label: AppStrings.largeFiles,
        subtitle: 'Files over 50MB',
        path: '/storage/emulated/0/',
        color: AppColors.orange,
        bgColor: isDark ? AppColors.fileIconArchiveDark : AppColors.fileIconArchiveLight,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            AppStrings.deviceStorage,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ...locations.map((loc) => _LocationTile(item: loc)),
      ],
    );
  }
}

class _LocationItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String path;
  final Color color;
  final Color bgColor;

  _LocationItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.path,
    required this.color,
    required this.bgColor,
  });
}

class _LocationTile extends StatelessWidget {
  final _LocationItem item;

  const _LocationTile({required this.item});

  Future<void> _navigateWithPermission(BuildContext context) async {
    final permissionService = PermissionService();
    final hasPermission = await permissionService.requestStoragePermission();
    if (!context.mounted) return;
    if (hasPermission) {
      final encodedPath = Uri.encodeComponent(item.path);
      context.push('/local/$encodedPath');
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to browse files')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () => _navigateWithPermission(context),
    );
  }
}
