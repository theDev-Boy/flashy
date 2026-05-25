import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool showFileExtensions;
  final bool showHiddenFiles;
  final bool showFileSizes;
  final bool showDates;
  final bool confirmBeforeDelete;
  final String defaultView;
  final String defaultSortBy;
  final bool sortAscending;
  final bool offlineUploadQueue;
  final bool showUploadPopup;
  final String syncInterval;
  final bool uploadNotifications;
  final bool downloadNotifications;
  final bool syncErrorAlerts;
  final double iconSize;
  final double itemDensity;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.accentColor = AppSettings.defaultAccent,
    this.showFileExtensions = true,
    this.showHiddenFiles = false,
    this.showFileSizes = true,
    this.showDates = true,
    this.confirmBeforeDelete = true,
    this.defaultView = 'list',
    this.defaultSortBy = 'name',
    this.sortAscending = true,
    this.offlineUploadQueue = true,
    this.showUploadPopup = true,
    this.syncInterval = 'realtime',
    this.uploadNotifications = true,
    this.downloadNotifications = true,
    this.syncErrorAlerts = true,
    this.iconSize = 44.0,
    this.itemDensity = 64.0,
  });

  static const Color defaultAccent = Color(0xFF2563EB);

  AppSettings copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? showFileExtensions,
    bool? showHiddenFiles,
    bool? showFileSizes,
    bool? showDates,
    bool? confirmBeforeDelete,
    String? defaultView,
    String? defaultSortBy,
    bool? sortAscending,
    bool? offlineUploadQueue,
    bool? showUploadPopup,
    String? syncInterval,
    bool? uploadNotifications,
    bool? downloadNotifications,
    bool? syncErrorAlerts,
    double? iconSize,
    double? itemDensity,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      showFileExtensions: showFileExtensions ?? this.showFileExtensions,
      showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
      showFileSizes: showFileSizes ?? this.showFileSizes,
      showDates: showDates ?? this.showDates,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      defaultView: defaultView ?? this.defaultView,
      defaultSortBy: defaultSortBy ?? this.defaultSortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      offlineUploadQueue: offlineUploadQueue ?? this.offlineUploadQueue,
      showUploadPopup: showUploadPopup ?? this.showUploadPopup,
      syncInterval: syncInterval ?? this.syncInterval,
      uploadNotifications: uploadNotifications ?? this.uploadNotifications,
      downloadNotifications: downloadNotifications ?? this.downloadNotifications,
      syncErrorAlerts: syncErrorAlerts ?? this.syncErrorAlerts,
      iconSize: iconSize ?? this.iconSize,
      itemDensity: itemDensity ?? this.itemDensity,
    );
  }
}
