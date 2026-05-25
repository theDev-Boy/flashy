import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transfer_provider.dart';
import '../../providers/upload_popup_provider.dart';
import '../file_browser/file_icon_widget.dart';
import '../../models/transfer.dart';
import '../../utils/file_utils.dart';
import '../../constants/app_colors.dart';

class UploadPopup extends ConsumerWidget {
  const UploadPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popupState = ref.watch(uploadPopupProvider);
    final transferState = ref.watch(transferProvider);

    if (!popupState.isVisible || transferState.active.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeTransfer = transferState.active.first;

    if (popupState.isMinimized) {
      return _buildMinimized(context, activeTransfer, ref);
    }

    return _buildFull(context, activeTransfer, ref);
  }

  Widget _buildMinimized(
    BuildContext context,
    Transfer transfer,
    WidgetRef ref,
  ) {
    return Positioned(
      bottom: 80,
      right: 16,
      child: GestureDetector(
        onTap: () => ref.read(uploadPopupProvider.notifier).toggleMinimize(),
        child: Container(
          width: 200,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.bolt, size: 18, color: AppColors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Uploading... ${(transfer.progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.expand_less, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFull(
    BuildContext context,
    Transfer transfer,
    WidgetRef ref,
  ) {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: GestureDetector(
        onPanUpdate: (details) {
          final currentPopupState = ref.read(uploadPopupProvider);
          ref.read(uploadPopupProvider.notifier).updatePosition(
            Offset(
              currentPopupState.position.dx + details.delta.dx,
              currentPopupState.position.dy + details.delta.dy,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    transfer.direction == TransferDirection.upload
                        ? Icons.upload
                        : Icons.download,
                    size: 18,
                    color: AppColors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    transfer.direction == TransferDirection.upload
                        ? 'Uploading to Flashy Disk'
                        : 'Downloading from Flashy Disk',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FileIconWidget(
                    fileName: transfer.fileName,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transfer.fileName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: transfer.progress,
                            minHeight: 8,
                            backgroundColor: Theme.of(context).dividerColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(transfer.progress * 100).toStringAsFixed(0)}%  ·  ${FileUtils.formatSize(transfer.fileSize)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        ref.read(uploadPopupProvider.notifier).toggleMinimize(),
                    child: const Text('Minimize', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => ref
                        .read(transferProvider.notifier)
                        .cancelTransfer(transfer.id),
                    child: const Text('Cancel',
                        style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


