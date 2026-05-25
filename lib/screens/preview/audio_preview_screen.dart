import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';

class AudioPreviewScreen extends StatefulWidget {
  final String filePath;
  final String fileName;
  final bool isCloudFile;

  const AudioPreviewScreen({
    super.key,
    required this.filePath,
    required this.fileName,
    this.isCloudFile = false,
  });

  @override
  State<AudioPreviewScreen> createState() => _AudioPreviewScreenState();
}

class _AudioPreviewScreenState extends State<AudioPreviewScreen> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareFile(),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album art placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.music_note,
                size: 80,
                color: AppColors.green.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),

            // Song name
            Text(
              widget.fileName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Waveform placeholder
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  20,
                  (index) => Container(
                    width: 4,
                    height: 20 + (index % 5) * 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time
            Text(
              '0:00 / 0:00',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 36,
                  onPressed: () {},
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 64,
                    color: AppColors.green,
                  ),
                  onPressed: () => setState(() => _isPlaying = !_isPlaying),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 36,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareFile() async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(widget.filePath)], text: widget.fileName),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share file')),
      );
    }
  }
}
