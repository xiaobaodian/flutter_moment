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
    _getPath().then((databasesPath){
      _path = join(databasesPath, "TimeMoment.db");
      openDataBase();
    });
  }

  String _path;
  int version;
  Map<String, TableDefinition> tables = Map<String, TableDefinition>();
  Database _database;

  String get path => _path;
  Database get database => _database;

  Future _getPath() async {
    assert(tables.isNotEmpty);
    return await getDatabasesPath();
  }

  Future openDataBase() async {
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
    tables['PersonItem'] = TableDefinition(
      name: 'PersonTable',
      structure: '''boxId INTEGER PRIMARY KEY,
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
        references integer,
      ''',
    );
  }

}

class DateServices {


}