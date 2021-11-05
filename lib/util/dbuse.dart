import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tp5_3/models/list_etudiants.dart';
import 'package:tp5_3/models/scol_list.dart';

class dbuse {
  final int version = 1;
  Database db;
  static final dbuse _dbHelper = dbuse._internal();
  dbuse._internal();
  factory dbuse() {
    return _dbHelper;
  }
  Future<Database> openDb() async {
    if (db == null) {
      db = await openDatabase(join(await getDatabasesPath(), 'scol.db'),
          onCreate: (database, version) {
        database.execute(
            'CREATE TABLE classes(codClass INTEGER PRIMARY KEY, nomClass TEXT, nbreEtud INTEGER)');
        database.execute(
            'CREATE TABLE etudiants(id INTEGER PRIMARY KEY, codClass INTEGER,nom TEXT, prenom TEXT, datNais TEXT, ' +
                'FOREIGN KEY(codClass) REFERENCES classes(codClass))');
      }, version: version);
    }
    return db;
  }

  Future<int> insertClass(ScolList list) async {
    int codClass = await this.db.insert(
          'classes',
          list.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
    return codClass;
  }

  Future<int> insertEtudiants(ListEtudiants etud) async {
    int id = await db.insert(
      'etudiants',
      etud.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> deleteStudent(ListEtudiants student) async {
    int result =
        await db.delete("etudiants", where: "id = ?", whereArgs: [student.id]);
    return result;
  }

  Future<int> deleteList(ScolList list) async {
    int result =
        await db.delete("classes", where: "id = ?", whereArgs: [list.codClass]);
    return result;
  }

  Future<List<ScolList>> getClasses() async {
    final List<Map<String, dynamic>> maps = await db.query('classes');
    return List.generate(maps.length, (i) {
      return ScolList(
        maps[i]['codClass'],
        maps[i]['nomClass'],
        maps[i]['nbreEtud'],
      );
    });
  }

  Future<List<ListEtudiants>> getEtudiants(code) async {
    final List<Map<String, dynamic>> maps =
        await db.query('etudiants', where: 'codClass = ?', whereArgs: [code]);
    return List.generate(maps.length, (i) {
      return ListEtudiants(
        maps[i]['id'],
        maps[i]['codClass'],
        maps[i]['nom'],
        maps[i]['prenom'],
        maps[i]['datNais'],
      );
    });
  }

  Future testDb() async {
    db = await openDb();
    await db.execute('INSERT INTO classes VALUES (0, "DSI33", 28)');
    await db.execute(
        'INSERT INTO etudiants VALUES (0, 0, "Mriri", "Wassim", "28/04/2000")');
    List etudiants = await db.rawQuery('select * from etudiants');
    List classes = await db.rawQuery('select * from classes');
    print(etudiants[0].toString());
    print(classes[0].toString());
  }
}
