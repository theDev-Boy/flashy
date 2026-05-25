import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../utils/file_utils.dart';

class ArchivePreviewScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const ArchivePreviewScreen({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<ArchivePreviewScreen> createState() => _ArchivePreviewScreenState();
}

class _ArchivePreviewScreenState extends State<ArchivePreviewScreen> {
  List<ArchiveFile> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  Future<void> _loadArchive() async {
    try {
      final file = File(widget.filePath);
      final bytes = await file.readAsBytes();
      final ext = widget.fileName.split('.').last.toLowerCase();

      Archive? archive;
      if (ext == 'zip') {
        archive = ZipDecoder().decodeBytes(bytes);
      } else if (ext == 'tar') {
        archive = TarDecoder().decodeBytes(bytes);
      } else if (ext == 'gz' || ext == 'tgz') {
        final gzBytes = GZipDecoder().decodeBytes(bytes);
        archive = TarDecoder().decodeBytes(gzBytes);
      } else {
        setState(() {
          _error = 'Unsupported archive format: .$ext';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _entries = archive?.files.toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not read archive: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          TextButton.icon(
            onPressed: _entries.isNotEmpty ? () {} : null,
            icon: const Icon(Icons.unarchive),
            label: const Text('Extract All'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48,
                          color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                )
              : _entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.archive_outlined, size: 64,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text('Archive is empty',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              )),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        final isDir = entry.isFile == false;
                        final size = entry.size;

                        return ListTile(
                          leading: Icon(
                            isDir ? Icons.folder : Icons.insert_drive_file,
                            color: isDir ? AppColors.warning : AppColors.blue,
                            size: 20,
                          ),
                          title: Text(
                            entry.name,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: isDir
                              ? null
                              : Text(
                                  FileUtils.formatSize(size),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                          dense: true,
                        );
                      },
                    ),
    );
  }
}
