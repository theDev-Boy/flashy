import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transfer.dart';
import '../models/drive_file.dart';
import '../services/transfer_service.dart';
import '../services/drive_service.dart';
import 'auth_provider.dart';
import 'drive_provider.dart';
import 'file_system_provider.dart';

class TransferState {
  final List<Transfer> active;
  final List<Transfer> queued;
  final List<Transfer> completed;
  final List<Transfer> failed;

  const TransferState({
    this.active = const [],
    this.queued = const [],
    this.completed = const [],
    this.failed = const [],
  });

  TransferState copyWith({
    List<Transfer>? active,
    List<Transfer>? queued,
    List<Transfer>? completed,
    List<Transfer>? failed,
  }) {
    return TransferState(
      active: active ?? this.active,
      queued: queued ?? this.queued,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
    );
  }
}

class TransferNotifier extends Notifier<TransferState> {
  TransferService? _transferService;

  @override
  TransferState build() => const TransferState();

  Future<TransferService> _getService() async {
    if (_transferService != null) return _transferService!;
    final authService = ref.read(authServiceProvider);
    final driveApi = await authService.getDriveApi();
    if (driveApi == null) throw Exception('Not authenticated');

    _transferService = TransferService(
      DriveService(driveApi),
      ref.read(fileServiceProvider),
      ref.read(cacheServiceProvider),
    );

    _transferService!.transferStream.listen(_onTransferUpdate);
    return _transferService!;
  }

  void _onTransferUpdate(Transfer transfer) {
    final active = List<Transfer>.from(state.active);
    final completed = List<Transfer>.from(state.completed);
    final failed = List<Transfer>.from(state.failed);

    active.removeWhere((t) => t.id == transfer.id);
    completed.removeWhere((t) => t.id == transfer.id);
    failed.removeWhere((t) => t.id == transfer.id);

    switch (transfer.status) {
      case TransferStatus.active:
      case TransferStatus.queued:
        active.add(transfer);
        break;
      case TransferStatus.completed:
        completed.add(transfer);
        break;
      case TransferStatus.failed:
        failed.add(transfer);
        break;
      case TransferStatus.cancelled:
        break;
    }

    state = TransferState(
      active: active,
      queued: state.queued,
      completed: completed,
      failed: failed,
    );
  }

  Future<void> startUpload(String localPath, String folderId) async {
    final service = await _getService();
    await service.startUpload(localPath: localPath, parentFolderId: folderId);
  }

  Future<void> startDownload(DriveFile file, String localPath) async {
    final service = await _getService();
    await service.startDownload(driveFile: file, localPath: localPath);
  }

  void cancelTransfer(String id) {
    _transferService?.cancelTransfer(id);
  }

  void clearCompleted() {
    state = state.copyWith(completed: []);
  }
}

final transferProvider =
    NotifierProvider<TransferNotifier, TransferState>(TransferNotifier.new);
