enum TransferDirection { upload, download }

enum TransferStatus { active, queued, completed, failed, cancelled }

class Transfer {
  final String id;
  final String fileName;
  final int fileSize;
  final TransferDirection direction;
  final TransferStatus status;
  final String? driveFileId;
  final String? localPath;
  final String? parentFolderId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final double progress;

  Transfer({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.direction,
    this.status = TransferStatus.active,
    this.driveFileId,
    this.localPath,
    this.parentFolderId,
    DateTime? startedAt,
    this.completedAt,
    this.errorMessage,
    this.progress = 0.0,
  }) : startedAt = startedAt ?? DateTime.now();

  Transfer copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    TransferDirection? direction,
    TransferStatus? status,
    String? driveFileId,
    String? localPath,
    String? parentFolderId,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    double? progress,
  }) {
    return Transfer(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      driveFileId: driveFileId ?? this.driveFileId,
      localPath: localPath ?? this.localPath,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }
}
