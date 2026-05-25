import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';

class SelectionAppBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onClear;
  final VoidCallback onSelectAll;

  const SelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.onClear,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClear,
      ),
      title: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: selectedCount),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) {
          return Text(
            '$value ${AppStrings.selected}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: onSelectAll,
          child: Text(
            AppStrings.selectAll,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
