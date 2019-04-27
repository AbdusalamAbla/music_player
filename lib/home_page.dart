import 'package:flutter/material.dart';

import 'models/models.dart';
import 'service/music_player.dart';
import 'pages/music_page_search.dart';
import 'utils/dialogs.dart';
import 'main_local.dart';
import 'main_netease.dart';
import 'routes.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState()=>_HomePageState();
 
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  
  //////////////////
  MusicPlayer musicPlayer;
   int _lastIntegerSelected;
   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProxyAnimation transitionAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);
////////////////////
 TabController _tabController;

  @override
  void initState() {
    super.initState();
    // songModel.getSongListfromLocal();
    _tabController=TabController(vsync: this,length: 2);

  }
  
  @override
  Widget build(BuildContext context) {
    final AudioModel audioModel=AudioModel.of(context);
        musicPlayer=new MusicPlayer(audioModel);
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
                            title: Text("关于开发人员"),
                            onTap: () {
                              launch(
                                  "https://github.com/AbdusalamAbla");
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
        centerTitle: true,
        title: Container(
            height: kToolbarHeight,
            width: 128,
            child: TabBar(
              controller: _tabController,
              indicator:
                  UnderlineTabIndicator(insets: EdgeInsets.only(bottom: 4)),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: <Widget>[
                Tab(child: Icon(Icons.music_note)),
                Tab(child: Icon(Icons.cloud)),
              ],
            ),
          ),
          actions: <Widget>[
          
        IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final int selected = await showSearch<int>(
                context: context,
                delegate: searchDelegate,
              );
              if (selected != null && selected != _lastIntegerSelected) {
                setState(() {
                  _lastIntegerSelected = selected;
                });
              }
            },
          ),
        
      ],
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
          children: <Widget>[MainLocalPage(), MainCloudPage()],
        ),
      bottomNavigationBar: initBottomBar(),
      );
  }

initBottomBar(){
  final AudioModel audioModel=AudioModel.of(context);
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
    if (UserAccount.of(context).isLogin) {
      return _buildHeader(context);
    } else {
      return _buildHeaderNotLogin(context);
    }
  }
  
  Widget _buildHeader(BuildContext context) {
    Map profile = UserAccount.of(context).user["profile"];
    return UserAccountsDrawerHeader(
      currentAccountPicture: InkResponse(
        onTap: () {
          if (UserAccount.of(context).isLogin) {
            // debugPrint("work in process...");
          }
        },
        child: CircleAvatar(
          
        ),
      ),
      accountName: Text(profile["nickname"]),
      accountEmail: null,
      otherAccountsPictures: [
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            tooltip: "退出登陆",
            onPressed: () async {
              if (await showConfirmDialog(context, Text('确认退出登录吗？'),
                  positiveLabel: '退出登录')) {
                UserAccount.of(context, rebuildOnChange: false).logout();
              }
            },
          ),
        )
      ],
    );
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
                      Navigator.pushNamed(context, ROUTE_LOGIN);
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