import 'package:music_player/models/model.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

enum MusicState{PLAYING,STOPPED,PAUSED}
class AudioModel extends Model{
  

  static AudioModel of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of<AudioModel>(context,
        rebuildOnChange: rebuildOnChange);
  }
  AudioModel(){
    initAudioPlayer();
    
  }
  List<Music> songList=[];
  MusicState audioState=MusicState.STOPPED;
  AudioPlayer audioPlayer;
  bool change=false;
  String localFilePath;
  
  bool isChange=false;
  bool isMuted = false;
  int currentIndex=0;
  
TabController controller;

void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
   
       
  }

  Future play() async {
    if(audioState==MusicState.PLAYING||audioState==MusicState.PAUSED){
      stop();
    }
    print('currentIndex :$currentIndex');
    try {
      if (songList[currentIndex].url!=''&&songList[currentIndex].url!=null) {
        print('是这个'+songList[currentIndex].url);
      await audioPlayer.play(songList[currentIndex].url);
    } else {
      await audioPlayer.play(songList[currentIndex].path, isLocal: true);
    }
    audioState=MusicState.PLAYING;
   notifyListeners();
    } catch (e) {
      print('无法播放音乐');
    }
   
   
  }
   Future contiNue() async{
     
    print('currentIndex :$currentIndex');
    try {
      if (songList[currentIndex].url!=''&&songList[currentIndex].url!=null) {
        print('是这个'+songList[currentIndex].url);
      await audioPlayer.play(songList[currentIndex].url);
    } else {
      await audioPlayer.play(songList[currentIndex].path, isLocal: true);
    }
    audioState=MusicState.PLAYING;
   notifyListeners();
    } catch (e) {
      print('无法播放音乐');
    }
   
   
   }
   Future pause() async {
    await audioPlayer.pause();
    audioState=MusicState.PAUSED;
    notifyListeners();
  }
 Future stop() async {
    await audioPlayer.stop();
     audioState=MusicState.STOPPED;
      notifyListeners();
    
  }
  changeIndex(int index){
    print('changeTo  $index');
    currentIndex=index;
    controller.index=index;
    notifyListeners();
  }
  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    isMuted = muted;
  }
  
  void onComplete() {
     audioState=MusicState.STOPPED;
     notifyListeners();
  }

  dispose(){
    controller.dispose();
    audioPlayer.stop();
  }
}