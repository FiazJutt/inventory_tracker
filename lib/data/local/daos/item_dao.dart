import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

/// Data Access Object for Item operations
class ItemDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insert(Map<String, dynamic> item) async {
    final db = await _dbHelper.database;
    await db.insert(
      'items',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.database;
    return await db.query('items', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getByRoomId(String roomId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'items',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getByContainerId(
    String roomId,
    String containerId,
  ) async {
    final db = await _dbHelper.database;
    return await db.query(
      'items',
      where: 'room_id = ? AND container_id = ?',
      whereArgs: [roomId, containerId],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getRoomItems(String roomId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'items',
      where: 'room_id = ? AND container_id IS NULL',
      whereArgs: [roomId],
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.query('items', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> update(Map<String, dynamic> item) async {
    final db = await _dbHelper.database;
    await db.update('items', item, where: 'id = ?', whereArgs: [item['id']]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> moveItem({
    required String itemId,
    required String newRoomId,
    String? newContainerId,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      'items',
      {'room_id': newRoomId, 'container_id': newContainerId},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await _dbHelper.database;
    final searchTerm = '%$query%';
    return await db.query(
      'items',
      where: '''
        name LIKE ? OR
        description LIKE ? OR
        brand LIKE ? OR
        model LIKE ? OR
        serial_number LIKE ? OR
        search_metadata LIKE ?
      ''',
      whereArgs: [
        searchTerm,
        searchTerm,
        searchTerm,
        searchTerm,
        searchTerm,
        searchTerm,
      ],
      orderBy: 'name ASC',
    );
  }
}
