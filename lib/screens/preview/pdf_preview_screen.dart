import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/app_colors.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String filePath;
  final String fileName;
  final bool isCloudFile;

  const PdfPreviewScreen({
    super.key,
    required this.filePath,
    required this.fileName,
    this.isCloudFile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareFile(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: AppColors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              fileName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openWith(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open with...'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _shareFile(context),
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share PDF'),
            ),
          ],
        ),
      ),
    );
  }

  void _openWith(BuildContext context) {
    try {
      OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: $e')),
      );
    }
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], text: fileName),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share file')),
      );
    }
  }
}
