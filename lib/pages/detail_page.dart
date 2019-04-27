

import 'package:flutter/material.dart';
import 'package:music_player/models/models.dart';
import 'package:music_player/utils/loader.dart';
import 'package:music_player/service/local_data.dart';
import 'package:music_player/service/netease.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:music_player/service/netease_image.dart';
class ListDetail extends StatefulWidget {
 ListDetail({Key key,this.playlistId,this.playlist}) : super(key: key);
  ///playlist id，can not be null
  final int playlistId;

  ///a simple playlist json obj , can be null
  ///used to preview playlist information when loading
  final PlaylistDetail playlist;
  _ListDetailState createState() => _ListDetailState(playlist: playlist,playlistId: playlistId);
}

class _ListDetailState extends State<ListDetail> {


  _ListDetailState({this.playlistId,this.playlist});
   final int playlistId;

  ///a simple playlist json obj , can be null
  ///used to preview playlist information when loading
  final PlaylistDetail playlist;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
      ),
     body: _ListBody(playlist)
    );
  }


  Widget buildPreview(BuildContext context, ) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            widget.playlist == null
                ? null
                : _PlaylistDetailHeader(widget.playlist),
           
          ]..removeWhere((v) => v == null),
        ),
        Column(
          children: <Widget>[
            OpacityTitle(
              name: null,
              defaultName: "歌单",
              appBarOpacity: ValueNotifier(0),
            )
          ],
        )
      ],
    );
  }
}




class _ListBody extends StatefulWidget {

  _ListBody(this.playlist) : assert(playlist != null);

  final PlaylistDetail playlist;

   List<NetMusic> get musicList => playlist.musicList;

  _ListBodyState createState() => _ListBodyState(playlist);
}

class _ListBodyState extends State<_ListBody> {
  final PlaylistDetail playlist;
    ScrollController controller = ScrollController();
  _ListBodyState(this.playlist);
  @override
  Widget build(BuildContext context) {
    return Loader(
            initialData: myData.getPlaylistDetail(playlist.id),
            loadTask: () => neteaseRepository.playlistDetail(playlist.id),
            resultVerify: simpleLoaderResultVerify((v) => v != null),
            loadingBuilder: (context) {
            
              return Container();
            },
            failedWidgetBuilder: (context, result, msg) {
              return ListView(children: [
                Container(
                  child: Center(child: Text('failed'),),
                ),
                Loader.buildSimpleFailedWidget(context, result, msg),
              ]);
            },
            builder: (context, result) {
              final PlaylistDetail playlist=result;
              List<NetMusic> musicList=playlist.musicList;
              return ListView.builder(
                controller: controller,
                itemExtent: 80,
                itemCount: musicList.length!=0?musicList.length:1,
                itemBuilder: (BuildContext context,int index){
                              return Column(
                                      children: <Widget>[
                                        ListTile(
                                          onTap: (){
                                            print('you pressed ${musicList[index].title}');
                                          },
                                          title: Row(
                                                  children: <Widget>[
                                                      Expanded(child: Text(  '${musicList[index].title}'  )),
                                                      
                                                  ],
                                           ),
                                          subtitle:  Text( '${musicList[index].artist[0].name}',
                                                              style: TextStyle(fontSize: 12.0),),
                                           trailing:  null ,
                                         ),
                                       Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                                      child: Divider(height: 1.0,),
                             )
                          ],
                        );
                       }
              );
            });
  }
}

class OpacityTitle extends StatefulWidget {
  OpacityTitle(
      {@required this.name,
      @required this.appBarOpacity,
      @required this.defaultName,
      this.actions})
      : assert(defaultName != null);

  ///title background opacity value notifier, from 0 - 1;
  final ValueNotifier<double> appBarOpacity;

  ///the name of playlist
  final String name;

  final String defaultName;

  final List<Widget> actions;

  @override
  State<StatefulWidget> createState() => OpacityTitleState();
}

class OpacityTitleState extends State<OpacityTitle> {
  double appBarOpacityValue = 0;

  @override
  void initState() {
    super.initState();
    widget.appBarOpacity?.addListener(_onAppBarOpacity);
  }

