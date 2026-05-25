import 'package:socbay/data/model/local/account_db.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:sqflite/sqflite.dart';

import 'db_constants.dart';

class DbManager {
  String tag = 'DbManager';

  DbManager._privateConstructor() {
    //
  }

  static final DbManager _instance = DbManager._privateConstructor();

  static DbManager get instance => _instance;

  Database? db;

  Future<void> openDb() async {
    LoggerUtil.info('openDb', tag: tag);
    try {
      db ??= await openDatabase(
        'data.db',
        version: 1,
        onCreate: (Database db, int version) async {
          final batch = db.batch();
          _createV1Tables(batch);
          await batch.commit();
        },
        onUpgrade: (db, oldVersion, newVersion) async {},
      );
    } catch (ex) {
      LoggerUtil.error("OpenDb Error : $ex");
      db = null;
    }
  }

  void _createV1Tables(Batch batch) {
    LoggerUtil.info('Create table $tableUser');
    batch.execute('''
          create table $tableUser (
          $columnId TEXT NOT NULL,
          $columnUserName TEXT NOT NULL,
          $columnPassword TEXT NOT NULL,
          PRIMARY KEY ('$columnUserName')
          )
          ''');
  }

  Future<void> closeDb() async {
    LoggerUtil.info('closeDb', tag: tag);
    try {
      await db?.close();
    } catch (_) {}
    db = null;
  }

  Future<int> insertAccount({
    String? id,
    required String username,
    required String password,
  }) async {
    if(username.isEmpty||password.isEmpty){
      return 0;
    }
    await openDb();
    final Map<String, dynamic> data = <String, dynamic>{};
    data[columnId] = id;
    data[columnUserName] = username;
    data[columnPassword] = password;

    var result = 0;
    try {
      result = await db?.insert(tableUser, data) ?? 0;
    } catch (ex) {
      LoggerUtil.error("OpenDb InsertAccount Error : $ex");
    }
    LoggerUtil.info('insertAccount : $tableUser - result: $result', tag: tag);
    if(result ==0){
      await updatePassword(username: username, password: password);
    }
    await closeDb();
    return result;
  }

  Future<void> showTableAccounts() async {
    await openDb();
    try {
      List<Map<String, Object?>>? list = await db?.query(tableUser);
      LoggerUtil.info('SHOW TABLE ACCOUNTS $tableUser: $list', tag: tag);
    } catch (ex) {
      LoggerUtil.error("OpenDb ShowTableAccounts Error : $ex");
    }
    await closeDb();
  }

  Future<bool> updatePassword(
      {required String username, required String password}) async {
    await openDb();

    final Map<String, dynamic> data = {
      columnPassword: password,
    };
    const where = '$columnUserName = ?';
    int? result;
    try {
      result = await db
          ?.update(tableUser, data, where: where, whereArgs: [username]);
    } catch (ex) {
      LoggerUtil.error("OpenDb UpdatePassword Error : $ex");
    }
    await showTableAccounts();
    await closeDb();
    return result != null && result > 0;
  }

  Future<List<AccountDb>> getAccounts() async {
    await openDb();
    List<Map>? maps = [];
    try {
      maps = await db?.query(
        tableUser,
      );
      LoggerUtil.info("OpenDb GetAccounts Infor : $maps");
    } catch (ex) {
      LoggerUtil.error("OpenDb GetAccounts Error : $ex");
    }

    List<AccountDb> accounts = [];
    if (maps != null) {
      for (final item in maps) {
        final account = AccountDb.fromDbMap(item);
        accounts.add(account);
      }
    }
    await closeDb();
    return accounts;
  }

  Future<int> deleteUser(String username) async {
    await openDb();
    var result = 0;
    String query = 'DELETE FROM $tableUser WHERE $columnUserName=?';
    try {
      result = await db?.rawDelete(query, [username]) ?? 0;
    } catch (_) {}
    await closeDb();
    return result;
  }
}
