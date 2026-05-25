import 'package:flutter/material.dart';
import '../../models/local_file_item.dart';
import '../../models/drive_file.dart';
import '../../widgets/file_browser/file_icon_widget.dart';
import '../../utils/file_utils.dart';
import '../../utils/date_utils.dart' as date_utils;

class PropertiesSheet extends StatelessWidget {
  final String name;
  final bool isFolder;
  final bool isCloudFolder;
  final int? size;
  final String? path;
  final DateTime? createdTime;
  final DateTime? modifiedTime;
  final String? mimeType;
  final String? driveId;

  const PropertiesSheet({
    super.key,
    required this.name,
    this.isFolder = false,
    this.isCloudFolder = false,
    this.size,
    this.path,
    this.createdTime,
    this.modifiedTime,
    this.mimeType,
    this.driveId,
  });

  factory PropertiesSheet.fromLocalFile(LocalFileItem file) {
    return PropertiesSheet(
      name: file.name,
      isFolder: file.isDirectory,
      size: file.size,
      path: file.path,
      createdTime: file.createdTime,
      modifiedTime: file.modifiedTime,
    );
  }

  factory PropertiesSheet.fromDriveFile(DriveFile file) {
    return PropertiesSheet(
      name: file.name,
      isFolder: file.isFolder,
      isCloudFolder: true,
      size: file.size,
      modifiedTime: file.modifiedTime,
      createdTime: file.createdTime,
      mimeType: file.mimeType,
      driveId: file.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 1.0,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              FileIconWidget(
                fileName: name,
                isFolder: isFolder,
                isCloudFolder: isCloudFolder,
                size: 72,
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              _propertyRow('Type', isFolder ? 'Folder' : (mimeType ?? 'File')),
              if (size != null) _propertyRow('Size', '${FileUtils.formatSize(size!)} ($size bytes)'),
              if (path != null) _propertyRow('Location', path!),
              if (createdTime != null) _propertyRow('Created', date_utils.DateUtils.formatDateTime(createdTime!)),
              if (modifiedTime != null) _propertyRow('Modified', date_utils.DateUtils.formatDateTime(modifiedTime!)),
              if (driveId != null) _propertyRow('Drive ID', driveId!),
              if (isCloudFolder) _propertyRow('Sync status', '\u2705 Synced'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _propertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
