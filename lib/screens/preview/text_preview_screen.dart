import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/file_utils.dart';

class TextPreviewScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const TextPreviewScreen({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<TextPreviewScreen> createState() => _TextPreviewScreenState();
}

class _TextPreviewScreenState extends State<TextPreviewScreen> {
  String _content = '';
  bool _isLoading = true;
  bool _showLineNumbers = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final file = File(widget.filePath);
      final content = await file.readAsString();
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Error loading file: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine language for highlighting
    final language = _detectLanguage(widget.fileName);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: Icon(_showLineNumbers ? Icons.code_off : Icons.code),
            onPressed: () => setState(() => _showLineNumbers = !_showLineNumbers),
            tooltip: 'Toggle line numbers',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _content.isNotEmpty ? _copyContent : null,
            tooltip: 'Copy all',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _content.isNotEmpty ? () => _shareFile() : null,
            tooltip: 'Share',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(language, isDark),
    );
  }

  Widget _buildContent(String? language, bool isDark) {
    if (language != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: HighlightView(
          _content,
          language: language,
          theme: isDark ? draculaTheme : githubTheme,
          padding: const EdgeInsets.all(12),
          textStyle: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.5,
          ),
        ),
      );
    }

    // Fallback for plain text files
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _content,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  String? _detectLanguage(String fileName) {
    final ext = FileUtils.getFileExtension(fileName).toLowerCase();
    switch (ext) {
      case '.dart':
        return 'dart';
      case '.py':
        return 'python';
      case '.js':
      case '.jsx':
      case '.mjs':
        return 'javascript';
      case '.ts':
      case '.tsx':
        return 'typescript';
      case '.java':
        return 'java';
      case '.kt':
      case '.kts':
        return 'kotlin';
      case '.swift':
        return 'swift';
      case '.cpp':
      case '.cc':
      case '.cxx':
      case '.c':
      case '.h':
      case '.hpp':
        return 'cpp';
      case '.html':
      case '.htm':
        return 'xml';
      case '.css':
      case '.scss':
      case '.less':
        return 'css';
      case '.json':
        return 'json';
      case '.xml':
      case '.svg':
      case '.plist':
        return 'xml';
      case '.yaml':
      case '.yml':
        return 'yaml';
      case '.md':
      case '.markdown':
        return 'markdown';
      case '.sh':
      case '.bash':
      case '.zsh':
        return 'bash';
      case '.rb':
        return 'ruby';
      case '.go':
        return 'go';
      case '.rs':
        return 'rust';
      case '.php':
        return 'php';
      case '.sql':
        return 'sql';
      default:
        // Only return null for text files that have no code highlighting
        return null;
    }
  }

  Future<void> _copyContent() async {
    await Clipboard.setData(ClipboardData(text: _content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareFile() async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(widget.filePath)], text: widget.fileName),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share file')),
      );
    }
  }
}
