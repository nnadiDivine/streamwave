import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CurrentMusic with ChangeNotifier {
  List songs = [];
  List songNames = [];
  List songAlbums = [];
  IconData playIcon = Icons.play_arrow;
  IconData shuffleIcon = Icons.loop;
  final audioQuerry = OnAudioQuery();
  int index = 0;
  bool isPlaying = false;
  bool hasLast = false;
  String toggle = '';
  final _playingBox = Hive.box('playingBox');
  final audioPlayer = AudioPlayer();

  setLast() {
    hasLast = _playingBox.get('last');
  }

  getMusic() {
    return _playingBox.get(index);
  }

  setLoopIcon() {
    shuffleIcon = Icons.loop;
  }

  setShuflleIcon() {
    shuffleIcon = Icons.shuffle;
  }

  setOnceIcon() {
    shuffleIcon = Icons.play_disabled_outlined;
  }

  getToggle() {
    return _playingBox.get('toggle');
  }

  newMusic(int i) {
    _playingBox.put(0, i);
    return;
  }

  getSongName() {
    return _playingBox.get(1);
  }

  getAlbum() {
    notifyListeners();
    return songAlbums[getMusic()];
  }

  songLength() {
    return songs.length;
  }
  // isPlayingNow() {
  //   isPlaying = _playingBox.get('isPlaying');
  //   return _playingBox.get('isPlaying');
  // }

  pause() {
    isPlaying = false;
    playIcon = Icons.play_arrow;
    notifyListeners();
  }

  play() {
    isPlaying = true;
    playIcon = Icons.pause;
    notifyListeners();
  }

  playIt() {
    isPlaying = true;
    audioPlayer.play(UrlSource(songs[getMusic()]));
    playIcon = Icons.pause;
    shuffleIcon = Icons.loop;
    notifyListeners();
  }

  shufflePlayIt() {
    isPlaying = true;
    audioPlayer.play(UrlSource(songs[getMusic()]));
    songs.shuffle();
    playIcon = Icons.pause;
    shuffleIcon = Icons.shuffle;
    notifyListeners();
  }
}
