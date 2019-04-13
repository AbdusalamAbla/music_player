import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:async';
import 'package:music_player/model/model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:music_player/model/audio_scp_model.dart';
class MusicPlayer extends StatefulWidget{
  MusicPlayer(this.audioModel,this._currentIndex);
 final AudioModel audioModel;
final int _currentIndex;
@override 
_MusicPlayerState createState()=>_MusicPlayerState(audioModel,this._currentIndex);
}
class _MusicPlayerState extends State<MusicPlayer> with TickerProviderStateMixin{



_MusicPlayerState(this._audioModel,this._currentIndex);
  //////////////////variables/////////////
final AudioModel _audioModel;
  String localFilePath;
  int _currentIndex;
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
    
      //  isControllerInit=true;
     
  }
  @override
  void dispose() {
   
    _audioPlayerStateSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }
  initPD(){
      
     audioPlayer=_audioModel.audioPlayer; 
     
     duration=audioPlayer.duration;
   _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        _audioModel.onComplete();
        setState(() {
          position = new Duration();
        });
      }
    }, onError: (msg) {
      setState(() {
        
        _audioModel.isPlaying=false;
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
      _audioModel.controller.index=_audioModel.currentIndex; 
     });
      //  isPlaying=_audioModel.isPlaying;
       
       
    return ScopedModel<AudioModel>(
         model: _audioModel,
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
                  duration == null? new Slider(
                    value:  0.0,
                    onChanged: (double value) =>
                    audioPlayer.seek((value / 1000).roundToDouble()),
                    min: 0.0,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    max: 100
                  )
                  : new Slider(
                    value: position?.inMilliseconds?.toDouble() ?? 0.0,
                    onChanged: (double value) =>
                    audioPlayer.seek((value / 1000).roundToDouble()),
                    min: 0.0,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    max: duration.inMilliseconds.toDouble()
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
                  width: 100,
                  height: 80,
                  child: Row(
                    children: <Widget>[
                     IconButton(
                      icon: Icon(Icons.collections),
                      onPressed: (){},
                     ),
                     IconButton(
                      icon: Icon(Icons.launch),
                      onPressed: (){},
                     )
                    ],
                  )
                 ),
              Container(
                width: 190,
                height: 80,
                child: 
                  TabBarView(
               controller: _audioModel.controller,
               children: _audioModel.songList.map<Widget>((LocalMusic music){
                return Column(
           children: <Widget>[
              Text(  '${music.title}' ,style: new TextStyle(fontSize: 18), softWrap:false,overflow: TextOverflow.fade,),
             Text('${music.artist}',style: new TextStyle(color: Colors.grey),softWrap: false,),
            
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
                    icon: _audioModel.isPlaying?Icon(Icons.pause):Icon(Icons.play_arrow),
                     onPressed: (){
                       if (_audioModel.isPlaying) {
                         _audioModel.pause();
                       } else {
                         _audioModel.play();
                       }
                       setState(() {
                         _audioModel.isPlaying?_audioModel.isPlaying=false:_audioModel.isPlaying=true;
                         });
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