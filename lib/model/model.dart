import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

abstract class ModelBase {
   String type;
      int id;
  String title;
  String artist;
  String path;
  String modify;
  String size;
}

@JsonSerializable()
class LocalMusic extends ModelBase {
  
  LocalMusic({this.id,this.title,this.artist,this.path,this.modify,this.size}){
   type='music';
  }
 final int id;
 final String title;
 final String artist;
 final String path;
 final String modify;
 final String size;


 factory LocalMusic.fromJson(Map<String,dynamic> json)=>_$LocalMusicFromJson(json);

 Map<String,dynamic> toJson()=>_$LocalMusicToJson(this);
}





class NetMusic {
 
NetMusic({
    this.id,
    this.title,
    this.url, 
    this.album, 
    this.artist,
    int mvId
}): this.mvId = mvId ?? 0;

 final int id;
 final String title;
 final String url;
 final Album album;
 final List<Artist> artist;
 final int mvId;///歌曲mv id,当其为0时,表示没有mv

 String get subTitle {
    var ar = artist.map((a) => a.name).join('/');
    var al = album.name;
    return "$al - $ar";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetMusic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Music{id: $id, title: $title, url: $url, album: $album, artist: $artist}';
  }

  static NetMusic fromMap(Map map) {
    if (map == null) {
      return null;
    }
    return NetMusic(
        id: map["id"],
        title: map["title"],
        url: map["url"],
        album: Album.fromMap(map["album"]),
        mvId: map['mvId'] ?? 0,
        artist:(map["artist"] as List)
               .cast<Map>()
               .map(Artist.fromMap)
               .toList());
  }

  Map toMap() {
    return {
      "id": this.id,
      "title": this.title,
      "url": this.url,
      "subTitle": this.subTitle,
      'mvId': this.mvId,
      "album": this.album.toMap(),
      "artist": this.artist.map((e) => e.toMap()).toList()
    };
  }
  }


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
