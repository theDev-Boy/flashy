import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      showFileExtensions: prefs.getBool('show_file_extensions') ?? true,
      showHiddenFiles: prefs.getBool('show_hidden_files') ?? false,
      showFileSizes: prefs.getBool('show_file_sizes') ?? true,
      showDates: prefs.getBool('show_dates') ?? true,
      confirmBeforeDelete: prefs.getBool('confirm_before_delete') ?? true,
      defaultView: prefs.getString('default_view') ?? 'list',
      defaultSortBy: prefs.getString('default_sort_by') ?? 'name',
      sortAscending: prefs.getBool('sort_ascending') ?? true,
      offlineUploadQueue: prefs.getBool('offline_upload_queue') ?? true,
      showUploadPopup: prefs.getBool('show_upload_popup') ?? true,
      syncInterval: prefs.getString('sync_interval') ?? 'realtime',
      uploadNotifications: prefs.getBool('upload_notifications') ?? true,
      downloadNotifications: prefs.getBool('download_notifications') ?? true,
      syncErrorAlerts: prefs.getBool('sync_error_alerts') ?? true,
      iconSize: prefs.getDouble('icon_size') ?? 44.0,
      itemDensity: prefs.getDouble('item_density') ?? 64.0,
    );
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_file_extensions', newSettings.showFileExtensions);
    await prefs.setBool('show_hidden_files', newSettings.showHiddenFiles);
    await prefs.setBool('show_file_sizes', newSettings.showFileSizes);
    await prefs.setBool('show_dates', newSettings.showDates);
    await prefs.setBool('confirm_before_delete', newSettings.confirmBeforeDelete);
    await prefs.setString('default_view', newSettings.defaultView);
    await prefs.setString('default_sort_by', newSettings.defaultSortBy);
    await prefs.setBool('sort_ascending', newSettings.sortAscending);
    await prefs.setBool('offline_upload_queue', newSettings.offlineUploadQueue);
    await prefs.setBool('show_upload_popup', newSettings.showUploadPopup);
    await prefs.setString('sync_interval', newSettings.syncInterval);
    await prefs.setBool('upload_notifications', newSettings.uploadNotifications);
    await prefs.setBool('download_notifications', newSettings.downloadNotifications);
    await prefs.setBool('sync_error_alerts', newSettings.syncErrorAlerts);
    await prefs.setDouble('icon_size', newSettings.iconSize);
    await prefs.setDouble('item_density', newSettings.itemDensity);
    state = newSettings;
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }

    await _loadSettings();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
