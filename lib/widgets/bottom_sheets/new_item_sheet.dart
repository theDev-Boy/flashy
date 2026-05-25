import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';

class NewItemSheet extends StatelessWidget {
  final VoidCallback? onNewFolder;
  final VoidCallback? onNewTextFile;
  final VoidCallback? onUploadFiles;
  final VoidCallback? onUploadPhoto;

  const NewItemSheet({
    super.key,
    this.onNewFolder,
    this.onNewTextFile,
    this.onUploadFiles,
    this.onUploadPhoto,
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
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.create_new_folder),
            title: const Text(AppStrings.newFolder),
            onTap: () { Navigator.pop(context); onNewFolder?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text(AppStrings.newTextFile),
            onTap: () { Navigator.pop(context); onNewTextFile?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text(AppStrings.uploadFiles),
            onTap: () { Navigator.pop(context); onUploadFiles?.call(); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text(AppStrings.uploadPhoto),
            onTap: () { Navigator.pop(context); onUploadPhoto?.call(); },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
