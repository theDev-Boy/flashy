import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';

class ExtractSheet extends StatelessWidget {
  final String archiveName;
  final ValueChanged<String> onExtract;

  const ExtractSheet({
    super.key,
    required this.archiveName,
    required this.onExtract,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Extract Archive', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Extract: $archiveName', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            const Text('Extract to current folder', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.cancel),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onExtract('here');
                  },
                  child: const Text('Extract Here'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
