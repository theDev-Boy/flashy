import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_strings.dart';

class ThemeSelectorCards extends ConsumerWidget {
  const ThemeSelectorCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider).themeMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildCard(context, AppStrings.light, Icons.light_mode, ThemeMode.light,
              themeMode == ThemeMode.light, ref),
          const SizedBox(width: 8),
          _buildCard(context, AppStrings.dark, Icons.dark_mode, ThemeMode.dark,
              themeMode == ThemeMode.dark, ref),
          const SizedBox(width: 8),
          _buildCard(context, AppStrings.system, Icons.settings_suggest,
              ThemeMode.system, themeMode == ThemeMode.system, ref),
        ],
      ),
    );
  }

  Widget _buildCard(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
