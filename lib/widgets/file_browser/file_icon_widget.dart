import 'package:flutter/material.dart';
import '../../utils/file_utils.dart';
import '../../constants/app_colors.dart';

class FileIconWidget extends StatelessWidget {
  final String fileName;
  final double size;
  final bool isFolder;
  final bool isCloudFolder;
  final String? thumbnailUrl;

  const FileIconWidget({
    super.key,
    required this.fileName,
    this.size = 44,
    this.isFolder = false,
    this.isCloudFolder = false,
    this.thumbnailUrl,
  });

  Color _getBackgroundColor(BuildContext context) {
    if (isFolder) {
      return isCloudFolder
          ? (Theme.of(context).brightness == Brightness.dark
              ? AppColors.flashyDiskBgDark
              : AppColors.flashyDiskBgLight)
          : (Theme.of(context).brightness == Brightness.dark
              ? AppColors.fileIconFolderDark
              : AppColors.fileIconFolderLight);
    }

    final category = FileUtils.getFileCategory(fileName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (category) {
      case 'image':
        return isDark ? AppColors.fileIconImageDark : AppColors.fileIconImageLight;
      case 'video':
        return isDark ? AppColors.fileIconVideoDark : AppColors.fileIconVideoLight;
      case 'audio':
        return isDark ? AppColors.fileIconAudioDark : AppColors.fileIconAudioLight;
      case 'document':
        return isDark ? AppColors.fileIconDocDark : AppColors.fileIconDocLight;
      case 'archive':
        return isDark ? AppColors.fileIconArchiveDark : AppColors.fileIconArchiveLight;
      case 'apk':
        return isDark ? AppColors.fileIconApkDark : AppColors.fileIconApkLight;
      case 'code':
        return isDark ? AppColors.fileIconCodeDark : AppColors.fileIconCodeLight;
      default:
        return isDark ? AppColors.fileIconOtherDark : AppColors.fileIconOtherLight;
    }
  }

  IconData _getIcon() {
    if (isFolder) return Icons.folder;
    if (FileUtils.isImage(fileName)) return Icons.image;
    if (FileUtils.isVideo(fileName)) return Icons.videocam;
    if (FileUtils.isAudio(fileName)) return Icons.music_note;
    if (FileUtils.isArchive(fileName)) return Icons.archive_outlined;
    if (FileUtils.isApk(fileName)) return Icons.android;
    if (FileUtils.isCodeFile(fileName)) return Icons.code;
    if (FileUtils.isDocument(fileName)) {
      if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf;
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  Color _getIconColor() {
    if (isFolder) {
      return isCloudFolder ? AppColors.flashyDiskBoltLight : AppColors.warning;
    }
    if (FileUtils.isImage(fileName)) return AppColors.purple;
    if (FileUtils.isVideo(fileName)) return AppColors.red;
    if (FileUtils.isAudio(fileName)) return AppColors.green;
    if (FileUtils.isArchive(fileName)) return AppColors.orange;
    if (FileUtils.isApk(fileName)) return AppColors.green;
    if (FileUtils.isCodeFile(fileName)) return AppColors.sky;
    return AppColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(),
              size: size * 0.5,
              color: _getIconColor(),
            ),
          ),
          if (isCloudFolder)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.cloud,
                  size: 10,
                  color: AppColors.sky,
                ),
              ),
            ),
          if (thumbnailUrl != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget flashyDiskIcon({double size = 44, bool isDark = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.flashyDiskBgDark : AppColors.flashyDiskBgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.bolt,
        size: size * 0.5,
        color: isDark ? AppColors.flashyDiskBoltDark : AppColors.flashyDiskBoltLight,
      ),
    );
  }
}
