import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/drive_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/selection_provider.dart';
import '../../models/drive_file.dart';
import '../../widgets/file_browser/file_list_item.dart';
import '../../widgets/file_browser/file_grid_item.dart';
import '../../widgets/file_browser/empty_state_widget.dart';
import '../../widgets/file_browser/skeleton_list.dart';
import '../../widgets/flashy_disk/offline_banner.dart';
import '../../widgets/flashy_disk/offline_warning_sheet.dart';
import '../../widgets/bottom_sheets/new_item_sheet.dart';
import '../../widgets/bottom_sheets/rename_sheet.dart';
import '../../widgets/bottom_sheets/properties_sheet.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clipboard_provider.dart';
import '../../providers/transfer_provider.dart';
import '../../services/drive_service.dart';
import '../../utils/file_utils.dart';

class FlashyDiskScreen extends ConsumerStatefulWidget {
  final String? folderId;

  const FlashyDiskScreen({super.key, this.folderId});

  @override
  ConsumerState<FlashyDiskScreen> createState() => _FlashyDiskScreenState();
}

class _FlashyDiskScreenState extends ConsumerState<FlashyDiskScreen> {
  bool _gridView = false;
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(driveProvider.notifier).listFolder(widget.folderId ?? 'root');
    });
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);
    final selectionState = ref.watch(selectionProvider);
    final theme = Theme.of(context);

    final files = widget.folderId != null
        ? driveState.folderContents[widget.folderId] ?? []
        : driveState.folderContents['root'] ?? [];

    final sortedFiles = _sortFiles(files);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 18),
                const SizedBox(width: 6),
                Text(
                  widget.folderId == null
                      ? 'Flashy Disk'
                      : _getFolderName(files),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (widget.folderId != null)
              Text(
                'Flashy Disk',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleSort(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'size', child: Text('Sort by Size')),
              const PopupMenuItem(value: 'type', child: Text('Sort by Type')),
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                value: 'grid',
                checked: _gridView,
                child: const Text('Grid View'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: driveState.isLoading && files.isEmpty
                ? const SkeletonList()
                : driveState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48,
                                color: theme.colorScheme.error),
                            const SizedBox(height: 16),
                            Text(driveState.error!,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(driveProvider.notifier)
                                  .listFolder(widget.folderId ?? 'root'),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : sortedFiles.isEmpty
                        ? EmptyStateWidget.emptyDisk()
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(driveProvider.notifier)
                                .listFolder(widget.folderId ?? 'root'),
                            child: _gridView
                                ? _buildGridView(sortedFiles, selectionState, theme)
                                : _buildListView(sortedFiles, selectionState, theme),
                          ),
          ),
          // Selection bottom bar
          if (selectionState.isSelecting)
            _buildSelectionBottomBar(selectionState),
        ],
      ),
      floatingActionButton: !selectionState.isSelecting
          ? FloatingActionButton(
              onPressed: () => _showNewItemSheet(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildSelectionBottomBar(SelectionState selectionState) {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
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
          _selectionAction(Icons.content_cut, 'Cut', () {}),
          _selectionAction(Icons.content_copy, 'Copy', () {}),
          _selectionAction(Icons.delete_outline, 'Delete', () {
            _deleteSelectedItems(selectionState);
          }),
          _selectionAction(Icons.more_horiz, 'More', () {}),
        ],
      ),
    );
  }

  Widget _selectionAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedItems(SelectionState selectionState) async {
    final count = selectionState.selectedPaths.length;
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemCount: count,
    );
    if (!confirmed || !mounted) return;

    final authService = ref.read(authServiceProvider);
    final driveApi = await authService.getDriveApi();
    if (driveApi == null) return;

    final driveService = DriveService(driveApi);
    for (final fileId in selectionState.selectedPaths) {
      try {
        await driveService.deleteFile(fileId);
      } catch (_) {}
    }

    ref.read(selectionProvider.notifier).clearSelection();
    ref.read(driveProvider.notifier).listFolder(widget.folderId ?? 'root');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count items deleted')),
    );
  }

  Widget _buildListView(
    List<DriveFile> files,
    SelectionState selectionState,
    ThemeData theme,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 4),
      itemCount: files.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 68,
        color: theme.dividerColor,
      ),
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = selectionState.selectedPaths.contains(file.id);
        return FileListItem(
          name: file.name,
          isFolder: file.isFolder,
          isCloudFolder: true,
          size: file.size,
          modifiedTime: file.modifiedTime,
          isSelected: isSelected,
          inSelectionMode: selectionState.isSelecting,
          onTap: () {
            if (selectionState.isSelecting) {
              ref.read(selectionProvider.notifier).toggleSelection(file.id);
            } else if (file.isFolder) {
              context.push('/flashy-disk/${file.id}');
            } else {
              _openFile(file);
            }
          },
          onLongPress: () {
            if (!selectionState.isSelecting) {
              ref.read(selectionProvider.notifier).startSelection(file.id);
            }
          },
          onSwipeLeft: file.isFolder
              ? null
              : () => _handleSwipeDownload(file),
          onSwipeRight: file.isFolder
              ? null
              : () => _handleSwipeCopy(file),
          onMoreTap: () => _showFileContextSheet(file),
        );
      },
    );
  }

  Widget _buildGridView(
    List<DriveFile> files,
    SelectionState selectionState,
    ThemeData theme,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = selectionState.selectedPaths.contains(file.id);
        return FileGridItem.fromDriveFile(
          file,
          isSelected: isSelected,
          inSelectionMode: selectionState.isSelecting,
          onTap: () {
            if (selectionState.isSelecting) {
              ref.read(selectionProvider.notifier).toggleSelection(file.id);
            } else if (file.isFolder) {
              context.push('/flashy-disk/${file.id}');
            } else {
              _openFile(file);
            }
          },
          onLongPress: () {
            if (!selectionState.isSelecting) {
              ref.read(selectionProvider.notifier).startSelection(file.id);
            }
          },
        );
      },
    );
  }

  String _getFolderName(List<DriveFile> files) {
    return widget.folderId != null ? 'Folder' : 'Flashy Disk';
  }

  List<DriveFile> _sortFiles(List<DriveFile> files) {
    final sorted = List<DriveFile>.from(files);
    sorted.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;

      int result;
      switch (_sortBy) {
        case 'name':
          result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'date':
          result = (a.modifiedTime ?? DateTime(0))
              .compareTo(b.modifiedTime ?? DateTime(0));
          break;
        case 'size':
          result = (a.size ?? 0).compareTo(b.size ?? 0);
          break;
        case 'type':
          result = (a.mimeType ?? '').compareTo(b.mimeType ?? '');
          break;
        default:
          result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return _sortAscending ? result : -result;
    });
    return sorted;
  }

  void _handleSort(String value) {
    if (value == 'grid') {
      setState(() => _gridView = !_gridView);
    } else if (value == 'refresh') {
      ref.read(driveProvider.notifier).listFolder(widget.folderId ?? 'root');
    } else {
      if (_sortBy == value) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = value;
        _sortAscending = true;
      }
    }
  }

  void _openFile(DriveFile file) {
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      OfflineWarningSheet.show(context: context);
      return;
    }

    // Navigate to appropriate preview screen based on file type
    final ext = FileUtils.getFileExtension(file.name);
    if (FileUtils.isImage(file.name)) {
      context.push('/preview', extra: {
        'type': 'image',
        'path': file.id,
        'name': file.name,
        'isCloud': true,
        'thumbnail': file.thumbnailLink,
      });
    } else if (FileUtils.isVideo(file.name)) {
      context.push('/preview', extra: {
        'type': 'video',
        'path': file.id,
        'name': file.name,
        'isCloud': true,
      });
    } else if (FileUtils.isAudio(file.name)) {
      context.push('/preview', extra: {
        'type': 'audio',
        'path': file.id,
        'name': file.name,
        'isCloud': true,
      });
    } else if (FileUtils.isDocument(file.name) && ext == '.pdf') {
      context.push('/preview', extra: {
        'type': 'pdf',
        'path': file.id,
        'name': file.name,
        'isCloud': true,
      });
    } else if (FileUtils.isArchive(file.name)) {
      context.push('/preview', extra: {
        'type': 'archive',
        'path': file.id,
        'name': file.name,
        'isCloud': true,
      });
    } else if (FileUtils.isTextFile(file.name) || FileUtils.isCodeFile(file.name)) {
      context.push('/preview', extra: {
        'type': 'text',
        'path': file.id,
        'name': file.name,
        'isCloud': true,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot preview ${file.name}')),
      );
    }
  }

  void _showFileContextSheet(DriveFile file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open'),
              onTap: () { Navigator.pop(ctx); _openFile(file); },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _renameFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Copy'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(ctx);
                _handleSwipeDownload(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(ctx);
                _shareFile(file);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                await _deleteFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Properties'),
              onTap: () {
                Navigator.pop(ctx);
                _showProperties(file);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _renameFile(DriveFile file) async {
    final newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => RenameSheet(
        currentName: file.name,
        onRename: (name) => Navigator.pop(ctx, name),
      ),
    );

    if (newName != null && newName != file.name && mounted) {
      final authService = ref.read(authServiceProvider);
      final driveApi = await authService.getDriveApi();
      if (driveApi == null) return;
      try {
        final driveService = DriveService(driveApi);
        await driveService.renameFile(file.id, newName);
        ref.read(driveProvider.notifier).listFolder(widget.folderId ?? 'root');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rename failed: $e')),
        );
      }
    }
  }

  Future<void> _deleteFile(DriveFile file) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: file.name,
    );
    if (!confirmed || !mounted) return;

    final authService = ref.read(authServiceProvider);
    final driveApi = await authService.getDriveApi();
    if (driveApi == null) return;

    try {
      final driveService = DriveService(driveApi);
      await driveService.deleteFile(file.id);
      ref.read(driveProvider.notifier).listFolder(widget.folderId ?? 'root');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.name} deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  void _shareFile(DriveFile file) {
    SharePlus.instance.share(
      ShareParams(text: 'Check out ${file.name} on Flashy!'),
    );
  }

  void _handleSwipeDownload(DriveFile file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${file.name}...'),
        action: SnackBarAction(label: 'Cancel', onPressed: () {}),
      ),
    );
    // Actual download handled by transfer service
  }

  void _handleSwipeCopy(DriveFile file) {
    ref.read(clipboardProvider.notifier).copy([file.id]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${file.name} copied to clipboard')),
    );
  }

  void _showNewItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => NewItemSheet(
        onNewFolder: () => _createNewFolder(),
        onNewTextFile: () => _createNewTextFile(),
        onUploadFiles: () => _pickAndUploadFiles(),
        onUploadPhoto: () => _pickAndUploadPhoto(),
      ),
    );
  }

  Future<void> _createNewFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && mounted) {
      ref.read(driveProvider.notifier).createFolder(name, widget.folderId ?? 'root');
    }
  }

  Future<void> _createNewTextFile() async {
    final nameController = TextEditingController();
    final contentController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Text File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'file.txt',
                labelText: 'File name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your content here...',
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && mounted) {
      final authService = ref.read(authServiceProvider);
      final driveApi = await authService.getDriveApi();
      if (driveApi == null) return;

      // Ensure file has .txt extension for proper mime type detection
      final fileName = name.contains('.') ? name : '$name.txt';
      Directory? tempDir;

      try {
        final driveService = DriveService(driveApi);
        tempDir = await Directory.systemTemp.createTemp('flashy_');
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsString(contentController.text);

        await driveService.uploadFile(
          localPath: tempFile.path,
          parentFolderId: widget.folderId ?? 'root',
          onProgress: (sent, total) {},
        );

        ref.read(driveProvider.notifier).listFolder(widget.folderId ?? 'root');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileName created in Flashy Disk')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create file: $e')),
        );
      } finally {
        if (tempDir != null) {
          try {
            await tempDir.delete(recursive: true);
          } catch (_) {}
        }
      }
    }
  }

  Future<void> _pickAndUploadFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty || !mounted) return;

      int uploaded = 0;
      for (final file in result.files) {
        if (file.path != null) {
          await ref.read(transferProvider.notifier).startUpload(
            file.path!,
            widget.folderId ?? 'root',
          );
          uploaded++;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$uploaded file(s) uploading to Flashy Disk')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty || !mounted) return;

      int uploaded = 0;
      for (final file in result.files) {
        if (file.path != null) {
          await ref.read(transferProvider.notifier).startUpload(
            file.path!,
            widget.folderId ?? 'root',
          );
          uploaded++;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$uploaded photo(s) uploading to Flashy Disk')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: $e')),
      );
    }
  }

  void _showProperties(DriveFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => PropertiesSheet.fromDriveFile(file),
    );
  }
}
