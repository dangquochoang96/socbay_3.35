// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(path, _migrations, _callback);
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
          database,
          startVersion,
          endVersion,
          migrations,
        );

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER NOT NULL, `username` TEXT, `avatar` TEXT, `email` TEXT, `phone` TEXT, `address` TEXT, `password` TEXT, `type` TEXT, `otp` INTEGER, `birthday` TEXT, `status` INTEGER, `isAgency` INTEGER, `isAdmin` INTEGER, `sex` INTEGER, `point` INTEGER, `lat` REAL, `lng` REAL, `distance` REAL, `createdAt` TEXT, `certification` TEXT, `idCard` TEXT, `idCardImageFront` TEXT, `idCardImageBack` TEXT, `cmt` TEXT, PRIMARY KEY (`id`))',
        );

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database, changeListener),
      _userInsertionAdapter = InsertionAdapter(
        database,
        'User',
        (User item) => <String, Object?>{
          'id': item.id,
          'username': item.username,
          'avatar': item.avatar,
          'email': item.email,
          'phone': item.phone,
          'address': item.address,
          'password': item.password,
          'type': item.type,
          'otp': item.otp,
          'birthday': item.birthday,
          'status': item.status,
          'isAgency': item.isAgency,
          'isAdmin': item.isAdmin,
          'sex': item.sex,
          'point': item.point,
          'lat': item.lat,
          'lng': item.lng,
          'distance': item.distance,
          'createdAt': item.createdAt,
          'certification': item.certification,
          'cmt': item.cmt,
        },
        changeListener,
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  @override
  Future<List<User>> findAllUsers() async {
    return _queryAdapter.queryList(
      'SELECT * FROM User',
      mapper: (Map<String, Object?> row) => User(
        row['username'] as String?,
        row['avatar'] as String?,
        row['email'] as String?,
        row['phone'] as String?,
        row['address'] as String?,
        row['password'] as String?,
        row['type'] as String?,
        row['otp'] as int?,
        row['id'] as int,
        row['birthday'] as String?,
        row['status'] as int?,
        row['isAgency'] as int?,
        row['isAdmin'] as int?,
        row['sex'] as int?,
        row['point'] as int?,
        row['lat'] as double?,
        row['lng'] as double?,
        row['distance'] as double?,
        row['createdAt'] as String?,
        row['certification'] as String?,
        row['cmt'] as String?,
      ),
    );
  }

  @override
  Stream<List<String>> findAllUserName() {
    return _queryAdapter.queryListStream(
      'SELECT name FROM User',
      mapper: (Map<String, Object?> row) => row.values.first as String,
      queryableName: 'User',
      isView: false,
    );
  }

  @override
  Stream<User?> findUserById(int id) {
    return _queryAdapter.queryStream(
      'SELECT * FROM User WHERE id = ?1',
      mapper: (Map<String, Object?> row) => User(
        row['username'] as String?,
        row['avatar'] as String?,
        row['email'] as String?,
        row['phone'] as String?,
        row['address'] as String?,
        row['password'] as String?,
        row['type'] as String?,
        row['otp'] as int?,
        row['id'] as int,
        row['birthday'] as String?,
        row['status'] as int?,
        row['isAgency'] as int?,
        row['isAdmin'] as int?,
        row['sex'] as int?,
        row['point'] as int?,
        row['lat'] as double?,
        row['lng'] as double?,
        row['distance'] as double?,
        row['createdAt'] as String?,
        row['certification'] as String?,
        row['cmt'] as String?,
      ),
      arguments: [id],
      queryableName: 'User',
      isView: false,
    );
  }

  @override
  Future<void> deleteAllUser() async {
    await _queryAdapter.queryNoReturn('DELETE FROM User');
  }

  @override
  Future<int?> countAllUser() async {
    return _queryAdapter.query(
      'SELECT COUNT(*) FROM User',
      mapper: (Map<String, Object?> row) => row.values.first as int,
    );
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }
}
