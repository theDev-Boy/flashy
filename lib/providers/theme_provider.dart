import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color accentColor;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.accentColor = AppColors.blue,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    _loadPreferences();
    return const ThemeState();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeStr = prefs.getString('theme_mode') ?? 'system';
    final accentHex = prefs.getString('accent_color') ?? '#2563EB';

    ThemeMode themeMode;
    switch (themeModeStr) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    final color = AppColors.accentColorMap.values.firstWhere(
      (c) => c.toARGB32() == AppColors.fromHex(accentHex).toARGB32(),
      orElse: () => AppColors.blue,
    );

    state = ThemeState(themeMode: themeMode, accentColor: color);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      default:
        modeStr = 'system';
    }
    await prefs.setString('theme_mode', modeStr);
  }

  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColor: color);
    final prefs = await SharedPreferences.getInstance();
    final hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
    await prefs.setString('accent_color', '#$hex');
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
