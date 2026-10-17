import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persists profile avatar images inside the app documents directory.
///
/// Picked images are copied into local storage so the avatar survives app
/// restarts and the picker's temporary file being cleaned up.
class AvatarStorageService {
  AvatarStorageService._();

  static const String _folderName = 'avatars';
  static const String _filePrefix = 'avatar_';

  static Future<Directory> _directory() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory('${documents.path}/$_folderName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Copies [source] into local storage for [userId] and returns the new path.
  ///
  /// Any avatar previously stored for [userId] is removed first, so at most one
  /// image is kept per profile.
  static Future<String> save({
    required String userId,
    required File source,
  }) async {
    await removeForUser(userId);
    final directory = await _directory();
    final name =
        '$_filePrefix${userId}_${DateTime.now().millisecondsSinceEpoch}'
        '${_extensionOf(source.path)}';
    final stored = await source.copy('${directory.path}/$name');
    return stored.path;
  }

  /// Deletes the avatar stored at [path], ignoring missing files.
  static Future<void> remove(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (error) {
      debugPrint('Could not delete avatar at $path: $error');
    }
  }

  /// Deletes every stored avatar belonging to [userId].
  static Future<void> removeForUser(String userId) async {
    try {
      final directory = await _directory();
      await for (final entity in directory.list()) {
        if (entity is File && _belongsTo(entity.path, userId)) {
          await entity.delete();
        }
      }
    } catch (error) {
      debugPrint('Could not clear avatars for $userId: $error');
    }
  }

  static bool _belongsTo(String path, String userId) =>
      path.split(Platform.pathSeparator).last.startsWith('$_filePrefix$userId');

  static String _extensionOf(String path) {
    final separator = path.lastIndexOf(Platform.pathSeparator);
    final dot = path.lastIndexOf('.');
    if (dot <= separator || dot == path.length - 1) return '.jpg';
    return path.substring(dot);
  }
}
