import 'package:flutter/material.dart';
import '../../utils/file_utils.dart';
import '../../utils/date_utils.dart' as date_utils;
import '../../models/local_file_item.dart';
import 'file_icon_widget.dart';

class FileListItem extends StatelessWidget {
  final String name;
  final String? subtitle;
  final bool isFolder;
  final bool isCloudFolder;
  final int? size;
  final DateTime? modifiedTime;
  final bool isSelected;
  final bool inSelectionMode;
  final String? thumbnailUrl;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMoreTap;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const FileListItem({
    super.key,
    required this.name,
    this.subtitle,
    this.isFolder = false,
    this.isCloudFolder = false,
    this.size,
    this.modifiedTime,
    this.isSelected = false,
    this.inSelectionMode = false,
    this.thumbnailUrl,
    this.onTap,
    this.onLongPress,
    this.onMoreTap,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  factory FileListItem.fromLocalFile(
    LocalFileItem file, {
    bool isSelected = false,
    bool inSelectionMode = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onMoreTap,
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
  }) {
    return FileListItem(
      name: file.name,
      isFolder: file.isDirectory,
      size: file.size,
      modifiedTime: file.modifiedTime,
      isSelected: isSelected,
      inSelectionMode: inSelectionMode,
      onTap: onTap,
      onLongPress: onLongPress,
      onMoreTap: onMoreTap,
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String itemSubtitle = subtitle ?? '';
    if (itemSubtitle.isEmpty) {
      final parts = <String>[];
      if (size != null && !isFolder) {
        parts.add(FileUtils.formatSize(size!));
      }
      if (modifiedTime != null) {
        parts.add(date_utils.DateUtils.formatRelative(modifiedTime!));
      }
      itemSubtitle = parts.join(' · ');
    }

    final itemContent = InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : null,
        ),
        child: Row(
          children: [
            if (inSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedScale(
                  scale: inSelectionMode ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
              ),
            FileIconWidget(
              fileName: name,
              isFolder: isFolder,
              isCloudFolder: isCloudFolder,
              thumbnailUrl: thumbnailUrl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itemSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onMoreTap != null && !inSelectionMode)
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: onMoreTap,
                ),
              ),
          ],
        ),
      ),
    );

    // If in selection mode or no swipe actions, no swipe gestures
    if (inSelectionMode || (onSwipeLeft == null && onSwipeRight == null)) {
      return itemContent;
    }

    // Wrap in Dismissible for swipe gestures
    return Dismissible(              key: ValueKey('file_${name}_$size'),
      direction: _getSwipeDirection(),
      background: onSwipeRight != null
          ? Container(
              color: theme.colorScheme.primary,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: const Icon(Icons.content_copy, color: Colors.white),
            )
          : null,
      secondaryBackground: onSwipeLeft != null
          ? Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            )
          : null,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && onSwipeRight != null) {
          onSwipeRight!();
          return false; // Don't actually dismiss - just trigger action
        } else if (direction == DismissDirection.endToStart && onSwipeLeft != null) {
          onSwipeLeft!();
          return false;
        }
        return false;
      },
      child: itemContent,
    );
  }

  DismissDirection _getSwipeDirection() {
    if (onSwipeLeft != null && onSwipeRight != null) {
      return DismissDirection.horizontal;
    }
    if (onSwipeLeft != null) {
      return DismissDirection.endToStart;
    }
    if (onSwipeRight != null) {
      return DismissDirection.startToEnd;
    }
    return DismissDirection.none;
  }
}
