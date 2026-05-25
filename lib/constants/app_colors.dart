import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary accent colors
  static const Color blue = Color(0xFF2563EB);
  static const Color sky = Color(0xFF0EA5E9);
  static const Color green = Color(0xFF16A34A);
  static const Color teal = Color(0xFF0D9488);
  static const Color purple = Color(0xFF7C3AED);
  static const Color orange = Color(0xFFEA580C);
  static const Color red = Color(0xFFDC2626);
  static const Color pink = Color(0xFFEC4899);

  static const List<Color> accentColors = [
    blue, sky, green, teal, purple, orange, red, pink,
  ];

  static const Map<String, Color> accentColorMap = {
    'blue': blue,
    'sky': sky,
    'green': green,
    'teal': teal,
    'purple': purple,
    'orange': orange,
    'red': red,
    'pink': pink,
  };

  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Light theme specific
  static const Color lightScaffoldBg = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFF3F4F6);
  static const Color lightSidebar = Color(0xFFF8F9FA);
  static const Color lightSecondaryText = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark theme specific
  static const Color darkScaffoldBg = Color(0xFF111827);
  static const Color darkCardBg = Color(0xFF1F2937);
  static const Color darkDivider = Color(0xFF374151);
  static const Color darkSidebar = Color(0xFF1F2937);
  static const Color darkSecondaryText = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF374151);

  // File type icon backgrounds - Light
  static const Color fileIconFolderLight = Color(0xFFFEF3C7);
  static const Color fileIconImageLight = Color(0xFFEDE9FE);
  static const Color fileIconVideoLight = Color(0xFFFEE2E2);
  static const Color fileIconAudioLight = Color(0xFFD1FAE5);
  static const Color fileIconDocLight = Color(0xFFDBEAFE);
  static const Color fileIconArchiveLight = Color(0xFFFEF9C3);
  static const Color fileIconApkLight = Color(0xFFDCFCE7);
  static const Color fileIconCodeLight = Color(0xFFE0F2FE);
  static const Color fileIconOtherLight = Color(0xFFF3F4F6);

  // File type icon backgrounds - Dark
  static const Color fileIconFolderDark = Color(0xFF3B2F00);
  static const Color fileIconImageDark = Color(0xFF2E1065);
  static const Color fileIconVideoDark = Color(0xFF450A0A);
  static const Color fileIconAudioDark = Color(0xFF064E3B);
  static const Color fileIconDocDark = Color(0xFF1E3A5F);
  static const Color fileIconArchiveDark = Color(0xFF422006);
  static const Color fileIconApkDark = Color(0xFF052E16);
  static const Color fileIconCodeDark = Color(0xFF0C2A3B);
  static const Color fileIconOtherDark = Color(0xFF1F2937);

  // Flashy Disk colors
  static const Color flashyDiskBgLight = Color(0xFFEFF6FF);
  static const Color flashyDiskBgDark = Color(0xFF1E3A5F);
  static const Color flashyDiskBoltLight = Color(0xFF2563EB);
  static const Color flashyDiskBoltDark = Color(0xFF60A5FA);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color infoBg = Color(0xFFEFF6FF);
}
