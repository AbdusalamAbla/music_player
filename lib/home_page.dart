import 'package:flutter/material.dart';
import 'package:music_player/music/music_page.dart';
import 'package:music_player/model/scp_model.dart';
class HomePage extends StatefulWidget{
  @override
  _HomePageState createState()=>_HomePageState();
 
}

class _HomePageState extends State<HomePage>{

  @override
  void initState() {
    super.initState();
    songModel.getSongListfromLocal();
  }
  final MusicFileModel songModel=MusicFileModel();
  @override
  Widget build(BuildContext context) {
    return MusicPage(songModel: songModel);
  }

}