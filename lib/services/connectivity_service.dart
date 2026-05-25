import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  StreamSubscription? _subscription;

  Stream<bool> get onConnectivityChanged => _connectivityController.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);
    _connectivityController.add(_isConnected);

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _isConnected = !result.contains(ConnectivityResult.none);
      _connectivityController.add(_isConnected);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
