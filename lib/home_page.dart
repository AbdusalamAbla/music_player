import 'package:flutter/material.dart';
import 'package:music_player/music/music_player.dart';
import 'package:music_player/model/music_scp_model.dart';
import 'package:music_player/model/audio_scp_model.dart';
import 'routes.dart';
import 'main/main_local.dart';
import 'main/main_cloud.dart';
class HomePage extends StatefulWidget{
  @override
  _HomePageState createState()=>_HomePageState();
 
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  
  //////////////////
  final MusicFileModel songModel=MusicFileModel();
  final AudioModel audioModel=AudioModel();
  MusicPlayer musicPlayer;

   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProxyAnimation transitionAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);
////////////////////
 TabController _tabController;

  @override
  void initState() {
    super.initState();
    songModel.getSongListfromLocal();
    audioModel.initAudioPlayer();
    _tabController=TabController(vsync: this,length: 2);
    audioModel.songList=songModel.songList;
    musicPlayer=new MusicPlayer(audioModel,audioModel.currentIndex);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer:Drawer(
        child: Column(
            children: <Widget>[
              _AppDrawerHeader(),
              MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Expanded(
                    child: ListTileTheme(
                      style: ListTileStyle.drawer,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text("设置"),
                            onTap: () {
                              // Navigator.pushNamed(context, ROUTE_SETTING);
                              Navigator.pushNamed(context, ROUTE_SETTING);
                            },
                          ),
                          Divider(height: 0, indent: 16),
                          ListTile(
                            leading: Icon(Icons.format_quote),
                            title: Text("Star On GitHub"),
                            onTap: () {
                              // launch(
                              //     "https://github.com/boyan01/quiet-flutter");
                              print('github');
                            },
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
      ),
      appBar: AppBar(
        leading: IconButton(
              icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_arrow,
                  color: Theme.of(context).primaryIconTheme.color,
                  progress: transitionAnimation),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              }),
        
      ),
      body: TabBarView(
          controller: _tabController,
          children: <Widget>[MainLocalPage(songModel,audioModel), MainCloudPage()],
        ),
      bottomNavigationBar: initBottomBar(),
      );
  }

initBottomBar(){
  if (audioModel.songList.length<1) {
    return null;
  }else{
return musicPlayer;
  }
}
}


class _AppDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return _buildHeaderNotLogin(context);
  }

  Widget _buildHeaderNotLogin(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Container(
        constraints: BoxConstraints.expand(),
        child: DefaultTextStyle(
          style:
              Theme.of(context).primaryTextTheme.caption.copyWith(fontSize: 14),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("登陆获得更多歌曲"),
                SizedBox(height: 8),
                FlatButton(
                    shape: RoundedRectangleBorder(
                            side: BorderSide(
                                   color: Theme.of(context)
                                    .primaryTextTheme
                                    .body1
                                    .color
                                    .withOpacity(0.9)),
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    onPressed: () {
                      // Navigator.pushNamed(context, ROUTE_LOGIN);
                      print('login');
                    },
                    child: Text("立即登陆"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}