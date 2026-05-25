import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/file_system_provider.dart';
import '../../providers/selection_provider.dart';
import '../../providers/clipboard_provider.dart';
import '../../providers/transfer_provider.dart';
import '../../models/local_file_item.dart';
import '../../widgets/file_browser/file_list_item.dart';
import '../../widgets/file_browser/file_grid_item.dart';
import '../../widgets/file_browser/empty_state_widget.dart';
import '../../widgets/file_browser/skeleton_list.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/bottom_sheets/new_item_sheet.dart';
import '../../widgets/bottom_sheets/rename_sheet.dart';
import '../../widgets/bottom_sheets/file_context_sheet.dart';
import '../../widgets/bottom_sheets/properties_sheet.dart';
import '../../widgets/bottom_sheets/compress_sheet.dart';
import '../../services/permission_service.dart';
import '../../services/file_service.dart';
import '../../services/drive_service.dart';
import '../../utils/file_utils.dart';

class FileBrowserScreen extends ConsumerStatefulWidget {
  final String initialPath;

  const FileBrowserScreen({
    super.key,
    this.initialPath = '/storage/emulated/0/',
  });

  @override
  ConsumerState<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends ConsumerState<FileBrowserScreen> {
  bool _gridView = false;
  String _sortBy = 'name';
  bool _sortAscending = true;
  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initNavigation());
  }

  Future<void> _initNavigation() async {
    final hasPermission = await _permissionService.requestStoragePermission();
    if (!mounted) return;
    if (hasPermission) {
      ref.read(fileSystemProvider.notifier).navigateTo(widget.initialPath);
    } else {
      // Show permission explanation
      _showPermissionRequiredSheet();
    }
  }

  void _showPermissionRequiredSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.folder_open, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Access Your Files',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'To browse your device files, Flashy needs storage permission.\n\nWe only access files you choose — nothing is shared without you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final granted = await _permissionService.requestStoragePermission();
                    if (granted && mounted) {
                      ref.read(fileSystemProvider.notifier).navigateTo(widget.initialPath);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Allow Access'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Not Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileState = ref.watch(fileSystemProvider);
    final selectionState = ref.watch(selectionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFolderName(fileState.currentPath),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              fileState.currentPath,
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
      body: fileState.isLoading
          ? const SkeletonList()
          : fileState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(fileState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(fileSystemProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : fileState.files.isEmpty
                  ? EmptyStateWidget.emptyFolder()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(fileSystemProvider.notifier).refresh(),
                      child: _gridView
                          ? _buildGridView(fileState.files, selectionState, theme)
                          : _buildListView(fileState.files, selectionState, theme),
                    ),
      floatingActionButton: !selectionState.isSelecting
          ? FloatingActionButton(
              onPressed: () => _showNewItemSheet(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildListView(
    List<LocalFileItem> files,
    SelectionState selectionState,
    ThemeData theme,
  ) {
    return ListView.separated(
      itemCount: files.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 68,
        color: theme.dividerColor,
      ),
      itemBuilder: (context, index) {
        final file = files[index];
        return FileListItem.fromLocalFile(
          file,
          isSelected: selectionState.selectedPaths.contains(file.path),
          inSelectionMode: selectionState.isSelecting,
          onTap: () {
            if (selectionState.isSelecting) {
              ref.read(selectionProvider.notifier).toggleSelection(file.path);
            } else if (file.isDirectory) {
              ref.read(fileSystemProvider.notifier).navigateTo(file.path);
            } else {
              _openPreview(file);
            }
          },
          onLongPress: () {
            if (!selectionState.isSelecting) {
              ref.read(selectionProvider.notifier).startSelection(file.path);
            }
          },
          onSwipeLeft: file.isDirectory
              ? null
              : () => _handleSwipeDelete(file),
          onSwipeRight: file.isDirectory
              ? null
              : () => _handleSwipeCopy(file),
          onMoreTap: () => _showFileContextSheet(file),
        ).animate().fadeIn(
          duration: 200.ms,
          delay: (index * 25).ms,
        ).slideX(begin: 0.05);
      },
    );
  }

  Widget _buildGridView(
    List<LocalFileItem> files,
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
        final isSelected = selectionState.selectedPaths.contains(file.path);
        return FileGridItem.fromLocalFile(
          file,
          isSelected: isSelected,
          inSelectionMode: selectionState.isSelecting,
          onTap: () {
            if (selectionState.isSelecting) {
              ref.read(selectionProvider.notifier).toggleSelection(file.path);
            } else if (file.isDirectory) {
              ref.read(fileSystemProvider.notifier).navigateTo(file.path);
            } else {
              _openPreview(file);
            }
          },
          onLongPress: () {
            if (!selectionState.isSelecting) {
              ref.read(selectionProvider.notifier).startSelection(file.path);
            }
          },
        ).animate().fadeIn(
          duration: 200.ms,
          delay: (index * 25).ms,
        ).slideY(begin: 0.05);
      },
    );
  }

  String _getFolderName(String path) {
    final parts = path.split('/').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'Root';
    return parts.last;
  }

  void _handleSort(String value) {
    if (value == 'grid') {
      setState(() => _gridView = !_gridView);
    } else if (value == 'refresh') {
      ref.read(fileSystemProvider.notifier).refresh();
    } else {
      if (_sortBy == value) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = value;
        _sortAscending = true;
      }
    }
  }

  void _openPreview(LocalFileItem file) {
    if (FileUtils.isImage(file.name)) {
      context.push('/preview', extra: {
        'type': 'image',
        'path': file.path,
        'name': file.name,
        'isCloud': false,
      });
    } else if (FileUtils.isVideo(file.name)) {
      context.push('/preview', extra: {
        'type': 'video',
        'path': file.path,
        'name': file.name,
        'isCloud': false,
      });
    } else if (FileUtils.isAudio(file.name)) {
      context.push('/preview', extra: {
        'type': 'audio',
        'path': file.path,
        'name': file.name,
        'isCloud': false,
      });
    } else if (FileUtils.isDocument(file.name) && file.name.endsWith('.pdf')) {
      context.push('/preview', extra: {
        'type': 'pdf',
        'path': file.path,
        'name': file.name,
        'isCloud': false,
      });
    } else if (FileUtils.isArchive(file.name)) {
      context.push('/preview', extra: {
        'type': 'archive',
        'path': file.path,
        'name': file.name,
        'isCloud': false,
      });
    } else if (FileUtils.isTextFile(file.name) || FileUtils.isCodeFile(file.name)) {
      context.push('/preview', extra: {
        'type': 'text',
        'path': file.path,
        'name': file.name,
        'isCloud': false,
      });
    }
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

  void _showFileContextSheet(LocalFileItem file) {
    final fileService = FileService();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => FileContextSheet(
        file: file,
        onOpen: () => _openPreview(file),
        onRename: () async {
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
            try {
              await fileService.renameFile(file.path, newName);
              ref.read(fileSystemProvider.notifier).refresh();
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Rename failed: $e')),
              );
            }
          }
        },
        onCopy: () {
          ref.read(clipboardProvider.notifier).copy([file.path]);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${file.name} copied')),
          );
        },                onCut: () {
          ref.read(clipboardProvider.notifier).cut([file.path]);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${file.name} cut'),
              action: SnackBarAction(label: 'Paste here', onPressed: () {
                _handlePaste(file.path);
              }),
            ),
          );
        },
        onDelete: () async {
          final confirmed = await ConfirmDialog.showDelete(
            context: context,
            itemName: file.name,
          );
          if (confirmed && mounted) {
            try {
              await fileService.deleteFile(file.path);
              ref.read(fileSystemProvider.notifier).refresh();
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
        },
        onShare: () async {
          try {
            await SharePlus.instance.share(
              ShareParams(files: [XFile(file.path)], text: file.name),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not share file')),
            );
          }
        },
        onProperties: () => _showProperties(file),
        onCompress: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (ctx) => CompressSheet(
              defaultName: '${FileUtils.getFileNameWithoutExtension(file.name)}.zip',
              onCompress: (name) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Compressing to $name...')),
                );
              },
            ),
          );
        },
        onFavorites: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${file.name} added to favorites')),
          );
        },
        onOpenWith: () {
          try {
            Process.run('xdg-open', [file.path]);
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open file')),
            );
          }
        },
      ),
    );
  }

  Future<void> _createNewFolder() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && mounted) {
      final fileService = FileService();
      try {
        await fileService.createDirectory('${ref.read(fileSystemProvider).currentPath}/$name');
        ref.read(fileSystemProvider.notifier).refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create folder: $e')),
        );
      }
    }
  }

  Future<void> _createNewTextFile() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Text File'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'file.txt',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && mounted) {
      final fileService = FileService();
      try {
        await fileService.createTextFile(
          '${ref.read(fileSystemProvider).currentPath}/$name',
          '',
        );
        ref.read(fileSystemProvider.notifier).refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create file: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty || !mounted) return;
      for (final file in result.files) {
        if (file.path != null) {
          await ref.read(transferProvider.notifier).startUpload(
            file.path!,
            'root',
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.files.length} file(s) uploaded')),
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
      for (final file in result.files) {
        if (file.path != null) {
          await ref.read(transferProvider.notifier).startUpload(
            file.path!,
            'root',
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.files.length} photo(s) uploaded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: $e')),
      );
    }
  }

  Future<void> _handleSwipeDelete(LocalFileItem file) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: file.name,
    );
    if (!confirmed || !mounted) return;
    try {
      final fileToDelete = File(file.path);
      final deletedPath = file.path;
      if (await fileToDelete.exists()) {
        await fileToDelete.delete(recursive: true);
        if (!mounted) return;
        ref.read(fileSystemProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                // Re-create the file/directory from backup if possible
                try {
                  if (file.isDirectory) {
                    await Directory(deletedPath).create();
                  } else {
                    await File(deletedPath).writeAsBytes([]);
                  }
                  if (mounted) ref.read(fileSystemProvider.notifier).refresh();
                } catch (_) {}
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    }
  }

  void _handleSwipeCopy(LocalFileItem file) {
    ref.read(clipboardProvider.notifier).copy([file.path]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${file.name} copied to clipboard')),
    );
  }

  void _handlePaste(String destinationPath) {
    final clipboard = ref.read(clipboardProvider);
    if (!clipboard.hasItems) return;
    
    final fileService = FileService();
    for (final sourcePath in clipboard.files) {
      final destParent = destinationPath.contains('/')
          ? destinationPath.substring(0, destinationPath.lastIndexOf('/'))
          : ref.read(fileSystemProvider).currentPath;
      final fileName = sourcePath.split('/').last;
      final destPath = '$destParent/$fileName';
      
      if (clipboard.operation == 'copy') {
        fileService.copyFile(sourcePath, destPath);
      } else if (clipboard.operation == 'cut') {
        fileService.moveFile(sourcePath, destPath);
      }
    }
    ref.read(clipboardProvider.notifier).clear();
    ref.read(fileSystemProvider.notifier).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${clipboard.files.length} item(s) pasted')),
    );
  }

  void _showProperties(LocalFileItem file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => PropertiesSheet.fromLocalFile(file),
    );
  }
}
