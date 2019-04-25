import 'package:flutter/material.dart';

import 'package:music_player/models/user_scp_model.dart';
import 'package:music_player/service/netease.dart';
import '../service/counter.dart';
import '../service/liked_song_list.dart';

import 'package:scoped_model/scoped_model.dart';
class ModelManager extends StatefulWidget {
  final Widget child;

  const ModelManager({Key key, @required this.child}) : super(key: key);

  @override
  ModelManagerState createState() => ModelManagerState();

  static ModelManagerState of(BuildContext context) {
    return context.ancestorStateOfType(TypeMatcher<ModelManagerState>());
  }
}

class ModelManagerState extends State<ModelManager> {
  final UserAccount account = UserAccount();

  Counter counter;

  @override
  void initState() {
    super.initState();
    counter = Counter(account, neteaseRepository, myData);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserAccount>(
      model: account,
      child: ScopedModel<LikedSongList>(
        model: LikedSongList(account),
        child: ScopedModel<Counter>(
          model: counter,
          child: widget.child,
        ),
      ),
    );
  }
}