  void _onAppBarOpacity() {
    setState(() {
      appBarOpacityValue = widget.appBarOpacity.value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.appBarOpacity?.removeListener(_onAppBarOpacity);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      title: Text(appBarOpacityValue < 0.5
          ? widget.defaultName
          : (widget.name ?? widget.defaultName)),
      toolbarOpacity: 1,
      backgroundColor:
          Theme.of(context).primaryColor,
      actions: widget.actions,
    );
  }
}

class _HeaderAction extends StatelessWidget {
  _HeaderAction(this.icon, this.action, this.onTap);

  final IconData icon;

  final String action;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).primaryTextTheme;

    return InkResponse(
      onTap: onTap,
      splashColor: textTheme.body1.color,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: textTheme.body1.color,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 2),
          ),
          Text(
            action,
            style: textTheme.caption,
          )
        ],
      ),
    );
  }
}

class DetailHeader extends StatelessWidget {
  const DetailHeader(
      {Key key,
      @required this.content,
      this.onCommentTap,
      this.onShareTap,
      this.onSelectionTap,
      int commentCount = 0,
      int shareCount = 0})
      : this.commentCount = commentCount ?? 0,
        this.shareCount = shareCount ?? 0,
        super(key: key);

  final Widget content;

  final GestureTapCallback onCommentTap;
  final GestureTapCallback onShareTap;
  final GestureTapCallback onSelectionTap;

  final int commentCount;
  final int shareCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // PlayListHeaderBackground(),
        Material(
          color: Colors.black.withOpacity(0.5),
          child: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight),
            child: Column(
              children: <Widget>[
                content,
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _HeaderAction(
                          Icons.comment,
                          commentCount > 0 ? commentCount.toString() : "评论",
                          onCommentTap),
                      _HeaderAction(
                          Icons.share,
                          shareCount > 0 ? shareCount.toString() : "分享",
                          onShareTap),
                      _HeaderAction(Icons.check_box, "多选", onSelectionTap),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistDetailHeader extends StatelessWidget {
  _PlaylistDetailHeader(this.playlist) : assert(playlist != null);

  final PlaylistDetail playlist;

  ///the music list
  ///could be null if music list if not loaded
  List<NetMusic> get musicList => playlist.musicList;

  @override
  Widget build(BuildContext context) {
    Map<String, Object> creator = playlist.creator;

    return DetailHeader(
        commentCount: playlist.commentCount,
        shareCount: playlist.shareCount,
        onCommentTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return CommentPage(
          //     threadId: CommentThreadId(playlist.id, CommentType.playlist,
          //         payload: CommentThreadPayload.playlist(playlist)),
          //   );
          // }));
        },
        onSelectionTap: () async {
          // if (musicList == null) {
          //   showSimpleNotification(context, Text("歌曲未加载,请加载后再试"));
          // } else {
          //   await Navigator.push(context, MaterialPageRoute(builder: (context) {
          //     return PlaylistSelectionPage(
          //         list: musicList,
          //         onDelete: (selected) async {
          //           return neteaseRepository.playlistTracksEdit(
          //               PlaylistOperation.remove,
          //               playlist.id,
          //               selected.map((m) => m.id).toList());
          //         });
          //   }));
          // }
        },
        onShareTap: () => showSimpleNotification(context, Text("页面未完成"),
      background: Color(0xFFd2dd37), foreground: Colors.black),
        content: Container(
          height: 150,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: <Widget>[
              SizedBox(width: 24),
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  child: Stack(
                    children: <Widget>[
                      Hero(
                        tag: playlist.heroTag,
                        child: Image(
                            fit: BoxFit.cover,
                            image: NeteaseImage(playlist.coverUrl)),
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Colors.black54,
                              Colors.black26,
                              Colors.transparent,
                              Colors.transparent,
                            ])),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.headset,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                  size: 12),
                              // Text(getFormattedNumber(playlist.playCount),
                              //     style: Theme.of(context)
                              //         .primaryTextTheme
                              //         .body1
                              //         .copyWith(fontSize: 11))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Text(
                      playlist.name,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .title
                          .copyWith(fontSize: 17),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () => {},
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: ClipOval(
                                child: Image(
                                    image: NeteaseImage(creator["avatarUrl"])),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 4)),
                            Text(
                              creator["nickname"],
                              style: Theme.of(context).primaryTextTheme.body1,
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).primaryIconTheme.color,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 16),
            ],
          ),
        ));
  }
}
