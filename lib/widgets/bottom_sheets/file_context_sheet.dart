import 'package:flutter/material.dart';
import '../../models/local_file_item.dart';
import '../../constants/app_strings.dart';

class FileContextSheet extends StatelessWidget {
  final LocalFileItem file;
  final VoidCallback? onOpen;
  final VoidCallback? onRename;
  final VoidCallback? onCopy;
  final VoidCallback? onCut;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onProperties;
  final VoidCallback? onCompress;
  final VoidCallback? onFavorites;
  final VoidCallback? onOpenWith;

  const FileContextSheet({
    super.key,
    required this.file,
    this.onOpen,
    this.onRename,
    this.onCopy,
    this.onCut,
    this.onDelete,
    this.onShare,
    this.onProperties,
    this.onCompress,
    this.onFavorites,
    this.onOpenWith,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (!file.isDirectory) ...[
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text(AppStrings.openWith),
              onTap: () { Navigator.pop(context); onOpenWith?.call(); },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text(AppStrings.rename),
            onTap: () { Navigator.pop(context); onRename?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text(AppStrings.copy),
            onTap: () { Navigator.pop(context); onCopy?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.content_cut),
            title: const Text(AppStrings.cut),
            onTap: () { Navigator.pop(context); onCut?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text(AppStrings.compress),
            onTap: () { Navigator.pop(context); onCompress?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text(AppStrings.share),
            onTap: () { Navigator.pop(context); onShare?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text(AppStrings.addToFavorites),
            onTap: () { Navigator.pop(context); onFavorites?.call(); },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(AppStrings.delete, style: const TextStyle(color: Colors.red)),
            onTap: () { Navigator.pop(context); onDelete?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(AppStrings.properties),
            onTap: () { Navigator.pop(context); onProperties?.call(); },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
