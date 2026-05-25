import 'dart:io';

class PermissionUtils {
  PermissionUtils._();

  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;

  static bool isAndroid11OrAbove() {
    if (!isAndroid) return false;
    return Platform.operatingSystemVersion
        .split('.')
        .first
        .tryParseInt() >= 11;
  }

  static List<String> get commonStoragePaths {
    if (isAndroid) {
      return [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/',
      ];
    }
    if (isIOS) {
      // iOS uses path_provider for app-specific directories
      return [];
    }
    return [];
  }
}

extension on String {
  int tryParseInt() {
    try {
      return int.parse(this);
    } catch (_) {
      return 0;
    }
  }
}
