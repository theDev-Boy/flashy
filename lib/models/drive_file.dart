class DriveFile {
  final String id;
  final String name;
  final String? mimeType;
  final String? parentId;
  final int? size;
  final DateTime? modifiedTime;
  final DateTime? createdTime;
  final String? thumbnailLink;
  final String? webContentLink;
  final bool starred;
  final bool isFolder;
  final String? localThumbPath;
  final int? syncedAt;

  DriveFile({
    required this.id,
    required this.name,
    this.mimeType,
    this.parentId,
    this.size,
    this.modifiedTime,
    this.createdTime,
    this.thumbnailLink,
    this.webContentLink,
    this.starred = false,
    this.isFolder = false,
    this.localThumbPath,
    this.syncedAt,
  });

  factory DriveFile.fromJson(Map<String, dynamic> json) {
    return DriveFile(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      mimeType: json['mime_type'] as String?,
      parentId: json['parent_id'] as String?,
      size: json['size'] as int?,
      modifiedTime: json['modified_time'] != null
          ? DateTime.tryParse(json['modified_time'] as String)
          : null,
      createdTime: json['created_time'] != null
          ? DateTime.tryParse(json['created_time'] as String)
          : null,
      thumbnailLink: json['thumbnail_link'] as String?,
      webContentLink: json['web_content_link'] as String?,
      starred: (json['starred'] as int? ?? 0) == 1,
      isFolder: (json['is_folder'] as int? ?? 0) == 1,
      localThumbPath: json['local_thumb_path'] as String?,
      syncedAt: json['synced_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mime_type': mimeType,
      'parent_id': parentId,
      'size': size,
      'modified_time': modifiedTime?.toIso8601String(),
      'created_time': createdTime?.toIso8601String(),
      'thumbnail_link': thumbnailLink,
      'web_content_link': webContentLink,
      'starred': starred ? 1 : 0,
      'is_folder': isFolder ? 1 : 0,
      'local_thumb_path': localThumbPath,
      'synced_at': syncedAt,
    };
  }

  DriveFile copyWith({
    String? id,
    String? name,
    String? mimeType,
    String? parentId,
    int? size,
    DateTime? modifiedTime,
    DateTime? createdTime,
    String? thumbnailLink,
    String? webContentLink,
    bool? starred,
    bool? isFolder,
    String? localThumbPath,
    int? syncedAt,
  }) {
    return DriveFile(
      id: id ?? this.id,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      parentId: parentId ?? this.parentId,
      size: size ?? this.size,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      createdTime: createdTime ?? this.createdTime,
      thumbnailLink: thumbnailLink ?? this.thumbnailLink,
      webContentLink: webContentLink ?? this.webContentLink,
      starred: starred ?? this.starred,
      isFolder: isFolder ?? this.isFolder,
      localThumbPath: localThumbPath ?? this.localThumbPath,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
