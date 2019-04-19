import 'dart:async';

import 'data_base.dart';

import 'package:flutter/foundation.dart';
import 'package:music_player/model/model.dart';
import 'package:sembast/sembast.dart';

AppLocalData myData=AppLocalData._();
class AppLocalData {


//*  本地存放的data必须是可以放到store中的类型
  static Stream<T> withData<T>(String key, Future<T> netData,
      {void onNetError(dynamic e)}) async* {

        final data = myData[key];
        if (data != null) {
          final cached = await data;
          if (cached != null) {
            assert(cached is T, "local espect be $T, but is $cached");
            yield cached;
          }
        }
      try {

        final net = await netData;

        myData[key] = net;

        yield net;

      } catch (e) {
        if (onNetError != null) onNetError("$e");
        debugPrint(e);
    }
  }


  AppLocalData._();

  Store _store;

//* 得到store
  Future<Store> get store async {
    if(_store!=null){
      return _store;
    }
      final db=await getApplicationDatabase();
      _store=db.getStore('localdata');
    return _store;
  }

FutureOr operator [](key) async {
    return get(key);
  }

  void operator []=(key, value) {
    _put(value, key);
  }
  
  Future<T> get<T>(dynamic key) async {
    final result = await (await store).get(key);
    if (result is T) {
      return result;
    }
    return null;
  }

  Future _put(dynamic value, [dynamic key]) async {
    return (await store).put(value, key);
  }

  Future<List<LocalMusic>> getLocalMusiclist() async {
    final data = await get("localmusiclist");
    if (data == null) {
      return [];
    }
    final result = (data as List)
        .cast<Map>()
        .map((m) => LocalMusic.fromJson(m))
        .toList();
    return result;
  }

  void updateUserPlaylist(List<LocalMusic> list) {
    _put(list.map((p) => p.toJson()).toList(), "localmusiclist");
  }

}