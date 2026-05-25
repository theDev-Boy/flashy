import 'package:flutter/material.dart';

class SelectionBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onCut;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;

  const SelectionBottomBar({
    super.key,
    required this.selectedCount,
    this.onCut,
    this.onCopy,
    this.onDelete,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: selectedCount > 0 ? 60 : 0,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAction(context, Icons.content_cut, 'Cut', onCut),
          _buildAction(context, Icons.content_copy, 'Copy', onCopy),
          _buildAction(context, Icons.delete_outline, 'Delete', onDelete,
              color: Colors.red),
          _buildAction(context, Icons.more_horiz, 'More', onMore),
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onTap, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color ?? theme.colorScheme.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
