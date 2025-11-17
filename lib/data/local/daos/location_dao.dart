import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

/// Data Access Object for Location operations
class LocationDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insert(Map<String, dynamic> location) async {
    final db = await _dbHelper.database;
    await db.insert(
      'locations',
      location,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.database;
    return await db.query('locations', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getByName(String name) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'locations',
      where: 'name = ?',
      whereArgs: [name],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> update(String id, String name) async {
    final db = await _dbHelper.database;
    await db.update(
      'locations',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByName(String name) async {
    final db = await _dbHelper.database;
    await db.delete('locations', where: 'name = ?', whereArgs: [name]);
  }

  Future<bool> exists(String name) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      'SELECT COUNT(*) as count FROM locations WHERE name = ?',
      [name],
    );
    final countValue = results.first['count'];
    final count = countValue is int
        ? countValue
        : countValue is num
        ? countValue.toInt()
        : int.tryParse('$countValue') ?? 0;
    return count > 0;
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await _dbHelper.database;
    final searchTerm = '%$query%';
    return await db.query(
      'locations',
      where: 'name LIKE ?',
      whereArgs: [searchTerm],
      orderBy: 'name ASC',
    );
  }
}
