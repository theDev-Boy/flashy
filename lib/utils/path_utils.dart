class PathUtils {
  PathUtils._();

  static String getFileName(String path) {
    final separator = path.contains('/') ? '/' : '\\';
    final parts = path.split(separator);
    return parts.isNotEmpty ? parts.last : path;
  }

  static String getParentPath(String path) {
    final separator = path.contains('/') ? '/' : '\\';
    final parts = path.split(separator);
    if (parts.length <= 1) return path;
    return parts.sublist(0, parts.length - 1).join(separator);
  }

  static String join(String part1, String part2) {
    if (part1.endsWith('/') || part1.endsWith('\\')) {
      return '$part1$part2';
    }
    return '$part1/$part2';
  }

  static String normalize(String path) {
    return path.replaceAll('\\', '/');
  }

  static bool isRootPath(String path) {
    return path == '/' || path == '/storage/emulated/0/';
  }

  static List<String> getPathSegments(String path) {
    final normalized = normalize(path);
    if (normalized == '/') return ['/'];
    return normalized.split('/').where((s) => s.isNotEmpty).toList();
  }
}
