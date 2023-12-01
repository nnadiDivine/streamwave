import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Favourite with ChangeNotifier {
  List favourite_song = [];
  List favourite_songName = [];
  List favourite_songAlbum = [];
  final _playingBox = Hive.box('playingBox');
  final audioPlayer = AudioPlayer();

  AddFav() {
     _playingBox.get("favourite") == favourite_song;
  }
  AddFavName() {
     _playingBox.get("favouriteName") == favourite_songName;
  }
  AddFavAlbum() {
     _playingBox.get("favouriteAlbum") == favourite_songAlbum;
  }
}
