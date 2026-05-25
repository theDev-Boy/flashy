import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../models/drive_file.dart';
import '../services/drive_service.dart';
import '../services/cache_service.dart';

import 'auth_provider.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

class DriveState {
  final Map<String, List<DriveFile>> folderContents;
  final bool isLoading;
  final String? error;
  final drive.About? quota;

  const DriveState({
    this.folderContents = const {},
    this.isLoading = false,
    this.error,
    this.quota,
  });

  DriveState copyWith({
    Map<String, List<DriveFile>>? folderContents,
    bool? isLoading,
    String? error,
    drive.About? quota,
  }) {
    return DriveState(
      folderContents: folderContents ?? this.folderContents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      quota: quota ?? this.quota,
    );
  }
}

class DriveNotifier extends Notifier<DriveState> {
  @override
  DriveState build() => const DriveState();

  Future<void> listFolder(String folderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = ref.read(authServiceProvider);
      final driveApi = await authService.getDriveApi();
      if (driveApi == null) throw Exception('Not authenticated');

      final driveService = DriveService(driveApi);
      final cacheService = ref.read(cacheServiceProvider);

      // Try cache first
      final cached = await cacheService.getCachedDriveFiles(folderId);
      if (cached.isNotEmpty) {
        final updatedContents = Map<String, List<DriveFile>>.from(state.folderContents);
        updatedContents[folderId] = cached;
        state = state.copyWith(folderContents: updatedContents, isLoading: true);
      }

      // Fetch fresh data
      final files = await driveService.listFiles(folderId);

      await cacheService.cacheDriveFiles(files);

      final updatedContents = Map<String, List<DriveFile>>.from(state.folderContents);
      updatedContents[folderId] = files;
      state = state.copyWith(folderContents: updatedContents, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load Flashy Disk: ${e.toString()}',
      );
    }
  }

  Future<void> fetchQuota() async {
    try {
      final authService = ref.read(authServiceProvider);
      final driveApi = await authService.getDriveApi();
      if (driveApi == null) return;

      final driveService = DriveService(driveApi);
      final quota = await driveService.getQuota();
      state = state.copyWith(quota: quota);
    } catch (_) {}
  }

  Future<void> createFolder(String name, String parentId) async {
    try {
      final authService = ref.read(authServiceProvider);
      final driveApi = await authService.getDriveApi();
      if (driveApi == null) return;

      final driveService = DriveService(driveApi);
      await driveService.createFolder(name, parentId);
      await listFolder(parentId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create folder: ${e.toString()}');
    }
  }
}

final driveProvider = NotifierProvider<DriveNotifier, DriveState>(DriveNotifier.new);
