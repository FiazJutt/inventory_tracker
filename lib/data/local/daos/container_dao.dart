import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

/// Data Access Object for Container operations
class ContainerDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insert(Map<String, dynamic> container) async {
    final db = await _dbHelper.database;
    await db.insert(
      'containers',
      container,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.database;
    return await db.query('containers', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getByRoomId(String roomId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'containers',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'containers',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> update(Map<String, dynamic> container) async {
    final db = await _dbHelper.database;
    await db.update(
      'containers',
      container,
      where: 'id = ?',
      whereArgs: [container['id']],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('containers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await _dbHelper.database;
    final searchTerm = '%$query%';
    return await db.query(
      'containers',
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
