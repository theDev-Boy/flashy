import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final String? lottieAsset;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.lottieAsset,
  });

  factory EmptyStateWidget.emptyFolder() {
    return const EmptyStateWidget(
      icon: Icons.folder_open,
      title: 'Nothing here',
      subtitle: 'This folder is empty',
      lottieAsset: 'lib/assets/lottie/empty_folder.json',
    );
  }

  factory EmptyStateWidget.emptyDisk() {
    return const EmptyStateWidget(
      icon: Icons.cloud_outlined,
      title: 'Flashy Disk is empty',
      subtitle: 'Tap + to upload your first file',
      lottieAsset: 'lib/assets/lottie/empty_disk.json',
    );
  }

  factory EmptyStateWidget.noResults() {
    return const EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No files found',
      subtitle: 'Try a different search term',
      lottieAsset: 'lib/assets/lottie/no_results.json',
    );
  }

  factory EmptyStateWidget.noTransfers() {
    return const EmptyStateWidget(
      icon: Icons.swap_vert,
      title: 'No transfers yet',
      subtitle: 'Files you upload to Flashy Disk appear here',
      lottieAsset: 'lib/assets/lottie/no_transfers.json',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLottie = lottieAsset != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLottie)
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  lottieAsset!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildIconFallback(theme),
                ),
              )
            else
              _buildIconFallback(theme),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconFallback(ThemeData theme) {
    return Icon(
      icon,
      size: 72,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
    );
  }
}
