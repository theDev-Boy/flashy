import 'package:flutter/material.dart';

class ConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    VoidCallback? onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm?.call();
            },
            child: Text(
              confirmText,
              style: confirmColor != null
                  ? TextStyle(color: confirmColor)
                  : null,
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<bool> showDelete({
    required BuildContext context,
    String? itemName,
    int? itemCount,
  }) async {
    final title = itemCount != null
        ? 'Delete $itemCount items?'
        : 'Delete ${itemName ?? 'this item'}?';

    final content = itemCount != null
        ? 'This cannot be undone.'
        : '${itemName ?? 'This file'} will be permanently deleted. This cannot be undone.';

    return show(
      context: context,
      title: title,
      message: content,
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );
  }
}
