import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';


class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;
  final String fileName;
  final bool isCloudFile;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    required this.fileName,
    this.isCloudFile = false,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final TransformationController _transformController = TransformationController();
  bool _showOverlay = true;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showOverlay = !_showOverlay),
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: widget.isCloudFile
                    ? Image.network(widget.imagePath, fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white54, size: 64))
                    : Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                      ),
              ),
            ),
          ),

          // Overlay controls
          AnimatedOpacity(
            opacity: _showOverlay ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.black54,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      widget.fileName,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () => _shareFile(),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (widget.isCloudFile)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareFile() async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(widget.imagePath)], text: widget.fileName),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share file')),
      );
    }
  }
}
