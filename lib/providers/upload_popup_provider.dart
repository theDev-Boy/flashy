import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadPopupState {
  final bool isVisible;
  final bool isMinimized;
  final String? currentTransferId;
  final Offset position;

  const UploadPopupState({
    this.isVisible = false,
    this.isMinimized = false,
    this.currentTransferId,
    this.position = const Offset(16, 0),
  });

  UploadPopupState copyWith({
    bool? isVisible,
    bool? isMinimized,
    String? currentTransferId,
    Offset? position,
  }) {
    return UploadPopupState(
      isVisible: isVisible ?? this.isVisible,
      isMinimized: isMinimized ?? this.isMinimized,
      currentTransferId: currentTransferId ?? this.currentTransferId,
      position: position ?? this.position,
    );
  }
}

class UploadPopupNotifier extends Notifier<UploadPopupState> {
  @override
  UploadPopupState build() => const UploadPopupState();

  void show(String transferId) {
    state = state.copyWith(
      isVisible: true,
      isMinimized: false,
      currentTransferId: transferId,
    );
  }

  void toggleMinimize() {
    state = state.copyWith(isMinimized: !state.isMinimized);
  }

  void hide() {
    state = state.copyWith(isVisible: false, currentTransferId: null);
  }

  void updatePosition(Offset newPosition) {
    state = state.copyWith(position: newPosition);
  }
}

final uploadPopupProvider = NotifierProvider<UploadPopupNotifier, UploadPopupState>(UploadPopupNotifier.new);
