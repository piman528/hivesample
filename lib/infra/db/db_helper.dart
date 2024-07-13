import 'dart:convert';

import 'package:hivesample/model/building.dart';
import 'package:hivesample/model/room.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

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
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'building_management.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE buildings(
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE rooms(
        roomId TEXT PRIMARY KEY,
        buildingId TEXT,
        floor TEXT,
        roomName TEXT,
        FOREIGN KEY (buildingId) REFERENCES buildings (id)
      )
    ''');
  }

  Future<bool> isTableExists(String tableName) async {
    final db = await database;
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]);

    return result.isNotEmpty;
  }

  Future<void> importFromJson(String jsonString) async {
    final db = await database;
    final batch = db.batch();
    final jsonData = json.decode(jsonString);

    for (var buildingJson in jsonData['buildings']) {
      final building = Building.fromJson(buildingJson);
      batch.insert('buildings', building.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (building.rooms != null) {
        building.rooms!.forEach((floor, rooms) {
          for (var room in rooms) {
            batch.insert(
                'rooms',
                {
                  'roomId': room.roomId,
                  'buildingId': building.id,
                  'floor': floor,
                  'roomName': room.roomName,
                },
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        });
      }
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getAllBuildingInfo() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT buildings.name as buildingName, rooms.floor, rooms.roomName
      FROM buildings
      JOIN rooms ON buildings.id = rooms.buildingId
      ORDER BY buildings.name, rooms.floor, rooms.roomName
    ''');
  }

  Future<List<Map<String, dynamic>>> searchBuilding(String searchWord) async {
    final db = await database;

    // 検索ワードを含む建物情報をクエリする
    return await db.rawQuery('''
      SELECT buildings.name as buildingName, buildings.id
      FROM buildings
      WHERE buildings.name LIKE '%$searchWord%'
      ORDER BY buildings.name
    ''');
  }

  Future<List<Map<String, dynamic>>> searchRoom(String searchWord) async {
    final db = await database;

    // 検索ワードを含む建物情報をクエリする
    return await db.rawQuery('''
      SELECT buildings.id, buildings.name as buildingName, rooms.floor, rooms.roomName, rooms.roomId
      FROM buildings
      JOIN rooms ON buildings.id = rooms.buildingId
      WHERE rooms.roomName LIKE '%$searchWord%'
      ORDER BY buildings.name, rooms.floor, rooms.roomName
    ''');
  }

  Future<Building?> getBuildingById(int id) async {
    final db = await database;

    // 建物の基本情報を取得
    final List<Map<String, dynamic>> buildingMaps = await db.query(
      'buildings',
      where: 'id = ?',
      whereArgs: [id.toString()], // SQLiteではIDを文字列として保存しているため
    );

    if (buildingMaps.isEmpty) {
      return null; // 指定されたIDの建物が見つからない場合
    }

    // 建物の部屋情報を取得
    final List<Map<String, dynamic>> roomMaps = await db.query(
      'rooms',
      where: 'buildingId = ?',
      whereArgs: [id.toString()],
    );

    // Building オブジェクトを作成するための JSON を準備
    final buildingJson = <String, List<Room>>{};

    // 部屋情報を JSON に追加
    for (var roomMap in roomMaps) {
      final floor = roomMap['floor'] as String;
      if (buildingJson[floor] == null) {
        buildingJson[floor] = [];
      }
      buildingJson[floor]!
          .add(Room(roomId: roomMap['roomId'], roomName: roomMap['roomName']));
    }

    // Building オブジェクトを作成して返す
    return Building(
        id: int.parse(buildingMaps.first['id']),
        name: buildingMaps.first['name'],
        rooms: buildingJson);
  }
}
