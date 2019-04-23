import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_player/model/audio_scp_model.dart';
import 'package:music_player/model/model.dart';
import 'package:music_player/model/music_scp_model.dart';
import 'package:music_player/player/music_player.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'music_page_search.dart';

class LocalMusicPage extends StatefulWidget{
  final MusicFileModel songModel;
  final AudioModel audioModel;
  final MusicPlayer musicPlayer;
  LocalMusicPage({@required this.songModel,this.audioModel,this.musicPlayer});
  @override
  _LocalMusicPageState createState()=>_LocalMusicPageState(songModel: songModel,audioModel: audioModel);
}

class _LocalMusicPageState extends State<LocalMusicPage> with TickerProviderStateMixin{
 final MusicPlayer musicPlayer;
  final MusicFileModel songModel;
  final AudioModel audioModel;
   
  ///////variables/////////////////
  List<LocalMusic> _songList=[];
  ScrollController controller = ScrollController();
  int _lastIntegerSelected;
  String localFilePath;
  
  _LocalMusicPageState({@required this.songModel,this.audioModel,this.musicPlayer});
  /////////////////////////
  @override
  Widget build(BuildContext context) {

    _songList=songModel.songList;
    audioModel.controller=TabController(vsync: this,length: audioModel.songList.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('本地音乐'),
        centerTitle: true,
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
      bottomNavigationBar: audioModel.songList.length<1?null:MusicPlayer(audioModel,audioModel.currentIndex),
    );
  }



getBody() {
  switch (songModel.status) {
    case SongModelAction.ERROR:
         return new Center(
            child: RaisedButton(onPressed: (){
               setState(() {
                 songModel.status=SongModelAction.SEARCHING;
              });
              // songModel.getSongListfromLocal();
              songModel.initSongList();
             
            },child: Text('获取本地歌曲'),),
         );         break;
    case SongModelAction.SEARCHING: new Future.delayed(const Duration(seconds: 2),(){
             setState(() {
                  _songList=songModel.songList;
                });
             });
              return  new Center(child:
                 new CircularProgressIndicator(),
              );break;
     
    case SongModelAction.FOUNDED: 
       return ScopedModelDescendant<MusicFileModel>(
               builder: (context,child,songModel){
                   return DraggableScrollbar.semicircle(
                     backgroundColor: Colors.white,
      padding: EdgeInsets.only(right: 4.0),
      labelTextBuilder: (double offset) => Text("${(offset ~/ 80)+1}",
          style: TextStyle(color: Colors.black)),
           controller: controller ,
                     child: ListView.builder(
                           controller: controller,
                           itemExtent: 80,
                          itemCount: _songList.length!=0?_songList.length:1,
                          itemBuilder: (BuildContext context,int index){
                              return Column(
                                   children: <Widget>[
                                      ListTile(
                                      onTap: (){
                                         setState(() {
                                          audioModel.songList=_songList; 
                                         });
                                       audioModel.changeIndex(_songList[index].id-1); 
                                       audioModel.play();
                                },
                              title: Row(
                                     children: <Widget>[
                                      Expanded(child: Text(  '${_songList[index].title}'  )),//file.path.substring(file.parent.path.length + 1)
                                      Container()   
                                      ],
                              ),
                              subtitle:  Text(
                                          '${_songList[index].artist}',
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
        ),
                   ) ;
      }
    );break;
         default:break;
      }
}  
}
