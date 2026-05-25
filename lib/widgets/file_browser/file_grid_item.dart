import 'package:flutter/material.dart';
import '../../models/local_file_item.dart';
import '../../models/drive_file.dart';
import '../../utils/file_utils.dart';
import 'file_icon_widget.dart';

class FileGridItem extends StatelessWidget {
  final String name;
  final bool isFolder;
  final bool isCloudFolder;
  final bool isSelected;
  final bool inSelectionMode;
  final int? size;
  final DateTime? modifiedTime;
  final String? thumbnailUrl;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileGridItem({
    super.key,
    required this.name,
    this.isFolder = false,
    this.isCloudFolder = false,
    this.isSelected = false,
    this.inSelectionMode = false,
    this.size,
    this.modifiedTime,
    this.thumbnailUrl,
    this.onTap,
    this.onLongPress,
  });

  factory FileGridItem.fromLocalFile(
    LocalFileItem file, {
    bool isSelected = false,
    bool inSelectionMode = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return FileGridItem(
      name: file.name,
      isFolder: file.isDirectory,
      size: file.size,
      modifiedTime: file.modifiedTime,
      isSelected: isSelected,
      inSelectionMode: inSelectionMode,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  factory FileGridItem.fromDriveFile(
    DriveFile file, {
    bool isSelected = false,
    bool inSelectionMode = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return FileGridItem(
      name: file.name,
      isFolder: file.isFolder,
      isCloudFolder: true,
      size: file.size,
      modifiedTime: file.modifiedTime,
      thumbnailUrl: file.thumbnailLink,
      isSelected: isSelected,
      inSelectionMode: inSelectionMode,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: isSelected ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FileIconWidget(
                  fileName: name,
                  isFolder: isFolder,
                  isCloudFolder: isCloudFolder,
                  thumbnailUrl: thumbnailUrl,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (size != null && !isFolder) ...[
                  const SizedBox(height: 4),
                  Text(
                    FileUtils.formatSize(size!),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
            if (inSelectionMode)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
