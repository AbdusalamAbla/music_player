import 'package:flutter/material.dart';
import 'package:music_player/service/netease.dart';
class MainCloudPage extends StatefulWidget{
@override
_MainCloudPageState createState()=>_MainCloudPageState();
}
class _MainCloudPageState extends State<MainCloudPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: 
          RaisedButton(
            child: Text('获取登陆数据'),
            onPressed: ()async{
             Map<String ,dynamic> result=await neteaseRepository.personalizedNewSong();
             print(result);
            },)
        ,),
    );
  }

}