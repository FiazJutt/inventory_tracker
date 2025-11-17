import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

/// Data Access Object for Room operations
class RoomDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insert(Map<String, dynamic> room) async {
    final db = await _dbHelper.database;
    await db.insert(
      'rooms',
      room,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.database;
    return await db.query('rooms', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.query('rooms', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getByLocation(String location) async {
    final db = await _dbHelper.database;
    return await db.query(
      'rooms',
      where: 'location = ?',
      whereArgs: [location],
      orderBy: 'name ASC',
    );
  }

  Future<void> update(Map<String, dynamic> room) async {
    final db = await _dbHelper.database;
    await db.update(
      'rooms',
      {'name': room['name'], 'location': room['location']},
      where: 'id = ?',
      whereArgs: [room['id']],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await _dbHelper.database;
    final searchTerm = '%$query%';
    return await db.query(
      'rooms',
      where: 'name LIKE ? OR location LIKE ?',
      whereArgs: [searchTerm, searchTerm],
      orderBy: 'name ASC',
    );
  }
}
