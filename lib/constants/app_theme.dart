import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme(Color accentColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        surface: AppColors.lightScaffoldBg,
      ),
      scaffoldBackgroundColor: AppColors.lightScaffoldBg,
      cardColor: AppColors.lightCardBg,
      dividerColor: AppColors.lightDivider,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightCardBg,
        elevation: 0,
        indicatorColor: accentColor.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: [
        _FileIconColors(
          folder: AppColors.fileIconFolderLight,
          image: AppColors.fileIconImageLight,
          video: AppColors.fileIconVideoLight,
          audio: AppColors.fileIconAudioLight,
          doc: AppColors.fileIconDocLight,
          archive: AppColors.fileIconArchiveLight,
          apk: AppColors.fileIconApkLight,
          code: AppColors.fileIconCodeLight,
          other: AppColors.fileIconOtherLight,
          flashyDiskBg: AppColors.flashyDiskBgLight,
          flashyDiskBolt: AppColors.flashyDiskBoltLight,
        ),
      ],
    );
  }

  static ThemeData darkTheme(Color accentColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        surface: AppColors.darkScaffoldBg,
      ),
      scaffoldBackgroundColor: AppColors.darkScaffoldBg,
      cardColor: AppColors.darkCardBg,
      dividerColor: AppColors.darkDivider,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCardBg,
        elevation: 0,
        indicatorColor: accentColor.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: [
        _FileIconColors(
          folder: AppColors.fileIconFolderDark,
          image: AppColors.fileIconImageDark,
          video: AppColors.fileIconVideoDark,
          audio: AppColors.fileIconAudioDark,
          doc: AppColors.fileIconDocDark,
          archive: AppColors.fileIconArchiveDark,
          apk: AppColors.fileIconApkDark,
          code: AppColors.fileIconCodeDark,
          other: AppColors.fileIconOtherDark,
          flashyDiskBg: AppColors.flashyDiskBgDark,
          flashyDiskBolt: AppColors.flashyDiskBoltDark,
        ),
      ],
    );
  }
}

class _FileIconColors extends ThemeExtension<_FileIconColors> {
  final Color folder;
  final Color image;
  final Color video;
  final Color audio;
  final Color doc;
  final Color archive;
  final Color apk;
  final Color code;
  final Color other;
  final Color flashyDiskBg;
  final Color flashyDiskBolt;

  _FileIconColors({
    required this.folder,
    required this.image,
    required this.video,
    required this.audio,
    required this.doc,
    required this.archive,
    required this.apk,
    required this.code,
    required this.other,
    required this.flashyDiskBg,
    required this.flashyDiskBolt,
  });

  @override
  ThemeExtension<_FileIconColors> copyWith({
    Color? folder,
    Color? image,
    Color? video,
    Color? audio,
    Color? doc,
    Color? archive,
    Color? apk,
    Color? code,
    Color? other,
    Color? flashyDiskBg,
    Color? flashyDiskBolt,
  }) {
    return _FileIconColors(
      folder: folder ?? this.folder,
      image: image ?? this.image,
      video: video ?? this.video,
      audio: audio ?? this.audio,
      doc: doc ?? this.doc,
      archive: archive ?? this.archive,
      apk: apk ?? this.apk,
      code: code ?? this.code,
      other: other ?? this.other,
      flashyDiskBg: flashyDiskBg ?? this.flashyDiskBg,
      flashyDiskBolt: flashyDiskBolt ?? this.flashyDiskBolt,
    );
  }

  @override
  _FileIconColors lerp(_FileIconColors other, double t) {
    return _FileIconColors(
      folder: Color.lerp(folder, other.folder, t)!,
      image: Color.lerp(image, other.image, t)!,
      video: Color.lerp(video, other.video, t)!,
      audio: Color.lerp(audio, other.audio, t)!,
      doc: Color.lerp(doc, other.doc, t)!,
      archive: Color.lerp(archive, other.archive, t)!,
      apk: Color.lerp(apk, other.apk, t)!,
      code: Color.lerp(code, other.code, t)!,
      other: Color.lerp(this.other, other.other, t)!,
      flashyDiskBg: Color.lerp(flashyDiskBg, other.flashyDiskBg, t)!,
      flashyDiskBolt: Color.lerp(flashyDiskBolt, other.flashyDiskBolt, t)!,
    );
  }
}
