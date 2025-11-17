import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper class for managing SQLite database
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create locations table
    await db.execute('''
      CREATE TABLE locations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create rooms table
    await db.execute('''
      CREATE TABLE rooms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (location) REFERENCES locations(name) ON DELETE CASCADE
      )
    ''');

    // Create containers table
    await db.execute('''
      CREATE TABLE containers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        room_id TEXT NOT NULL,
        serial_number TEXT,
        notes TEXT,
        description TEXT,
        purchase_price REAL,
        purchase_date INTEGER,
        current_value REAL,
        current_condition TEXT,
        expiration_date INTEGER,
        weight REAL,
        retailer TEXT,
        brand TEXT,
        model TEXT,
        search_metadata TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');

    // Create items table
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        room_id TEXT NOT NULL,
        container_id TEXT,
        quantity INTEGER NOT NULL DEFAULT 1,
        serial_number TEXT,
        notes TEXT,
        description TEXT,
        purchase_price REAL,
        purchase_date INTEGER,
        current_value REAL,
        current_condition TEXT,
        expiration_date INTEGER,
        weight REAL,
        retailer TEXT,
        brand TEXT,
        model TEXT,
        search_metadata TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
        FOREIGN KEY (container_id) REFERENCES containers(id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_rooms_location ON rooms(location)');
    await db.execute('CREATE INDEX idx_containers_room_id ON containers(room_id)');
    await db.execute('CREATE INDEX idx_items_room_id ON items(room_id)');
    await db.execute('CREATE INDEX idx_items_container_id ON items(container_id)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

