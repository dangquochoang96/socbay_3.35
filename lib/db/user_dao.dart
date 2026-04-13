// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:socbay/db/entity/users.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM User')
  Future<List<User>> findAllUsers();

  @Query('SELECT name FROM User')
  Stream<List<String>> findAllUserName();

  @Query('SELECT * FROM User WHERE id = :id')
  Stream<User?> findUserById(int id);

  @insert
  Future<void> insertUser(User user);

  @Query('DELETE FROM User')
  Future<void> deleteAllUser();

  @Query('SELECT COUNT(*) FROM User')
  Future<int?> countAllUser();
}