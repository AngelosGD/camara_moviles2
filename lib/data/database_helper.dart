import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/member.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'camara_moviles2.db';
  static const int _dbVersion = 1;
  static const String _table = 'miembros';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            apellidos TEXT NOT NULL,
            telefono TEXT,
            email TEXT,
            fotoPath TEXT,
            fechaRegistro TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertMember(Member member) async {
    final db = await database;
    final map = member.toMap()..remove('id');
    return db.insert(_table, map);
  }

  Future<List<Member>> searchMembers(String query) async {
    final db = await database;
    final maps = await db.query(
      _table,
      where: 'nombre LIKE ? OR apellidos LIKE ? OR (nombre || \' \' || apellidos) LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'nombre ASC',
    );
    return maps.map(Member.fromMap).toList();
  }

  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final maps = await db.query(_table, orderBy: 'nombre ASC');
    return maps.map(Member.fromMap).toList();
  }

  Future<int> updateMember(Member member) async {
    final db = await database;
    final map = member.toMap()..remove('id');
    return db.update(
      _table,
      map,
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
