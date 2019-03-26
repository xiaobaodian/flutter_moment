import 'package:flutter_moment/models/models.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class TableDefinition {
  TableDefinition({
    this.name,
    this.structure,
    this.version = 1,
  });

  String name;
  String structure ;
  int version;
}

class DataSource {
  DataSource({
    this.version = 1,
  }){
    initTable();
//    setPath().then((databasesPath){
//      _path = join(databasesPath, "TimeMoment.db");
//      print('database path : $_path');
//      //openDataBase();
//    });
  }

  String _path;
  int version;
  Map<String, TableDefinition> tables = Map<String, TableDefinition>();
  Database _database;

  String get path => _path;
  Database get database => _database;

  Future setPath() async {
    assert(tables.isNotEmpty);
    return await getDatabasesPath();
  }

  Future openDataBase() async {
    var p = await getDatabasesPath();
    _path = join(p, "TimeMoment.db");
    print('database path : $_path');
    _database = await openDatabase(_path, version: version,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE ${tables['PersonItem'].name} (${tables['PersonItem'].structure})');
      }
    );
  }

  Future deleteDataBase() async {
    await deleteDatabase(_path);
  }

  void initTable() {
    tables['PersonItem'] = TableDefinition(  //INTEGER PRIMARY KEY,
      name: 'PersonTable',
      structure: '''boxId integer primary key autoincrement,
       name TEXT, 
       photo TEXT,
       gender INTEGER, 
       birthday TEXT, 
       ref INTEGER'''
    );

    tables['PlaceItem'] = TableDefinition(
      name: 'PlaceTable',
      structure: '''
        boxId integer primary key autoincrement, 
        title text not null,
        address text,
        picture text,
        ref integer,
      ''',
    );
  }

}

class DateServices {


}