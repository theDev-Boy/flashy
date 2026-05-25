import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ThumbnailService {
  Future<String?> cacheDriveThumbnail({
    required String thumbnailUrl,
    required String fileId,
  }) async {
    try {
      final cacheDir = await getThumbnailCacheDir();
      final localPath = p.join(cacheDir.path, '$fileId.jpg');

      if (await File(localPath).exists()) {
        return localPath;
      }

      // Download and cache thumbnail
      final response = await HttpClient().getUrl(Uri.parse(thumbnailUrl));
      final request = await response.close();
      final file = File(localPath);
      await request.pipe(file.openWrite());

      return localPath;
    } catch (e) {
      return null;
    }
  }

  Future<Directory> getThumbnailCacheDir() async {
    final appDir = await getTemporaryDirectory();
    final thumbDir = Directory(p.join(appDir.path, 'thumbnails'));
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    return thumbDir;
  }

  Future<void> clearThumbnailCache() async {
    final cacheDir = await getThumbnailCacheDir();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create();
    }
  }

  Future<int> getThumbnailCacheSize() async {
    final cacheDir = await getThumbnailCacheDir();
    int size = 0;
    if (await cacheDir.exists()) {
      await for (var entity in cacheDir.list()) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    }
    return size;
  }
}
