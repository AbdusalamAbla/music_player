import 'package:flutter/material.dart';
import 'package:music_player/music/music_player.dart';
import 'package:music_player/model/music_scp_model.dart';
import 'package:music_player/music/local_music_page.dart';
import 'package:music_player/model/audio_scp_model.dart';
class HomePage extends StatefulWidget{
  @override
  _HomePageState createState()=>_HomePageState();
 
}

class _HomePageState extends State<HomePage>{

  @override
  void initState() {
    super.initState();
    songModel.getSongListfromLocal();
    audioModel.initAudioPlayer();
    musicPlayer=new MusicPlayer(audioModel,audioModel.currentIndex);
    
    print(audioModel.controller);
  }
  final MusicFileModel songModel=MusicFileModel();
  final AudioModel audioModel=AudioModel();
  MusicPlayer musicPlayer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('音乐界面'),centerTitle: true,),
      body: Center(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RaisedButton(
            child: Text('本地歌曲'),
            onPressed: (){Navigator.push(
    context,
    new MaterialPageRoute(builder: (context) => new LocalMusicPage(songModel: songModel,audioModel: audioModel,musicPlayer: musicPlayer,)),
  );},
          ),
          RaisedButton(
            child: Text('网络歌曲'),
            onPressed: (){print('open netMusicPage');},
          )
        ],
      ),),
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