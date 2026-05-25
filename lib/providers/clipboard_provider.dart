import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClipboardState {
  final List<String> files;
  final String operation; // 'copy', 'cut', or 'none'

  const ClipboardState({
    this.files = const [],
    this.operation = 'none',
  });

  bool get hasItems => files.isNotEmpty;

  ClipboardState copyWith({
    List<String>? files,
    String? operation,
  }) {
    return ClipboardState(
      files: files ?? this.files,
      operation: operation ?? this.operation,
    );
  }
}

class ClipboardNotifier extends Notifier<ClipboardState> {
  @override
  ClipboardState build() => const ClipboardState();

  void copy(List<String> paths) {
    state = ClipboardState(files: paths, operation: 'copy');
  }

  void cut(List<String> paths) {
    state = ClipboardState(files: paths, operation: 'cut');
  }

  void paste(List<String> destinationPaths) {
    clear();
  }

  void clear() {
    state = const ClipboardState();
  }
}

final clipboardProvider = NotifierProvider<ClipboardNotifier, ClipboardState>(ClipboardNotifier.new);
