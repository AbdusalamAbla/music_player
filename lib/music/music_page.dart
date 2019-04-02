import 'package:flutter/material.dart';
import 'music_page_search.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:music_player/model/scp_model.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:async';
import 'package:music_player/model/model.dart';

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
  bool isPlaying=false;
  AudioPlayer audioPlayer;
  Duration duration;
  Duration position;
  String localFilePath;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';
  
  bool isMuted = false;
  int _currentIndex=0;
  LocalMusic _currentMusic=new LocalMusic(title: '点击歌曲进行播放',artist: '');
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  TabController _controller;
  /////////////////////////
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller=TabController(vsync: this,length: _songList.length);//TODO:need test
    
    // _controller.addListener(controlListener);
    initAudioPlayer();
     
  }

  @override
  void dispose() {
    // TODO: implement dispose
      _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    _controller.dispose();
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
      bottomNavigationBar: getBottomBar()
    );}
////////Songlist /////////////
getBody() {
  if(songModel.isFounding==false&&_songList.length!=0){
    _controller=TabController(vsync: this,length: _songList.length);
    _controller.addListener((){
      if(_currentIndex!=_controller.index){
         _currentIndex=_controller.index;
      if (isPlaying) {
       stop();
     }
    play();
      }
    });
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
            onTap: ()=>playMusic(music),
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


playMusic(LocalMusic music){
  _currentIndex=music.id-1;
  _controller.index=_currentIndex;
  if (isPlaying) {
    stop();
  }
  play();
}

controlListener(){
  print(_controller.index);
  _currentIndex=_controller.index;
  if(isPlaying){
    stop();
  }
  play();
}


////////player method/////
void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        isPlaying=false;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
     });
  }

  Future play() async {
   await audioPlayer.play(_songList[_currentIndex].path, isLocal: true);
    
    setState(() {
      isPlaying = true;
    });
  }

   Future pause() async {
    await audioPlayer.pause();
    setState(() => isPlaying=false);
  }
 Future stop() async {
    await audioPlayer.stop();
    setState(() {
     isPlaying=false;
      position = new Duration();
    });
  }
  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }
  void onComplete() {
    setState(() => isPlaying=false);
  }

getBottomBar(){
  return BottomAppBar(
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
                child: TabBarView(
               controller: _controller,
               children: _songList.map<Widget>((LocalMusic music){
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
                    icon: isPlaying?Icon(Icons.pause):Icon(Icons.play_arrow),
                     onPressed: (){
                      if (isPlaying) {
                  pause();
                    } else {
                   play();
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
    );
}
}
