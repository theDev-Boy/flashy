import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class OfflineWarningSheet {
  static void show({
    required BuildContext context,
    bool isUpload = false,
    VoidCallback? onQueue,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUpload ? Icons.cloud_off : Icons.cloud_off,
                size: 48,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              Text(
                isUpload ? "You're Offline" : 'No Internet Connection',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isUpload
                    ? 'Upload will be queued and start automatically when you\'re back online.'
                    : 'You need internet to open Flashy Disk files. Connect to Wi-Fi or mobile data and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (isUpload) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onQueue?.call();
                      },
                      child: Text(isUpload ? 'Queue Upload' : 'OK — Got it'),
                    ),
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
