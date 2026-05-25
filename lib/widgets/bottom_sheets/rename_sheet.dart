import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';

class RenameSheet extends StatefulWidget {
  final String currentName;
  final ValueChanged<String> onRename;

  const RenameSheet({
    super.key,
    required this.currentName,
    required this.onRename,
  });

  @override
  State<RenameSheet> createState() => _RenameSheetState();
}

class _RenameSheetState extends State<RenameSheet> {
  late TextEditingController _controller;
  String _error = '';

  @override
  void initState() {
    super.initState();
    final dotIndex = widget.currentName.lastIndexOf('.');
    final nameWithoutExt = dotIndex > 0
        ? widget.currentName.substring(0, dotIndex)
        : widget.currentName;
    _controller = TextEditingController(text: nameWithoutExt);
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: nameWithoutExt.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValid(String value) {
    if (value.trim().isEmpty) return false;
    const invalidChars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|'];
    return !invalidChars.any((c) => value.contains(c));
  }

  @override
  Widget build(BuildContext context) {
    final dotIndex = widget.currentName.lastIndexOf('.');
    final extension = dotIndex > 0 ? widget.currentName.substring(dotIndex) : '';
    final theme = Theme.of(context);

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
            Text(AppStrings.rename, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      errorText: _error.isNotEmpty ? _error : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (!_isValid(value)) {
                          _error = 'Invalid characters: / \\ : * ? < > |';
                        } else {
                          _error = '';
                        }
                      });
                    },
                  ),
                ),
                if (extension.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      extension,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
              ],
            ),
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
                  onPressed: _isValid(_controller.text) && _controller.text.trim().isNotEmpty
                      ? () {
                          Navigator.pop(context);
                          widget.onRename(_controller.text.trim() + extension);
                        }
                      : null,
                  child: const Text(AppStrings.rename),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
