import 'package:socbay/db/db_constants.dart';

class AccountDb {
  String id = '';
  String username = '';
  String password = '';

  AccountDb({
    required this.username,
    required this.password,
  });

  AccountDb.fromDbMap(Map map) {
    id = map[columnId];
    username = map[columnUserName];
    password = map[columnPassword];
  }
}
