import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:music_player/model/model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:music_player/service/local_data.dart';

enum SongModelAction{START,SEARCHING,FOUNDED,ERROR}

class MusicFileModel extends Model {
   List<LocalMusic> _songList=[];
   SongModelAction status=SongModelAction.START;
   List<LocalMusic> get songList=>_songList;
MusicFileModel(){
  initSongList();
}

initSongList()async{
  bool permission = await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
      
  if (!permission) {
        //* 没有权限，设置statu为ERROR，申请读取文件权限
        status=SongModelAction.ERROR;
        await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
  }else{
     status=SongModelAction.SEARCHING;
    _songList=await myData.getLocalMusiclist();
    if(_songList.length>1){
       print('找到数据');
       status=SongModelAction.FOUNDED;
       notifyListeners();
      return _songList;
       //* 没找到数据，进行查找工作，再返回数据
      
    }
    print('未找到数据,进行文件遍历');
    var path=(await getExternalStorageDirectory()).path;
       _songList = await compute(_findFileInDir, path);
    myData.updateUserPlaylist(_songList);
    status=SongModelAction.FOUNDED;
    notifyListeners();
    return _songList;
    
      }
     
}
  
  static List<LocalMusic> _findFileInDir(String path){

    List<FileSystemEntity> fileList=[];
    List<FileSystemEntity> songFileList=[];
    List<LocalMusic>  songList=[];
      Directory directory=Directory(path);
     fileList.addAll(directory.listSync());
     for (int index=0;index<fileList.length;index++) {
       var file=fileList[index];
       if (!FileSystemEntity.isFileSync(file.path)&&basename(file.path).substring(0,1)!='.') {
         fileList.addAll(Directory(file.path).listSync());
         fileList.removeAt(index);
         index--;
       }
     }
     
      for (FileSystemEntity file in fileList) {
        var listStr= basename(file.path).split('.');
        if (listStr.length!=2) {
          continue;
        }else{
         switch (listStr[1]) {
           case 'mp3':
           case 'MP3':
           case 'Mp3':
           case 'flac':
           case 'Flac':
           case "FLAC":
           case 'wav':
           case 'Wav':
           if (!(File(file.resolveSymbolicLinksSync()).lengthSync()<1048576)) {
             songFileList.add(file);
           }   break;
           default:break;
         }
        }
      }
      for (var i = 0; i < songFileList.length; i++) {
        String totalName=songFileList[i].path.substring(songFileList[i].parent.path.length + 1);
         var k1=totalName.split(' - ');
         var k2=k1[1].split('.');
        songList.add(new LocalMusic(
          id: i+1,
          title:k2[0],
          artist: k1[0],
          path: songFileList[i].path,
          modify: getFileLastModifiedTime(songFileList[i]),
          size: getFileSize(songFileList[i])));
      }
      fileList=null;
      songFileList=null;
    
      return songList; 
   }



  static getFileLastModifiedTime(FileSystemEntity file) {
    DateTime dateTime = File(file.resolveSymbolicLinksSync()).lastModifiedSync();

    String time =
        '${dateTime.year}-${dateTime.month < 10 ? 0 : ''}${dateTime.month}-${dateTime.day < 10 ? 0 : ''}${dateTime.day} ${dateTime.hour < 10 ? 0 : ''}${dateTime.hour}:${dateTime.minute < 10 ? 0 : ''}${dateTime.minute}';
    return time;
  } 

 static getFileSize(FileSystemEntity file){
    int _fileSize=File(file.resolveSymbolicLinksSync()).lengthSync();
    if (_fileSize<1024) {
      return '${_fileSize.toStringAsFixed(2)}B';
    }else if (1024<=_fileSize&&_fileSize<1048576) {
      return '${(_fileSize/1024).toStringAsFixed(1)}KB';
    }else if(1048576<_fileSize&&_fileSize<1073741824){
      return '${(_fileSize/1024/1024).toStringAsFixed(1)}MB';
    }
  }
}