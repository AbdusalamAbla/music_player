import 'package:music_player/models/model.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class AudioModel extends Model{
  

  static AudioModel of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of<AudioModel>(context,
        rebuildOnChange: rebuildOnChange);
  }
  AudioModel(){
    initAudioPlayer();
    
  }
  List<Music> songList=[];
  bool isPlaying=false;
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
    if(isPlaying){
      stop();
    }
    print(currentIndex);
    try {
      if (songList[currentIndex].url!=''&&songList[currentIndex].url!=null) {
        print('是这个'+songList[currentIndex].url);
      await audioPlayer.play(songList[currentIndex].url);
    } else {
      await audioPlayer.play(songList[currentIndex].path, isLocal: true);
    }
    isPlaying = true;
   notifyListeners();
    } catch (e) {
      print('无法播放音乐');
    }
   
   
  }
   
   Future pause() async {
    await audioPlayer.pause();
    isPlaying=false;
    notifyListeners();
  }
 Future stop() async {
    await audioPlayer.stop();
     isPlaying=false;
      notifyListeners();
    
  }
  changeIndex(int index){
    print(index);
    currentIndex=index;
    controller.index=index;
    notifyListeners();
  }
  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    isMuted = muted;
  }
  
  void onComplete() {
     isPlaying=false;
     notifyListeners();
  }

  dispose(){
    controller.dispose();
    audioPlayer.stop();
  }
}