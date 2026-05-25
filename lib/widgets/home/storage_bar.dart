import 'package:flutter/material.dart';
import '../../utils/file_utils.dart';
import '../../constants/app_colors.dart';

class StorageBar extends StatefulWidget {
  final int usedBytes;
  final int totalBytes;
  final Color? fillColor;

  const StorageBar({
    super.key,
    required this.usedBytes,
    required this.totalBytes,
    this.fillColor,
  });

  @override
  State<StorageBar> createState() => _StorageBarState();
}

class _StorageBarState extends State<StorageBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _widthAnimation = Tween<double>(begin: 0.0, end: getProgress()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double getProgress() {
    if (widget.totalBytes <= 0) return 0;
    return widget.usedBytes / widget.totalBytes;
  }

  int get freeBytes => widget.totalBytes - widget.usedBytes;

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.fillColor ?? AppColors.blue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      color: isDark
                          ? AppColors.darkBorder
                          : const Color(0xFFE5E7EB),
                    ),
                    AnimatedBuilder(
                    animation: _widthAnimation,
                    builder: (context, child) {
                      return Container(
                        width: constraints.maxWidth * _widthAnimation.value,
                        color: fillColor,
                      );
                    },
                  ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${FileUtils.formatSize(widget.usedBytes)} used',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${FileUtils.formatSize(freeBytes)} free',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


