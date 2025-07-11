import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fashion_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }
  
  Future<Database> initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'fashion_app.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
      );
    } catch (e) {
      print('Error initializing database: $e');
      // Jika terjadi error, coba buat database di lokasi alternatif
      String path = join(await getDatabasesPath(), 'fashion_app_alt.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
      );
    }
  }
  
  Future<void> _createDb(Database db, int version) async {
    try {
      print('Creating database tables...');
      await db.execute('''
        CREATE TABLE items(
          id TEXT PRIMARY KEY,
          name TEXT,
          brand TEXT,
          price REAL,
          imagePath TEXT,
          category TEXT,
          colors TEXT,
          sizes TEXT,
          description TEXT,
          stock INTEGER,
          isFavorite INTEGER
        )
      ''');
      
      await db.execute('''
        CREATE TABLE cart(
          id TEXT PRIMARY KEY,
          fashionItemId TEXT,
          name TEXT,
          brand TEXT,
          price REAL,
          imagePath TEXT,
          selectedColor TEXT,
          selectedSize TEXT,
          quantity INTEGER
        )
      ''');
    } catch (e) {
      print('Error creating database tables: $e');
    }
  }
  
  // CRUD Operations untuk items
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('items');
  }
  
  Future<Map<String, dynamic>?> getItem(String id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('items', item);
  }
  
  Future<int> updateItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.update(
      'items',
      item,
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }
  
  Future<int> deleteItem(String id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // CRUD Operations untuk cart
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.query('cart');
  }
  
  Future<int> insertCartItem(Map<String, dynamic> cartItem) async {
    final db = await database;
    return await db.insert('cart', cartItem);
  }
  
  Future<int> updateCartItem(Map<String, dynamic> cartItem) async {
    final db = await database;
    return await db.update(
      'cart',
      cartItem,
      where: 'id = ?',
      whereArgs: [cartItem['id']],
    );
  }
  
  Future<int> deleteCartItem(String id) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> clearCart() async {
    final db = await database;
    return await db.delete('cart');
  }
}