class LocalFileItem {
  final String path;
  final String name;
  final int? size;
  final DateTime? modifiedTime;
  final DateTime? createdTime;
  final bool isDirectory;

  LocalFileItem({
    required this.path,
    required this.name,
    this.size,
    this.modifiedTime,
    this.createdTime,
    this.isDirectory = false,
  });

  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot == -1) return '';
    return name.substring(dot).toLowerCase();
  }

  String get nameWithoutExtension {
    final dot = name.lastIndexOf('.');
    if (dot == -1) return name;
    return name.substring(0, dot);
  }
}
