import 'dart:async';
import 'dart:io';
import '../models/transfer.dart';
import '../models/drive_file.dart';
import 'drive_service.dart';
import 'file_service.dart';
import 'cache_service.dart';

class TransferService {
  final DriveService _driveService;
  // ignore: unused_field
  final FileService _fileService;
  // ignore: unused_field
  final CacheService _cacheService;

  final StreamController<Transfer> _transferController =
      StreamController<Transfer>.broadcast();

  Stream<Transfer> get transferStream => _transferController.stream;
  final List<Transfer> _transfers = [];
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  TransferService(this._driveService, this._fileService, this._cacheService);

  List<Transfer> get transfers => List.unmodifiable(_transfers);

  Future<void> startUpload({
    required String localPath,
    required String parentFolderId,
  }) async {
    final file = File(localPath);
    final fileName = file.uri.pathSegments.last;
    final fileSize = await file.length();

    final transfer = Transfer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      fileSize: fileSize,
      direction: TransferDirection.upload,
      localPath: localPath,
      parentFolderId: parentFolderId,
    );

    _transfers.add(transfer);
    _transferController.add(transfer);

    try {
      await _driveService.uploadFile(
        localPath: localPath,
        parentFolderId: parentFolderId,
        onProgress: (sent, total) {
          final updated = transfer.copyWith(
            progress: sent / total,
          );
          final idx = _transfers.indexWhere((t) => t.id == transfer.id);
          if (idx >= 0) {
            _transfers[idx] = updated;
            _transferController.add(updated);
          }
        },
      );

      final completed = transfer.copyWith(
        status: TransferStatus.completed,
        progress: 1.0,
        completedAt: DateTime.now(),
      );
      final idx = _transfers.indexWhere((t) => t.id == transfer.id);
      if (idx >= 0) {
        _transfers[idx] = completed;
        _transferController.add(completed);
      }
    } catch (e) {
      final failed = transfer.copyWith(
        status: TransferStatus.failed,
        errorMessage: e.toString(),
        completedAt: DateTime.now(),
      );
      final idx = _transfers.indexWhere((t) => t.id == transfer.id);
      if (idx >= 0) {
        _transfers[idx] = failed;
        _transferController.add(failed);
      }
    }
  }

  Future<void> startDownload({
    required DriveFile driveFile,
    required String localPath,
  }) async {
    final transfer = Transfer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: driveFile.name,
      fileSize: driveFile.size ?? 0,
      direction: TransferDirection.download,
      driveFileId: driveFile.id,
      localPath: localPath,
    );

    _transfers.add(transfer);
    _transferController.add(transfer);

    try {
      await _driveService.downloadFile(
        driveFile.id,
        localPath,
        onProgress: (received, total) {
          final updated = transfer.copyWith(
            progress: total > 0 ? received / total : 0,
          );
          final idx = _transfers.indexWhere((t) => t.id == transfer.id);
          if (idx >= 0) {
            _transfers[idx] = updated;
            _transferController.add(updated);
          }
        },
      );

      final completed = transfer.copyWith(
        status: TransferStatus.completed,
        progress: 1.0,
        completedAt: DateTime.now(),
      );
      final idx = _transfers.indexWhere((t) => t.id == transfer.id);
      if (idx >= 0) {
        _transfers[idx] = completed;
        _transferController.add(completed);
      }
    } catch (e) {
      final failed = transfer.copyWith(
        status: TransferStatus.failed,
        errorMessage: e.toString(),
      );
      final idx = _transfers.indexWhere((t) => t.id == transfer.id);
      if (idx >= 0) {
        _transfers[idx] = failed;
        _transferController.add(failed);
      }
    }
  }

  void cancelTransfer(String id) {
    final idx = _transfers.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _transfers[idx] = _transfers[idx].copyWith(
        status: TransferStatus.cancelled,
        completedAt: DateTime.now(),
      );
      _transferController.add(_transfers[idx]);
    }
  }

  void dispose() {
    _transferController.close();
    for (var sub in _activeSubscriptions.values) {
      sub.cancel();
    }
    _activeSubscriptions.clear();
  }
}
