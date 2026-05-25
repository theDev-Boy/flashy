import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/drive_file.dart';
import '../models/upload_queue_item.dart';

class CacheService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'flashy_cache.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE drive_files (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            mime_type TEXT,
            parent_id TEXT,
            size INTEGER,
            modified_time TEXT,
            created_time TEXT,
            thumbnail_link TEXT,
            web_content_link TEXT,
            starred INTEGER DEFAULT 0,
            is_folder INTEGER DEFAULT 0,
            local_thumb_path TEXT,
            synced_at INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_parent ON drive_files(parent_id)');
        await db.execute('CREATE INDEX idx_name ON drive_files(name)');

        await db.execute('''
          CREATE TABLE favorites (
            path TEXT PRIMARY KEY,
            name TEXT,
            is_drive INTEGER DEFAULT 0,
            added_at INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE transfer_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_name TEXT,
            file_size INTEGER,
            direction TEXT,
            status TEXT,
            drive_file_id TEXT,
            local_path TEXT,
            started_at INTEGER,
            completed_at INTEGER,
            error_message TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE upload_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            local_path TEXT NOT NULL,
            dest_folder_id TEXT NOT NULL,
            file_name TEXT,
            file_size INTEGER,
            status TEXT DEFAULT 'pending',
            created_at INTEGER,
            retry_count INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE recent_searches (
            query TEXT PRIMARY KEY,
            searched_at INTEGER
          )
        ''');
      },
    );
  }

  // Drive Files Cache
  Future<void> cacheDriveFiles(List<DriveFile> files) async {
    final db = await database;
    final batch = db.batch();

    for (var file in files) {
      batch.insert('drive_files', file.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<List<DriveFile>> getCachedDriveFiles(String parentId) async {
    final db = await database;
    final results = await db.query(
      'drive_files',
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
    return results.map((json) => DriveFile.fromJson(json)).toList();
  }

  Future<void> clearDriveCache() async {
    final db = await database;
    await db.delete('drive_files');
  }

  // Upload Queue
  Future<int> addToUploadQueue(UploadQueueItem item) async {
    final db = await database;
    return db.insert('upload_queue', item.toJson());
  }

  Future<List<UploadQueueItem>> getPendingUploads() async {
    final db = await database;
    final results = await db.query(
      'upload_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
    return results.map((json) => UploadQueueItem.fromJson(json)).toList();
  }

  Future<void> updateUploadQueueStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'upload_queue',
      {'status': status, 'retry_count': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetryCount(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE upload_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<void> removeFromQueue(int id) async {
    final db = await database;
    await db.delete('upload_queue', where: 'id = ?', whereArgs: [id]);
  }

  // Search History
  Future<void> addRecentSearch(String query) async {
    final db = await database;
    await db.insert(
      'recent_searches',
      {'query': query, 'searched_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getRecentSearches() async {
    final db = await database;
    final results = await db.query(
      'recent_searches',
      orderBy: 'searched_at DESC',
      limit: 8,
    );
    return results.map((r) => r['query'] as String).toList();
  }

  Future<void> clearRecentSearches() async {
    final db = await database;
    await db.delete('recent_searches');
  }

  Future<void> removeRecentSearch(String query) async {
    final db = await database;
    await db.delete('recent_searches', where: 'query = ?', whereArgs: [query]);
  }

  // Settings
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
