import 'dart:async';

import 'package:floor/floor.dart';
import 'package:socbay/db/entity/users.dart';
import 'package:socbay/db/user_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [User])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
}
