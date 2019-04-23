import 'package:flutter/material.dart';

import 'package:music_player/material/DividerWrapper.dart';
import 'package:music_player/model/audio_scp_model.dart';
import 'package:music_player/model/music_scp_model.dart';
import 'package:music_player/local/local_music_page.dart';

import 'package:overlay_support/overlay_support.dart';
class MainLocalPage extends StatefulWidget{
  final MusicFileModel songModel;
  final AudioModel audioModel;
  MainLocalPage(this.songModel,this.audioModel);
@override
_MainLocalPageState createState()=>_MainLocalPageState(songModel,audioModel);
}
class _MainLocalPageState extends State<MainLocalPage>{
  final MusicFileModel songModel;
  final AudioModel audioModel;
  _MainLocalPageState(this.songModel,this.audioModel);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        Column(
          children: <Widget>[
            DividerWrapper(
            indent: 16,
            child: ListTile(
              leading: Icon(
                Icons.format_align_left,
                color:const  Color.fromRGBO(0,52,63, 1),
              ),
              title: Text.rich(TextSpan(children: [
                TextSpan(text: '本地音乐'),
                TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    text:
                        '  ${songModel.songList.length>0?songModel.songList.length:''}'),
              ])),
              onTap: () {
                Navigator.push(context, new MaterialPageRoute(
            builder: (context)=>new LocalMusicPage(songModel: songModel,audioModel: audioModel,)
          ));
              },
            )),
            DividerWrapper(
            indent: 16,
            child: ListTile(
              leading: Icon(
                Icons.cast,
                color: Color.fromRGBO(0,52,63, 1),
              ),
              title: Text.rich(TextSpan(children: [
                TextSpan(text: '新功能2'),
              ])),
              onTap: () {
                showSimpleNotification(context, Text('还未创建对应功能'),background: Colors.black12);
              },
            )),
            DividerWrapper(
            indent: 16,
            child: ListTile(
              leading: Icon(
                Icons.library_music,
                color:const  Color.fromRGBO(0,52,63, 1),
              ),
              title: Text.rich(TextSpan(children: [
                TextSpan(text: '新功能3 '),
              ])),
              onTap: () {
                showSimpleNotification(context, Text('还未创建对应功能'),background: Colors.black12);
              },
            )),
            
            
          ],
    ),
    );
  }

}