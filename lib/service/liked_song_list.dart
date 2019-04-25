import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_player/models/model.dart';
import 'package:music_player/service/netease.dart';
import 'package:music_player/models/user_scp_model.dart';
import 'package:scoped_model/scoped_model.dart';

class LikedSongList extends Model {
  LikedSongList(UserAccount account) {
    int userId = 0;
    account.addListener(() {
      if (account.isLogin && account.userId != userId) {
        userId = account.userId;
        _loadUserLikedList(userId);
      } else if (!account.isLogin) {
        userId = 0;
        _ids = const [];
        notifyListeners();
      }
    });
  }

  void _loadUserLikedList(int userId) async {
    _ids =
        (await myData['likedSongList'] as List)?.cast() ?? const [];
    notifyListeners();
    try {
      _ids = await neteaseRepository.likedList(userId);
      notifyListeners();
      myData['likedSongList'] = _ids;
    } catch (e) {
      debugPrint("$e");
    }
  }

  List<int> _ids = const [];

  List<int> get ids => _ids;

  static LikedSongList of(BuildContext context,
      {bool rebuildOnChange = false}) {
    return ScopedModel.of<LikedSongList>(context,
        rebuildOnChange: rebuildOnChange);
  }

  static bool contain(BuildContext context, NetMusic music) {
    final list = ScopedModel.of<LikedSongList>(context, rebuildOnChange: true);
    return list.ids?.contains(music.id) == true;
  }

  ///红心歌曲
  Future<void> likeMusic(NetMusic music) async {
    final succeed = await neteaseRepository.like(music.id, true);
    if (succeed) {
      _ids = List.from(_ids)..add(music.id);
      notifyListeners();
    }
  }

  ///取消红心歌曲
  Future<void> dislikeMusic(NetMusic music) async {
    final succeed = await neteaseRepository.like(music.id, false);
    if (succeed) {
      _ids = List.from(_ids)..remove(music.id);
      notifyListeners();
    }
  }
}
