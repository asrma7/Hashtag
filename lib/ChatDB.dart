import 'dart:async';
import 'package:hashtag/msg.dart';
import 'package:sqflite/sqflite.dart';

class ChatDB {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    String path = await getDatabasesPath() + "/chat.db";
    var theDb = await openDatabase(path, version: 1);
    return theDb;
  }

  Future<List> getchats() async {
    var dbClient = await db;
    List c = await dbClient
        .rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'");
    return c;
  }

  void addchat(name, message, time, type) async {
    var dbClient = await db;
    print(type);
    if (type == "recieved") {
      await dbClient.execute(
          "CREATE TABLE IF NOT EXISTS $name(user TEXT, message TEXT, time INTEGER)");
    }
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO $name(user, message, time) VALUES(\'' +
              name +
              '\'' +
              ',' +
              '\'' +
              message +
              '\'' +
              ',' +
              time.toString() +
              ')');
    });
  }

  Future<List<Messages>> getChats(user) async {
    var dbClient = await db;
    await dbClient.execute(
        "CREATE TABLE IF NOT EXISTS $user(user TEXT, message TEXT, time INTEGER)");
    List<Map> list = await dbClient.rawQuery('SELECT * FROM $user');
    List<Messages> messages = new List();
    for (int i = 0; i < list.length; i++) {
      messages.add(
        new Messages(
          author: list[i]["user"],
          text: list[i]["message"],
          time: list[i]["time"],
        ),
      );
    }
    return messages;
  }
}
