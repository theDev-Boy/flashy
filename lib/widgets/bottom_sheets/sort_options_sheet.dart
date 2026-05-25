import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';

class SortOptionsSheet extends StatelessWidget {
  final String currentSortBy;
  final bool currentAscending;
  final ValueChanged<String> onSortByChanged;
  final ValueChanged<bool> onAscendingChanged;

  const SortOptionsSheet({
    super.key,
    required this.currentSortBy,
    required this.currentAscending,
    required this.onSortByChanged,
    required this.onAscendingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text('Sort By', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 8),
          ...['name', 'date', 'size', 'type'].map((sortBy) {
            final label = _getSortLabel(sortBy);
            final selected = currentSortBy == sortBy;
            return ListTile(
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(label),
              onTap: () {
                onSortByChanged(sortBy);
                Navigator.pop(context);
              },
            );
          }),
          const Divider(),
          SwitchListTile(
            title: Text(currentAscending ? AppStrings.ascending : AppStrings.descending),
            value: currentAscending,
            onChanged: (value) {
              onAscendingChanged(value);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'name': return AppStrings.sortByName;
      case 'date': return AppStrings.sortByDate;
      case 'size': return AppStrings.sortBySize;
      case 'type': return AppStrings.sortByType;
      default: return AppStrings.sortByName;
    }
  }
}
