import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class TableDefinition {
  TableDefinition({
    this.name,
    this.structure,
    this.version = 1,
  }) {
    _init();
  }

  String name;
  String structure ;
  int version;

}

class TimeDataBase {
  TimeDataBase({
    this.version = 1,
    this.tableList,
  }){
    _init().then((databasesPath){path = join(databasesPath, "TimeMoment.db");});
  }

  String path;
  int version;
  List<TableDefinition> tableList;
  Database database;

  Future _init() async {
    return await getDatabasesPath();
  }

  Future openDataBase() async {
    database = await openDatabase(path, version: version,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE ${_tableDefinition.name} (${_tableDefinition.structure})');
      }
    );
  }

  Future deleteDataBase() async {
    await deleteDatabase(path);
  }

}

class DateServices {
  TableDefinition _definition = TableDefinition(
    name: 'PersonTable',
    structure: '''
      boxId integer primary key autoincrement, 
      name text not null,
      age integer not null)
    ''',
  );

}