import 'package:flutter/material.dart';
import 'package:music_player/music/local_music_page.dart';
import 'package:music_player/model/music_scp_model.dart';
import 'package:music_player/model/audio_scp_model.dart';
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
      body: Center(child: RaisedButton(
        child: Text('本地歌曲'),
        onPressed: (){
          Navigator.push(context, new MaterialPageRoute(
            builder: (context)=>new LocalMusicPage(songModel: songModel,audioModel: audioModel,)
          ));
        },//TODO 在主页创建对象后进行初始化赋值并在redux中传值到localpage页面
      )),
    );
  }

}