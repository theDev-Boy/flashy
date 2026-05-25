import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionState {
  final Set<String> selectedPaths;
  final bool isSelecting;

  const SelectionState({
    this.selectedPaths = const {},
    this.isSelecting = false,
  });

  int get count => selectedPaths.length;

  SelectionState copyWith({
    Set<String>? selectedPaths,
    bool? isSelecting,
  }) {
    return SelectionState(
      selectedPaths: selectedPaths ?? this.selectedPaths,
      isSelecting: isSelecting ?? this.isSelecting,
    );
  }
}

class SelectionNotifier extends Notifier<SelectionState> {
  @override
  SelectionState build() => const SelectionState();

  void toggleSelection(String path) {
    final paths = Set<String>.from(state.selectedPaths);
    if (paths.contains(path)) {
      paths.remove(path);
    } else {
      paths.add(path);
    }

    if (paths.isEmpty) {
      state = state.copyWith(selectedPaths: paths, isSelecting: false);
    } else {
      state = state.copyWith(selectedPaths: paths, isSelecting: true);
    }
  }

  void selectAll(List<String> allPaths) {
    state = state.copyWith(
      selectedPaths: Set.from(allPaths),
      isSelecting: true,
    );
  }

  void clearSelection() {
    state = const SelectionState();
  }

  void startSelection(String path) {
    final paths = Set<String>.from(state.selectedPaths);
    paths.add(path);
    state = state.copyWith(selectedPaths: paths, isSelecting: true);
  }

  bool isSelected(String path) => state.selectedPaths.contains(path);
}

final selectionProvider = NotifierProvider<SelectionNotifier, SelectionState>(SelectionNotifier.new);
