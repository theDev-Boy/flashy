import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transfer_provider.dart';
import '../../models/transfer.dart';
import '../../utils/file_utils.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/file_browser/empty_state_widget.dart';

class TransfersScreen extends ConsumerWidget {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabTransfers),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(transferProvider.notifier).clearCompleted(),
            child: const Text('Clear all completed'),
          ),
        ],
      ),
      body: transferState.active.isEmpty &&
              transferState.queued.isEmpty &&
              transferState.completed.isEmpty &&
              transferState.failed.isEmpty
          ? EmptyStateWidget.noTransfers()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (transferState.active.isNotEmpty)
                  _buildSection(
                    context,
                    'ACTIVE',
                    transferState.active,
                    isActive: true,
                    ref: ref,
                  ),
                if (transferState.queued.isNotEmpty)
                  _buildSection(
                    context,
                    'QUEUED',
                    transferState.queued,
                    ref: ref,
                  ),
                if (transferState.completed.isNotEmpty)
                  _buildSection(
                    context,
                    'COMPLETED',
                    transferState.completed,
                    ref: ref,
                  ),
                if (transferState.failed.isNotEmpty)
                  _buildSection(
                    context,
                    'FAILED',
                    transferState.failed,
                    isFailed: true,
                    ref: ref,
                  ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Transfer> transfers, {
    bool isActive = false,
    bool isFailed = false,
    required WidgetRef ref,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...transfers.map((t) => _buildTransferItem(context, t, isActive, isFailed, ref)),
      ],
    );
  }

  Widget _buildTransferItem(
    BuildContext context,
    Transfer transfer,
    bool isActive,
    bool isFailed,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  transfer.direction == TransferDirection.upload
                      ? Icons.upload
                      : Icons.download,
                  size: 36,
                  color: transfer.direction == TransferDirection.upload
                      ? AppColors.blue
                      : AppColors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: transfer.progress,
                            minHeight: 6,
                            backgroundColor: theme.dividerColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(transfer.progress * 100).toStringAsFixed(0)}% \u00b7 ${FileUtils.formatSize(transfer.fileSize)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                      if (transfer.status == TransferStatus.queued)
                        Text(
                          'Queued \u2014 waiting for connection',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                          ),
                        ),
                      if (transfer.status == TransferStatus.completed)
                        Text(
                          '${transfer.direction == TransferDirection.upload ? 'Uploaded' : 'Downloaded'} \u00b7 ${FileUtils.formatSize(transfer.fileSize)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.green,
                          ),
                        ),
                      if (isFailed)
                        Text(
                          transfer.errorMessage ?? 'Failed',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.red,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isActive)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () =>
                        ref.read(transferProvider.notifier).cancelTransfer(transfer.id),
                  ),
                if (isFailed)
                  TextButton(
                    onPressed: () {
                      if (transfer.localPath != null &&
                          transfer.parentFolderId != null) {
                        ref.read(transferProvider.notifier).startUpload(
                              transfer.localPath!,
                              transfer.parentFolderId!,
                            );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                if (transfer.status == TransferStatus.completed)
                  const Icon(Icons.check_circle, color: AppColors.green, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
