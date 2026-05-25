class UploadQueueItem {
  final int? id;
  final String localPath;
  final String destFolderId;
  final String fileName;
  final int? fileSize;
  final String status;
  final int createdAt;
  final int retryCount;

  UploadQueueItem({
    this.id,
    required this.localPath,
    required this.destFolderId,
    required this.fileName,
    this.fileSize,
    this.status = 'pending',
    int? createdAt,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory UploadQueueItem.fromJson(Map<String, dynamic> json) {
    return UploadQueueItem(
      id: json['id'] as int?,
      localPath: json['local_path'] as String,
      destFolderId: json['dest_folder_id'] as String,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'local_path': localPath,
      'dest_folder_id': destFolderId,
      'file_name': fileName,
      'file_size': fileSize,
      'status': status,
      'created_at': createdAt,
      'retry_count': retryCount,
    };
  }
}
