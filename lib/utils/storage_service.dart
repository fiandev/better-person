import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service for persistent storage of data to disk.
/// Uses JSON files stored in the app's document directory.
class StorageService {
  static const _dataKeys = [
    'users',
    'habits',
    'habit_completions',
    'tasks',
    'prayers',
    'focus_sessions',
    'quran_sessions',
    'kindness_logs',
    'kindness_acts',
    'spiritual_moments',
    'dzikir_entries',
    'custom_devotions',
    'badges',
    'growth_scores',
    'activity_summaries',
    'daily_consistency_records',
    'wallets',
    'transactions',
    'settings',
  ];
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  /// Get the app's document directory path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Get a file reference for a given key
  Future<File> _getFile(String key) async {
    final path = await _localPath;
    return File('$path/$key.json');
  }

  /// Save data to disk as JSON
  /// [key] - The storage key (filename without extension)
  /// [data] - List of items to serialize and save
  Future<void> save(String key, List<Map<String, dynamic>> data) async {
    try {
      final file = await _getFile(key);
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving data for key $key: $e');
      rethrow;
    }
  }

  /// Load data from disk
  /// [key] - The storage key (filename without extension)
  /// Returns a list of JSON objects, or empty list if file doesn't exist
  Future<List<Map<String, dynamic>>> load(String key) async {
    try {
      final file = await _getFile(key);

      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> decoded = jsonDecode(jsonString);

      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error loading data for key $key: $e');
      return [];
    }
  }

  /// Delete data file from disk
  /// [key] - The storage key (filename without extension)
  Future<bool> delete(String key) async {
    try {
      final file = await _getFile(key);

      if (await file.exists()) {
        await file.delete();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting data for key $key: $e');
      return false;
    }
  }

  /// Check if data exists for a key
  /// [key] - The storage key (filename without extension)
  Future<bool> exists(String key) async {
    try {
      final file = await _getFile(key);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking existence for key $key: $e');
      return false;
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);

      if (await directory.exists()) {
        await for (final entity in directory.list()) {
          if (entity is File && entity.path.endsWith('.json')) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    }
  }

  Future<String> exportBackup() async {
    final data = <String, List<Map<String, dynamic>>>{};
    for (final key in _dataKeys) {
      data[key] = await load(key);
    }
    return jsonEncode({
      'formatVersion': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  Future<void> importBackup(String content) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic> || decoded['formatVersion'] != 1) {
      throw const FormatException('Unsupported backup format.');
    }
    final source = decoded['data'];
    if (source is! Map<String, dynamic>) {
      throw const FormatException('Backup data is missing.');
    }

    final validated = <String, List<Map<String, dynamic>>>{};
    for (final key in _dataKeys) {
      final value = source[key];
      if (value is! List) {
        throw FormatException('Backup data for $key is invalid.');
      }
      final records = <Map<String, dynamic>>[];
      for (final record in value) {
        if (record is! Map<String, dynamic>) {
          throw FormatException('A $key record is invalid.');
        }
        records.add(record);
      }
      validated[key] = records;
    }

    for (final entry in validated.entries) {
      await save(entry.key, entry.value);
    }
  }
}
