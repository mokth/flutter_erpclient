import 'dart:async';
import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import '../setting.dart';

class SettingBean  {
  SqfliteAdapter _adapter;

  final IntField id = new IntField('_id');
  final StrField url = new StrField('url');
  final StrField wh = new StrField('wh');

  String get tableName => 'settings';

  Future connectAdapter() async {
    if (this._adapter != null) {
      print("connect adataper....");
      try{
        await this._adapter.connect();
        print("adataper connected....");
      } catch (e){
        print(e.toString());
      }
    }
  }

  Future closeAdapter() async {
    if (this._adapter != null) {
      await this._adapter.close();
      _adapter = null;
      print("Connection close");
    }
  }

  Future<bool> getAdapter() async {
    try {
      String dbPath =await getDatabasesPath();  
      this._adapter = SqfliteAdapter(path.join(dbPath,"erpcli.db"));
      print('DatabasesPath '+path.join(dbPath,"erpcli.db"));    
    } catch (e) {
      print('open DatabasesPath error here');    
      print(e.toString());
      return false;
    }
    return true;
  }

  Future<Null> createTable() async {
    final st = new Create(tableName, ifNotExists: true)
        .addInt('_id', primary: true,autoIncrement: true)
        .addStr('url', isNullable: true)
        .addStr('wh', isNullable: true);
    try {
      await getAdapter();
      await this._adapter.connect();
      await this._adapter.createTable(st);
    } catch (e) {
      print(e.toString());
    }finally{
      await closeAdapter();
    }
  }

  Future insert(Setting setting) async {
    Insert inserter = new Insert(tableName);

    inserter.set(id, setting.id);
    inserter.set(url, setting.url);
    inserter.set(wh, setting.defwh);
    try {
      await getAdapter();
       await this._adapter.connect();
      await this._adapter.insert(inserter);
      print("setting inserted");
    } catch (e) {
      print(e.toString());
    } finally {
      await closeAdapter();
    }
  }

  /// Updates a sett
  Future update(int id, String url,String defWh) async {
    Update updater = new Update(tableName);
    updater.where(this.id.eq(id));

    updater.set(this.url, url);
    updater.set(this.wh, defWh);
    try {
      await getAdapter();
      await this._adapter.connect();
      await this._adapter.update(updater);
      print("setting updated");
    } catch (e) {
      print(e.toString());
    } finally {
      await closeAdapter();
    }
  }

  /// Finds one sett by [id]
  Future<Setting> findOne(int id) async {
    Setting sett = new Setting();
    try {
      await getAdapter();
       await this._adapter.connect();
      Find updater = new Find(tableName);
      updater.where(this.id.eq(id));
      Map map = await this._adapter.findOne(updater);
      sett.id = map['_id'];
      sett.url = map['url'];
      sett.defwh = map['wh'];
    } catch (e) {
      print(e.toString());
    } finally {
      await closeAdapter();
    }
    return sett;
  }

  /// Finds all setts
  Future<List<Setting>> findAll() async {
    List<Setting> setts = new List<Setting>();
    try {
      Find finder = new Find(tableName);
      await getAdapter();
      await this._adapter.connect();
      List<Map> maps = await (await this._adapter.find(finder)).toList();

      for (Map map in maps) {
        Setting sett = new Setting();

        sett.id = map['_id'];
        sett.url = map['url'];
        sett.defwh = map['wh'];
        setts.add(sett);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      await closeAdapter();
    }
    return setts;
  }

  /// Deletes a sett by [id]
  Future remove(int id) async {
    Remove deleter = new Remove(tableName);
    try{
      await getAdapter();
      await this._adapter.connect();
      deleter.where(this.id.eq(id));
     await this._adapter.remove(deleter);
    }catch (e) {
      print(e.toString());
    } finally {
      await closeAdapter();
    }
  }
}

