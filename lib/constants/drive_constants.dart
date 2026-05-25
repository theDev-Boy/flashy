class DriveConstants {
  DriveConstants._();

  static const String flashyRootFolder = 'Flashy';
  static const int maxUploadRetries = 3;
  static const int smallFileThreshold = 5 * 1024 * 1024; // 5MB
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration realtimeSyncInterval = Duration(seconds: 30);
  static const int maxCacheAgeHours = 24;
  static const int itemsPerPage = 100;
  static const String driveFileScope = 'https://www.googleapis.com/auth/drive.file';
  static const String appFolderMimeType = 'application/vnd.google-apps.folder';
}
