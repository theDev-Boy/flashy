import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/file_service.dart';
import '../../models/local_file_item.dart';
import '../../widgets/file_browser/file_list_item.dart';
import '../../widgets/file_browser/empty_state_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  bool _isSearching = false;
  List<LocalFileItem> _localResults = [];
  String? _activeFilter;

  // Recent searches
  List<String> _recentSearches = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadRecentSearches() {
    // Load from shared preferences or memory
    setState(() {
      _recentSearches = [];
    });
  }

  void _saveRecentSearch(String query) {
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 8) {
        _recentSearches = _recentSearches.sublist(0, 8);
      }
    });
  }

  void _removeRecentSearch(String query) {
    setState(() {
      _recentSearches.remove(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: SizedBox(
          height: 48,
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search files...',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                        _localResults = [];
                      },
                    )
                  : null,
            ),
            onSubmitted: (value) => _performSearch(value),
            onChanged: (value) {
              setState(() => _query = value);
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (value.isNotEmpty) _performSearch(value);
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All', null),
                    const SizedBox(width: 8),
                    _filterChip('Images', 'image'),
                    const SizedBox(width: 8),
                    _filterChip('Videos', 'video'),
                    const SizedBox(width: 8),
                    _filterChip('Audio', 'audio'),
                    const SizedBox(width: 8),
                    _filterChip('Documents', 'document'),
                    const SizedBox(width: 8),
                    _filterChip('Archives', 'archive'),
                  ],
                ),
              ),
            ),

          // Recent searches (when query is empty)
          if (_query.isEmpty && _recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _recentSearches.clear()),
                    child: const Text('Clear all', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          if (_query.isEmpty && _recentSearches.isNotEmpty)
            ..._recentSearches.map((search) => ListTile(
              leading: const Icon(Icons.history, size: 20),
              title: Text(search, style: const TextStyle(fontSize: 14)),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => _removeRecentSearch(search),
              ),
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
            )),

          // Empty state for no query
          if (_query.isEmpty && _recentSearches.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search your files',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search across Flashy Disk and your device',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // No results
          if (_query.isNotEmpty && !_isSearching && _localResults.isEmpty)
            Expanded(
              child: EmptyStateWidget.noResults(),
            ),

          // Loading
          if (_isSearching)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),

          // Results
          if (!_isSearching && _localResults.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'On This Device (${_localResults.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _localResults.length,
                      itemBuilder: (context, index) {
                        final file = _localResults[index];
                        return FileListItem.fromLocalFile(
                          file,
                          onTap: () {
                            if (file.isDirectory) {
                              final encodedPath = Uri.encodeComponent(file.path);
                              context.push('/local/$encodedPath');
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? filter) {
    final isSelected = _activeFilter == filter;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _activeFilter = selected ? filter : null);
        if (_query.isNotEmpty) _performSearch(_query);
      },
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    _saveRecentSearch(query);

    final fileService = FileService();
    try {
      final results = await fileService.searchFiles(query, '/storage/emulated/0/');
      if (mounted) {
        setState(() {
          _localResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }
}
