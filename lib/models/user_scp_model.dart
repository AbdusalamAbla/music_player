import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/service/local_data.dart';
import 'package:music_player/service/netease.dart';
import 'package:scoped_model/scoped_model.dart';


class UserAccount extends Model{

  static const persistenceKey='neteaseLoginUser';

  Map _user;

  Map get user=>_user;
   ///根据BuildContext获取 [UserAccount]
  static UserAccount of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of<UserAccount>(context,
        rebuildOnChange: rebuildOnChange);
  }
  UserAccount() {
    scheduleMicrotask(() async {
      final login = await myData[persistenceKey];
      if (login != null) {
        _user = login;
        // debugPrint('persistence user :${_user['account']['id']}');
        notifyListeners();
        //访问api，刷新登陆状态
        final state = await neteaseRepository.refreshLogin();
        if (!state) {
          _user = null;
          notifyListeners();
        }
      }
    });
  }

  bool get isLogin{
    return user!=null;
  }

  int get userId{
    if (!isLogin) {
      return null;
    }
    Map<String,Object> account=user['account'];
    return account['id'];
  }


   Future<Map> login(String phone, String password) async {
    final result = await neteaseRepository.login(phone, password);
    myData[persistenceKey] = result;
    _user = result;
    notifyListeners();
    return result;
  }

  void logout() {
    _user = null;
    notifyListeners();
    myData[persistenceKey] = null;
    neteaseRepository.logout();
  }
}