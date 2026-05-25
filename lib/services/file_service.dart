import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/local_file_item.dart';

class FileService {
  Future<List<LocalFileItem>> listDirectory(String path) async {
    final dir = Directory(path);
    final entities = await dir.list().toList();
    
    final items = <LocalFileItem>[];
    for (var entity in entities) {
      try {
        final stat = await entity.stat();
        items.add(LocalFileItem(
          path: entity.path,
          name: p.basename(entity.path),
          size: stat.size,
          modifiedTime: stat.modified,
          createdTime: stat.changed,
          isDirectory: entity is Directory,
        ));
      } catch (_) {
        // Skip files that can't be accessed
      }
    }
    
    items.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    
    return items;
  }

  Future<List<LocalFileItem>> searchFiles(String query, String rootPath) async {
    final results = <LocalFileItem>[];
    try {
      final root = Directory(rootPath);
      await for (var entity in root.list(recursive: true, followLinks: false)) {
        if (results.length >= 200) break; // Limit results
        try {
          final name = p.basename(entity.path);
          if (name.toLowerCase().contains(query.toLowerCase())) {
            final stat = await entity.stat();
            results.add(LocalFileItem(
              path: entity.path,
              name: name,
              size: stat.size,
              modifiedTime: stat.modified,
              isDirectory: entity is Directory,
            ));
          }
        } catch (_) {}
      }
    } catch (_) {}
    return results;
  }

  Future<void> createDirectory(String path) async {
    await Directory(path).create(recursive: true);
  }

  Future<void> deleteFile(String path) async {
    final entity = FileSystemEntity.typeSync(path);
    if (entity == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: true);
    } else {
      await File(path).delete();
    }
  }

  Future<void> copyFile(String source, String destination) async {
    final sourceType = FileSystemEntity.typeSync(source);
    if (sourceType == FileSystemEntityType.directory) {
      await _copyDirectory(Directory(source), Directory(destination));
    } else {
      await File(source).copy(destination);
    }
  }

  Future<void> moveFile(String source, String destination) async {
    await File(source).rename(destination);
  }

  Future<void> renameFile(String source, String newName) async {
    final parent = p.dirname(source);
    final dest = p.join(parent, newName);
    await File(source).rename(dest);
  }

  Future<File> createTextFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
    return file;
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (var entity in source.list()) {
      if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(p.join(destination.path, p.basename(entity.path))));
      }
    }
  }

  Future<int> getDirectorySize(String path) async {
    int totalSize = 0;
    try {
      final dir = Directory(path);
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            totalSize += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return totalSize;
  }

  Future<Map<String, dynamic>> getStorageInfo(String path) async {
    try {
      await Directory(path).stat();
      return {
        'path': path,
        'exists': true,
      };
    } catch (_) {
      return {
        'path': path,
        'exists': false,
      };
    }
  }
}
