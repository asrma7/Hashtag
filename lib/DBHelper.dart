import 'dart:async';
import 'package:hashtag/Posts.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    String path = await getDatabasesPath() + "/hashtag.db";
    var theDb = await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  // Creating a table name Employee with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE Post(id INTEGER, user TEXT, usericon TEXT, postimage TEXT, tags TEXT, caption TEXT, like TEXT, likecount INTEGER, time TEXT )");
    print("Created tables");
    await db.execute(
        "CREATE TABLE User(username TEXT, fullname TEXT, email TEXT, session TEXT)");
    print("Created tables");
  }

  void _onUpgrade(Database db, int oldversion, int newversion) {
    // When creating the db, create the table
    db.execute("DROP TABLE Post");
    db.execute("DROP TABLE User");
    _onCreate(db, newversion);
    print("Upgraded tables");
  }

  // Retrieving employees from Employee Tables
  Future<List<Posts>> getPosts() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Post');
    List<Posts> posts = new List();
    for (int i = 0; i < list.length; i++) {
      posts.add(new Posts(
          id: list[i]["id"].toString(),
          user: list[i]["user"],
          usericon: list[i]["usericon"],
          tags: list[i]["tags"],
          postimage: list[i]["postimage"],
          caption: list[i]["caption"],
          like: list[i]["like"] == 'true',
          likecount: list[i]["likecount"],
          time: list[i]["time"]));
    }
    return posts;
  }

  void deletePosts() async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawDelete('DELETE FROM Post');
    });
  }

  void logout() async {
    deletePosts();
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawDelete('DELETE FROM User');
    });
  }

  void savePosts(List posts) async {
    deletePosts();
    var dbClient = await db;
    for (int i = 0; i < posts.length; i++) {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO Post(id, user, usericon, postimage, tags, caption, like, likecount, time) VALUES(' +
                posts[i].id.toString() +
                ',' +
                '\'' +
                posts[i].user +
                '\'' +
                ',' +
                '\'' +
                posts[i].usericon +
                '\'' +
                ',' +
                '\'' +
                posts[i].postimage +
                '\'' +
                ',' +
                '\'' +
                posts[i].tags +
                '\'' +
                ',' +
                '\'' +
                posts[i].caption +
                '\'' +
                ',' +
                '\'' +
                posts[i].like.toString() +
                '\'' +
                ',' +
                posts[i].likecount.toString() +
                ',' +
                '\'' +
                posts[i].time +
                '\'' +
                ')');
      });
    }
  }

  void login(
      String userid, String fullname, String email, String session) async {
    logout();
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO User(username, fullname, email, session) VALUES(' +
              '\'' +
              userid +
              '\'' +
              ',' +
              '\'' +
              fullname +
              '\'' +
              ',' +
              '\'' +
              email +
              '\'' +
              ',' +
              '\'' +
              session +
              '\'' +
              ')');
    });
  }

  Future<int> postCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM Post'));
  }

  Future<int> updatePost(Posts posts) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'UPDATE Post SET likecount = \'${posts.likecount}\', like = \'${posts.like}\' WHERE id = ${posts.id}');
  }

  Future<String> getSession() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT session FROM User');
    return list[0]['session'];
  }

  Future<bool> islogin() async {
    var dbClient = await db;
    int i = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM User'));
    if (i > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> getUsername() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT username FROM User');
    return list[0]['username'];
  }
}
