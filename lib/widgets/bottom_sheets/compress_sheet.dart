import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';

class CompressSheet extends StatefulWidget {
  final String defaultName;
  final ValueChanged<String> onCompress;

  const CompressSheet({
    super.key,
    required this.defaultName,
    required this.onCompress,
  });

  @override
  State<CompressSheet> createState() => _CompressSheetState();
}

class _CompressSheetState extends State<CompressSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            const Text('Create Archive', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Archive Name',
                hintText: 'archive.zip',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Format: ZIP', style: TextStyle(fontSize: 13, color: Colors.grey)),
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
                    widget.onCompress(_controller.text.trim());
                  },
                  child: const Text('Create Archive'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
