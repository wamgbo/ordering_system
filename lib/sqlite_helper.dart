import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!; //如果db不存在就_initDB
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    //傳送狀態的 異布
    String path = join(
      await getDatabasesPath(),
      'orders_cache.db',
    ); //創建order_cache.db

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute("""
              CREATE TABLE orders (
                id            TEXT PRIMARY KEY,
                customerName  TEXT,
                customerPhone TEXT,
                orderTime     TEXT,
                totalPrice    INTEGER,
                items         TEXT
              )
            """);
      },
    );
  }

  // 同步 Firebase 資料到 SQLite (Upsert 邏輯)
  static Future<void> syncOrder(String id, Map<String, dynamic> order) async {
    //firebase以map進來
    final db = await database;
    await db.insert(
      'orders',
      {
        'id': id,
        'customerName': order['customerName'] ?? '匿名',
        'customerPhone': order['customerPhone'] ?? '',
        'orderTime': order['orderTime'] ?? '',
        'totalPrice': order['totalPrice'] ?? 0,
        'items': order['items']?.toString() ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // 若 ID 存在則更新
    );
  }

  // 從本地讀取紀錄
  static Future<List<Map<String, dynamic>>> getLocalOrders() async {
    final db = await database;
    return await db.query('orders', orderBy: "orderTime DESC");
  }
}
