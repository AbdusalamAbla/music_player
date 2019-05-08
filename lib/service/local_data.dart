import 'dart:async';

import 'data_base.dart';
import 'package:music_player/models/model.dart';
import 'package:flutter/foundation.dart';

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
  //*  获得本地歌曲列表
  Future<List<Music>> getLocalMusicList() async {
    final data = await get("localmusiclist");
    if (data == null) {
      return [];
    }
    final result = (data as List)
        .cast<Map>()
        .map((m) => Music.fromMap(m))
        .toList();
    return result;
  }

  //* 更新本地歌曲列表
  void updateLocalMusicList(List<Music> list) {
    _put(list.map((p) => p.toMap()).toList(), "localmusiclist");
  }
  //*  获得用户网络歌单
  Future<List<PlaylistDetail>> getUserNetMusicList(int userId) async {
    final data = await get("user_playlist_$userId");
    if (data == null) {
      return null;
    }
    final result = (data as List)
        .cast<Map>()
        .map((m) => PlaylistDetail.fromMap(m))
        .toList();
    return result;
  }
  //* 存储(更新)用户网络歌单
  void updateUserNetMusicList(int userId,List<PlaylistDetail> list){
       _put(list.map((p) => p.toMap()).toList(), "user_playlist_$userId");
  }
  //*  存储歌单
  Future updatePlaylistDetail(PlaylistDetail playlistDetail) {
    // assert(playlistDetail.loaded);
    return _put(playlistDetail.toMap(), 'playlist_detail_${playlistDetail.id}');
  }
//* 获得用户网络歌单内容
  Future<PlaylistDetail> getPlaylistDetail(int playlistId) async {
    final data = await get("playlist_detail_$playlistId");
    return PlaylistDetail.fromMap(data);
  }

}