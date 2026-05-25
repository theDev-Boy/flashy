import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 11+, use MANAGE_EXTERNAL_STORAGE
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;

      // Fallback to normal storage
      if (await Permission.storage.isGranted) return true;

      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }

    if (Platform.isIOS) {
      return true; // iOS uses sandboxed file access
    }

    return true;
  }

  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) return true;
      if (await Permission.storage.isGranted) return true;
      return false;
    }
    return true;
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  Future<PermissionStatus> checkPermission(Permission permission) async {
    return permission.status;
  }

  Future<bool> isPermissionGranted(Permission permission) async {
    return permission.isGranted;
  }

  Future<bool> openPermissionSettings() async {
    return await openAppSettings();
  }
}
