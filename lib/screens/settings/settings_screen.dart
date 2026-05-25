import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabSettings),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Account Card
          if (authState.isAuthenticated)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: authState.user?.photoURL != null
                              ? NetworkImage(authState.user!.photoURL!)
                              : null,
                          child: authState.user?.photoURL == null
                              ? const Icon(Icons.person, size: 26)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.user?.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                authState.user?.email ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          _sectionHeader(context, AppStrings.appearance),

          // Theme selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _themeCard(context, 'Light', Icons.light_mode, ThemeMode.light,
                    themeState.themeMode == ThemeMode.light, ref),
                const SizedBox(width: 8),
                _themeCard(context, 'Dark', Icons.dark_mode, ThemeMode.dark,
                    themeState.themeMode == ThemeMode.dark, ref),
                const SizedBox(width: 8),
                _themeCard(context, 'System', Icons.settings_suggest,
                    ThemeMode.system, themeState.themeMode == ThemeMode.system, ref),
              ],
            ),
          ),

          // Accent color picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.accentColors.map((color) {
                final isSelected = themeState.accentColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () =>
                      ref.read(themeProvider.notifier).setAccentColor(color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          _sectionHeader(context, AppStrings.filePreferences),
          SwitchListTile(
            title: Text(AppStrings.showFileExtensions),
            value: settings.showFileExtensions,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSetting('show_file_extensions', v),
          ),
          SwitchListTile(
            title: Text(AppStrings.showHiddenFiles),
            value: settings.showHiddenFiles,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSetting('show_hidden_files', v),
          ),
          SwitchListTile(
            title: Text(AppStrings.confirmBeforeDelete),
            value: settings.confirmBeforeDelete,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSetting('confirm_before_delete', v),
          ),

          _sectionHeader(context, AppStrings.flashyDiskSettings),
          SwitchListTile(
            title: Text(AppStrings.offlineUploadQueue),
            value: settings.offlineUploadQueue,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSetting('offline_upload_queue', v),
          ),
          SwitchListTile(
            title: Text(AppStrings.showUploadPopup),
            value: settings.showUploadPopup,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSetting('show_upload_popup', v),
          ),

          _sectionHeader(context, AppStrings.notifications),
          SwitchListTile(
            title: Text(AppStrings.uploadCompleteNotif),
            value: settings.uploadNotifications,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSetting('upload_notifications', v),
          ),
          SwitchListTile(
            title: Text(AppStrings.downloadCompleteNotif),
            value: settings.downloadNotifications,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSetting('download_notifications', v),
          ),

          _sectionHeader(context, AppStrings.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppStrings.appVersion),
            subtitle: const Text('Flashy 1.0.0 (Build 1)'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(AppStrings.helpSupport),
            trailing: const Icon(Icons.open_in_new, size: 18),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(AppStrings.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 18),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(AppStrings.rateFlashy),
            trailing: const Icon(Icons.open_in_new, size: 18),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _themeCard(
    BuildContext context,
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    WidgetRef ref,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(themeProvider.notifier).setThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
