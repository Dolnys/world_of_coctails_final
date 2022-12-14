// import 'dart:async';

// import 'package:flutter/foundation.dart';

// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
// import 'package:world_of_coctails_final/extensions/filter.dart';

// import 'crud_exeptions.dart';

// class CoctailsService {
//   Database? _db;

//   List<DatabaseCoctail> _coctails = [];

//   DatabaseUser? _user;

//   static final CoctailsService _shared = CoctailsService._sharedInstance();
//   CoctailsService._sharedInstance() {
//     _coctailsStreamController =
//         StreamController<List<DatabaseCoctail>>.broadcast(
//       onListen: () {
//         _coctailsStreamController.sink.add(_coctails);
//       },
//     );
//   }
//   factory CoctailsService() => _shared;

//   late final StreamController<List<DatabaseCoctail>> _coctailsStreamController;

//   Stream<List<DatabaseCoctail>> get allCoctails =>
//       _coctailsStreamController.stream.filter((coctail) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return coctail.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllCoctails();
//         }
//       });

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheCoctails() async {
//     final allCoctails = await getAllCoctails();
//     _coctails = allCoctails.toList();
//     _coctailsStreamController.add(_coctails);
//   }

//   Future<DatabaseCoctail> updateCoctail({
//     required DatabaseCoctail coctail,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
// // make sure coctail exists
//     await getCoctail(id: coctail.id);
//     // uptade DB

//     final updatesCount = await db.update(
//       coctailTable,
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: 'id = ?',
//       whereArgs: [coctail.id],
//     );

//     if (updatesCount == 0) {
//       throw CouldNotUpdateCoctail();
//     } else {
//       final updatedCoctail = await getCoctail(id: coctail.id);
//       _coctails.removeWhere((coctails) => coctail.id == updatedCoctail.id);
//       _coctails.add(updatedCoctail);
//       _coctailsStreamController.add(_coctails);
//       return updatedCoctail;
//     }
//   }

//   Future<Iterable<DatabaseCoctail>> getAllCoctails() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final coctails = await db.query(coctailTable);

//     return coctails.map((coctailRow) => DatabaseCoctail.fromRow(coctailRow));
//   }

//   Future<DatabaseCoctail> getCoctail({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final coctails = await db.query(
//       coctailTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (coctails.isEmpty) {
//       throw CouldNotFindCoctail();
//     } else {
//       final coctail = DatabaseCoctail.fromRow(coctails.first);
//       _coctails.removeWhere((coctail) => coctail.id == id);
//       _coctails.add(coctail);
//       _coctailsStreamController.add(_coctails);
//       return coctail;
//     }
//   }

//   Future<int> deleteAllCoctails() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(coctailTable);
//     _coctails = [];
//     _coctailsStreamController.add(_coctails);
//     return numberOfDeletions;
//   }

//   Future<void> deleteCoctail({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       coctailTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeleteCoctail();
//     } else {
//       _coctails.removeWhere((coctail) => coctail.id == id);
//       _coctailsStreamController.add(_coctails);
//     }
//   }

//   Future<DatabaseCoctail> createCoctail({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     // make sure owner exists in the database with the correct id
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUser();
//     }

//     const text = '';
//     // create the coctail
//     final coctailId = await db.insert(coctailTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final coctail = DatabaseCoctail(
//       id: coctailId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     _coctails.add(coctail);
//     _coctailsStreamController.add(_coctails);

//     return coctail;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }

//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(
//       id: userId,
//       email: email,
//     );
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //empty
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       // create the user table
//       await db.execute(createUserTable);
//       // create coctail table
//       await db.execute(createCoctailTable);
//       await _cacheCoctails();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, ID = $id, email = $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseCoctail {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseCoctail({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseCoctail.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Coctail, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

//   @override
//   bool operator ==(covariant DatabaseCoctail other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = 'coctail.db';
// const coctailTable = 'coctail';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//         "id"	INTEGER NOT NULL,
//         "email"	TEXT NOT NULL UNIQUE,
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
// const createCoctailTable = '''CREATE TABLE IF NOT EXISTS "coctail" (
//         "id"	INTEGER NOT NULL,
//         "user_id"	INTEGER NOT NULL,
//         "text"	TEXT,
//         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY("user_id") REFERENCES "user"("id"),
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
