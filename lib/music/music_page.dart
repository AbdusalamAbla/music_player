import 'package:flutter/material.dart';
import 'music_page_search.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:music_player/model/scp_model.dart';

import 'dart:async';
import 'package:music_player/model/model.dart';
import 'package:music_player/music/music_player.dart';

class MusicPage extends StatefulWidget{
  final MusicFileModel songModel;
  MusicPage({@required this.songModel});
  @override
  _MusicPageState createState()=>_MusicPageState(songModel: songModel);
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin{
 
  final MusicFileModel songModel;

   
  _MusicPageState({@required this.songModel});
  ///////variables/////////////////
  List<LocalMusic> _songList=[];
  ScrollController controller = ScrollController();
  int _lastIntegerSelected;
  
  String localFilePath;
  /////////////////////////
  @override
  void initState() {
    
    super.initState();
   }

  @override
  void dispose() {
      
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    _songList=songModel.songList;
    // _controller=TabController(vsync: this,length: _songList.length);
   
    return Scaffold(
      appBar: AppBar(
        title: Text('音乐界面'),
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
      ),
   
      body: ScopedModel<MusicFileModel>(
             model: songModel,
             child: getBody(),
           ),
      bottomNavigationBar: MusicPlayer(_songList)
    );}
////////Songlist /////////////
getBody() {
  if(songModel.isFounding==false&&_songList.length!=0){
    return ScopedModelDescendant<MusicFileModel>(
      builder: (context,child,songModel){
        return Scrollbar(
      child: ListView.builder(
        controller: controller,
        itemCount: _songList.length!=0?_songList.length:1,
        itemBuilder: (BuildContext context,int index){
            return buildListViewItem(_songList[index]);
        }),

        );
      }
    );
  }else if (songModel.isFounding==true){
    new Future.delayed(const Duration(seconds: 2),(){
      setState(() {
        _songList=songModel.songList;
      });
    });
    return  new Center(child:
        new CircularProgressIndicator(),
     );
  }else if (songModel.songList.length<1) {
    return new Center(
      child: RaisedButton(onPressed: (){
      songModel.getSongListfromLocal();
      setState(() {
       _songList=songModel.songList; 
      });
    },child: Text('获取本地歌曲'),),
    );
  }
}

  buildListViewItem(LocalMusic music){
    return  Column(
        children: <Widget>[
          ListTile(
            onTap: ()=>(){print('${music.id}');},
            title: Row(
              children: <Widget>[
                Expanded(child: Text(  '${music.title}'  )),//file.path.substring(file.parent.path.length + 1)
                 Container()   
              ],
            ),
            subtitle:  Text(
                    '${music.artist}    ${music.size}',
                    style: TextStyle(fontSize: 12.0),
                  ),
          trailing:  null ,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Divider(
              height: 1.0,
            ),
          )
        ],
        
      );
  }




}
