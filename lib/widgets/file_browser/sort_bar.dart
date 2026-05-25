import 'package:flutter/material.dart';

class SortBar extends StatelessWidget {
  final String sortBy;
  final bool ascending;
  final bool isGridView;
  final VoidCallback onSortTap;
  final VoidCallback onViewToggle;

  const SortBar({
    super.key,
    required this.sortBy,
    required this.ascending,
    required this.isGridView,
    required this.onSortTap,
    required this.onViewToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onSortTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sorted by ${_getSortLabel()} ${ascending ? '↑' : '↓'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onViewToggle,
            child: Icon(
              isGridView ? Icons.grid_view : Icons.list,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (sortBy) {
      case 'name':
        return 'Name';
      case 'date':
        return 'Date';
      case 'size':
        return 'Size';
      case 'type':
        return 'Type';
      default:
        return 'Name';
    }
  }
}
