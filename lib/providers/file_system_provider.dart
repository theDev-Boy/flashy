import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/local_file_item.dart';
import '../services/file_service.dart';

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

class FileSystemState {
  final String currentPath;
  final List<LocalFileItem> files;
  final List<String> pathHistory;
  final bool isLoading;
  final String? error;

  const FileSystemState({
    this.currentPath = '/',
    this.files = const [],
    this.pathHistory = const [],
    this.isLoading = false,
    this.error,
  });

  FileSystemState copyWith({
    String? currentPath,
    List<LocalFileItem>? files,
    List<String>? pathHistory,
    bool? isLoading,
    String? error,
  }) {
    return FileSystemState(
      currentPath: currentPath ?? this.currentPath,
      files: files ?? this.files,
      pathHistory: pathHistory ?? this.pathHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FileSystemNotifier extends Notifier<FileSystemState> {
  @override
  FileSystemState build() => const FileSystemState();

  Future<void> navigateTo(String path) async {
    final history = List<String>.from(state.pathHistory);
    if (state.currentPath != '/') {
      history.add(state.currentPath);
    }

    state = state.copyWith(isLoading: true, currentPath: path, pathHistory: history);
    await _loadFiles(path);
  }

  Future<void> goBack() async {
    if (state.pathHistory.isNotEmpty) {
      final history = List<String>.from(state.pathHistory);
      final previousPath = history.removeLast();
      state = state.copyWith(pathHistory: history, currentPath: previousPath, isLoading: true);
      await _loadFiles(previousPath);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadFiles(state.currentPath);
  }

  Future<void> _loadFiles(String path) async {
    try {
      final fileService = ref.read(fileServiceProvider);
      final files = await fileService.listDirectory(path);
      state = state.copyWith(files: files, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load files: ${e.toString()}',
      );
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true);
    try {
      final fileService = ref.read(fileServiceProvider);
      final files = await fileService.searchFiles(query, state.currentPath);
      state = state.copyWith(files: files, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final fileSystemProvider = NotifierProvider<FileSystemNotifier, FileSystemState>(FileSystemNotifier.new);
