
import 'package:music_player/service/netease.dart';



abstract class ModelBase {
   String type;
      int id;
  String title;
  String path;
  String size;
}

class Music extends ModelBase {
  
  Music({this.id,
         this.title,
         this.artist,
         Album album,
          String url,
          String path,
         String size,
         int mvId
}){
   type='music';
   this.album=album??new Album(name: 'Not None');
   this.mvId=mvId??0;
   this.url=url??'';
   this.path=path??'';
  }
 final int id;
 final String title;
 final List<Artist> artist;
 String url;
 String path;
 Album album;
 String size;
 int mvId;
  
  @override
  int get hashCode => id.hashCode;


  String get subTitle {
    var ar = artist.map((a) => a.name).join('/');
    var al = album.name;
    return "$al - $ar";
  }

  @override
  String toString() {
    return 'Music{id: $id, title: $title, artist:$artist, path:$path,size:$size,url:$url}';
  }

 factory Music.fromMap(Map<String,dynamic> map){
   if (map == null) {
      return null;
    }
   return Music(
      id: map['id'] as int,
      title: map['title'] as String,
      artist: (map["artist"] as List)
               .cast<Map>()
               .map(Artist.fromMap)
               .toList(),
      album: Album.fromMap(map["album"]),
      path: map['path'] as String,
      size: map['size'] as String);
 }

 Map<String,dynamic> toMap(){
    return <String, dynamic>{
      'id': id,
      'title': title,
      'artist':artist.map((e) => e.toMap()).toList(),
      "subTitle": this.subTitle,
      'url':url,
      'path': path,
      'album':album.toMap(),
      'size': size,
    };
 }
}





// class NetMusic {
 
// NetMusic({
//     this.id,
//     this.title,
//     this.url, 
//     this.album, 
//     this.artist,
//     int mvId
// }): this.mvId = mvId ?? 0;

//  final int id;
//  final String title;
//  final String url;
//  final Album album;
//  final List<Artist> artist;
//  final int mvId;///歌曲mv id,当其为0时,表示没有mv

//  String get subTitle {
//     var ar = artist.map((a) => a.name).join('/');
//     var al = album.name;
//     return "$al - $ar";
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is NetMusic && runtimeType == other.runtimeType && id == other.id;

//   @override
//   int get hashCode => id.hashCode;

//   @override
//   String toString() {
//     return 'Music{id: $id, title: $title, url: $url, album: $album, artist: $artist}';
//   }

//   static NetMusic fromMap(Map map) {
//     if (map == null) {
//       return null;
//     }
//     return NetMusic(
//         id: map["id"],
//         title: map["title"],
//         url: map["url"],
//         album: Album.fromMap(map["album"]),
//         mvId: map['mvId'] ?? 0,
//         artist:(map["artist"] as List)
//                .cast<Map>()
//                .map(Artist.fromMap)
//                .toList());
//   }

//   Map toMap() {
//     return {
//       "id": this.id,
//       "title": this.title,
//       "url": this.url,
//       "subTitle": this.subTitle,
//       'mvId': this.mvId,
//       "album": this.album.toMap(),
//       "artist": this.artist.map((e) => e.toMap()).toList()
//     };
//   }
//   }


class Album {
  Album({this.coverImageUrl, this.name, this.id});

 final String coverImageUrl;
 final String name;
 final int id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id;

  @override
  int get hashCode => name.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'Album{name: $name, id: $id}';
  }

  static Album fromMap(Map map) {
    return Album(
        id: map["id"], name: map["name"], coverImageUrl: map["coverImageUrl"]);
  }

  Map toMap() {
    return {"id": id, "name": name, "coverImageUrl": coverImageUrl};
  }
}

class Artist {

Artist({this.name, this.id, this.imageUrl});

 final String name;
 final int id;
 final String imageUrl;

  @override
  String toString() {
    return 'Artist{name: $name, id: $id, imageUrl: $imageUrl}';
  }

  static Artist fromMap(Map map) {
    return Artist(id: map["id"], name: map["name"]);
  }

  Map toMap() {
    return {"id": id, "name": name};
  }
}

class PlaylistDetail {
  PlaylistDetail(
      this.id,
      this.musicList,
      this.creator,
      this.name,
      this.coverUrl,
      this.trackCount,
      this.description,
      this.subscribed,
      this.subscribedCount,
      this.commentCount,
      this.shareCount,
      this.playCount);

  ///null when playlist not complete loaded
  final List<Music> musicList;

  String name;

  String coverUrl;

  int id;

  int trackCount;

  String description;

  bool subscribed;

  int subscribedCount;

  int commentCount;

  int shareCount;

  int playCount;

  bool get loaded => musicList != null && musicList.length == trackCount;

  ///tag fro hero transition
  String get heroTag => "playlist_hero_$id";

  ///
  /// properties:
  /// avatarUrl , nickname
  ///
  final Map<String, dynamic> creator;

  static PlaylistDetail fromJson(Map playlist) {
    return PlaylistDetail(
        playlist["id"],
        mapJsonListToMusicList(playlist["tracks"],
            artistKey: "ar", albumKey: "al"),
        playlist["creator"],
        playlist["name"],
        playlist["coverImgUrl"],
        playlist["trackCount"],
        playlist["description"],
        playlist["subscribed"],
        playlist["subscribedCount"],
        playlist["commentCount"],
        playlist["shareCount"],
        playlist["playCount"]);
  }

  static PlaylistDetail fromMap(Map map) {
    if (map == null) {
      return null;
    }
    return PlaylistDetail(
        map['id'],
        (map['musicList'] as List)
            ?.cast<Map>()
            ?.map((m) => Music.fromMap(m))
            ?.toList(),
        map['creator'],
        map['name'],
        map['coverUrl'],
        map['trackCount'],
        map['description'],
        map['subscribed'],
        map['subscribedCount'],
        map['commentCount'],
        map['shareCount'],
        map['playCount']);
  }

  Map toMap() {
    return {
      'id': id,
      'musicList': musicList?.map((m) => m.toMap())?.toList(),
      'creator': creator,
      'name': name,
      'coverUrl': coverUrl,
      'trackCount': trackCount,
      'description': description,
      'subscribed': subscribed,
      'subscribedCount': subscribedCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'playCount': playCount
    };
  }
}