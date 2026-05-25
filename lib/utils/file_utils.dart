import 'package:mime/mime.dart';

class FileUtils {
  FileUtils._();

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  static String getFileExtension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1) return '';
    return name.substring(dot).toLowerCase();
  }

  static String getFileNameWithoutExtension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1) return name;
    return name.substring(0, dot);
  }

  static String getMimeTypeFromName(String name) {
    return lookupMimeType(name) ?? 'application/octet-stream';
  }

  static bool isImage(String name) {
    final ext = getFileExtension(name);
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'].contains(ext);
  }

  static bool isVideo(String name) {
    final ext = getFileExtension(name);
    return ['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm'].contains(ext);
  }

  static bool isAudio(String name) {
    final ext = getFileExtension(name);
    return ['.mp3', '.wav', '.aac', '.flac', '.ogg', '.wma', '.m4a'].contains(ext);
  }

  static bool isDocument(String name) {
    final ext = getFileExtension(name);
    return ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.md', '.csv'].contains(ext);
  }

  static bool isArchive(String name) {
    final ext = getFileExtension(name);
    return ['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2'].contains(ext);
  }

  static bool isCodeFile(String name) {
    final ext = getFileExtension(name);
    return ['.dart', '.py', '.js', '.ts', '.java', '.kt', '.swift', '.cpp', '.c', '.h', '.html', '.css', '.json', '.xml', '.yaml', '.yml'].contains(ext);
  }

  static bool isApk(String name) {
    return getFileExtension(name) == '.apk';
  }

  static bool isTextFile(String name) {
    final ext = getFileExtension(name);
    return ['.txt', '.md', '.csv', '.log', '.json', '.xml', '.yaml', '.yml'].contains(ext);
  }

  static String getFileCategory(String name) {
    if (isImage(name)) return 'image';
    if (isVideo(name)) return 'video';
    if (isAudio(name)) return 'audio';
    if (isDocument(name)) return 'document';
    if (isArchive(name)) return 'archive';
    if (isApk(name)) return 'apk';
    if (isCodeFile(name)) return 'code';
    return 'other';
  }
}
