import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_player/models/models.dart';

import 'package:audioplayer/audioplayer.dart';
import 'package:music_player/utils/music_playing.dart';
import 'package:scoped_model/scoped_model.dart';

class MusicPlayer extends StatefulWidget{
  MusicPlayer(this.audioModel);
final AudioModel  audioModel;
@override 
_MusicPlayerState createState()=>_MusicPlayerState(audioModel);
}
class _MusicPlayerState extends State<MusicPlayer> with TickerProviderStateMixin{



_MusicPlayerState(this.audioModel);
  //////////////////variables/////////////

  String localFilePath;
  final AudioModel  audioModel;
  // bool isPlaying;
  AudioPlayer audioPlayer;
  Duration duration;
  Duration position;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  bool isControllerInit=false;
  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';
///////////////////////////////////////////


@override
  void initState() {
    super.initState();
    initPD();
    

     
  }
  @override
  void dispose() {
   
    _audioPlayerStateSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }
  initPD(){
     audioPlayer=audioModel.audioPlayer; 
     
     duration=audioPlayer.duration;
   _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        audioModel.onComplete();
        setState(() {
          position = new Duration();
        });
      }
    }, onError: (msg) {
      setState(() {
        
        audioModel.audioState=MusicState.STOPPED;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
     });
  }
  

  
  @override
  Widget build(BuildContext context) {
    //  if (!isControllerInit) {
       
    //  }
     setState(() {
      audioModel.controller.index=audioModel.currentIndex; 
     });
      //  isPlaying=_audioModel.isPlaying;
       
    return ScopedModel<AudioModel>(
         model: audioModel,
         child: BottomAppBar(
             child: Container(
              height: 110,
              child: new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 30,
                  child: Row(
                 mainAxisSize: MainAxisSize.max,
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: <Widget>[
                  Text(  '${positionText??''}',style: new TextStyle(fontSize: 12),),
                  duration == null? new Container()
                  : new Slider(
                    value: position?.inMilliseconds?.toDouble() ?? 0.0,
                    onChanged: (double value) =>
                    audioPlayer.seek((value / 1000).roundToDouble()),
                    min: 0.0,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    max: (duration.inSeconds<0)&&(duration.inMinutes<0)?0:duration.inMilliseconds.toDouble()
                  ),
                  Text('${durationText ??''}',style: new TextStyle(fontSize: 12),),
                ],
               ),
                ),
                
               Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                 
              Container(
                width: 190,
                height: 80,
                child: 
                  TabBarView(
               controller: audioModel.controller,
               children: audioModel.songList.map<Widget>((Music music){
                return Column(
           children: <Widget>[
              Text(  '${music.title}' ,style: new TextStyle(fontSize: 18), softWrap:false,overflow: TextOverflow.fade,),
             Text('${music.artist[0].name}',style: new TextStyle(color: Colors.grey),softWrap: false,),
            
           ],
         );
               }).toList(),
                )
                
                
              ),
              Container(
              width: 100,
              height: 80,
              child: Row(
                children: <Widget>[
                IconButton(
                    icon: audioModel.audioState==MusicState.PLAYING?Icon(Icons.pause):Icon(Icons.play_arrow),
                     onPressed: (){
                       if (audioModel.audioState==MusicState.PLAYING) {
                         audioModel.pause();
                       } else if(audioModel.audioState==MusicState.PAUSED){
                        audioModel.contiNue();
                       }
                       
                     },
               ),
               IconButton(icon: Icon(Icons.menu), onPressed: () {},),      
             ],
            ),
          ),
         ],)
        ],
      ),
     ),
    )
    );
  }

}