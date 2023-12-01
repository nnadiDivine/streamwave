import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:streamwave/providers/current_music.dart';
import 'package:streamwave/providers/favourite.dart';
import 'package:streamwave/screens/home.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.audioPlayer});
  final AudioPlayer audioPlayer;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool _fisrt = true;
  Color bgColor = const Color.fromARGB(255, 255, 133, 213);
  Color subColor = Colors.white;
  final playingBox = Hive.box('playingBox');
  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  @override
  void initState() {
    super.initState();

    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        Provider.of<CurrentMusic>(context).isPlaying =
            state == PlayerState.playing;
      });
    });

    widget.audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    widget.audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    widget.audioPlayer.onPlayerComplete.listen((event) {
      Provider.of<CurrentMusic>(context, listen: false).pause();
      int newSongIndex =
          Provider.of<CurrentMusic>(context, listen: false).getMusic();
      String toggle =
          Provider.of<CurrentMusic>(context, listen: false).getToggle();
      if (toggle == 'loop') {
        playingBox.put(0, newSongIndex + 1);
        Provider.of<CurrentMusic>(context, listen: false).playIt();
      } else if (toggle == 'shuffle') {
        playingBox.put(0, newSongIndex + 1);
        Provider.of<CurrentMusic>(context, listen: false).shufflePlayIt();
      } else {
        Provider.of<CurrentMusic>(context, listen: false).pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List favSongs = Provider.of<Favourite>(context).favourite_song;
    List favSongsName = Provider.of<Favourite>(context).favourite_songName;
    List favSongAlbum = Provider.of<Favourite>(context).favourite_songAlbum;
    final audioPlayer = Provider.of<CurrentMusic>(context).audioPlayer;
    int songLength =
        Provider.of<CurrentMusic>(context, listen: false).songLength();
    bool isPlaying = Provider.of<CurrentMusic>(
      context,
    ).isPlaying;
    int songIndex =
        Provider.of<CurrentMusic>(context, listen: false).getMusic();
    String url = Provider.of<CurrentMusic>(context).songs[songIndex];
    String toggle =
        Provider.of<CurrentMusic>(context, listen: false).getToggle();

    if (!isPlaying && _fisrt) {
      audioPlayer.play(UrlSource(url));
      Provider.of<CurrentMusic>(context, listen: false).play();
      Provider.of<CurrentMusic>(context, listen: false).setLast();
      setState(() {
        _fisrt = false;
      });
    }
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: subColor,
                  iconSize: 35,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const StreamWave(),
                    ));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(150.0),
            ),
            child: const Album(),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Provider.of<CurrentMusic>(context)
                  .songNames[Provider.of<CurrentMusic>(context).getMusic()],
              softWrap: true,
              maxLines: 2,
              style: TextStyle(fontSize: 20, color: subColor),
            ),
          ),
          Slider(
            min: 0,
            thumbColor: const Color.fromARGB(255, 202, 85, 161),
            activeColor: const Color.fromARGB(255, 185, 80, 148),
            inactiveColor: subColor,
            value: position.inSeconds.toDouble(),
            onChanged: (value) {
              final position = Duration(seconds: value.toInt());
              audioPlayer.seek(position);
              Provider.of<CurrentMusic>(context, listen: false).play();
              audioPlayer.resume();
            },
            max: duration.inSeconds.toDouble(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatTime(position),
                  style: TextStyle(color: subColor),
                ),
                Text(
                  formatTime(duration - position),
                  style: TextStyle(color: subColor),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                color: subColor,
                onPressed: () {
                  Provider.of<CurrentMusic>(context, listen: false).play();
                  int newSongIndex =
                      Provider.of<CurrentMusic>(context, listen: false)
                          .getMusic();
                  if (newSongIndex > 0) {
                    playingBox.put(0, newSongIndex - 1);
                  } else {
                    playingBox.put(0, songLength - 1);
                  }
                  Provider.of<CurrentMusic>(context, listen: false).playIt();
                },
              ),
              AvatarGlow(
                glowColor: subColor,
                endRadius: 50,
                duration: const Duration(seconds: 3),
                repeat: true,
                showTwoGlows: true,
                curve: Curves.easeOutQuad,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: subColor,
                  ),
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: Icon(Provider.of<CurrentMusic>(context).playIcon),
                    color: Colors.black,
                    onPressed: () {
                      if (isPlaying) {
                        audioPlayer.pause();
                        Provider.of<CurrentMusic>(context, listen: false)
                            .pause();
                        return;
                      } else {
                        audioPlayer.play(UrlSource(url));
                        Provider.of<CurrentMusic>(context, listen: false)
                            .play();
                        Provider.of<CurrentMusic>(context, listen: false)
                            .setLast();
                        return;
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                color: subColor,
                onPressed: () {
                  Provider.of<CurrentMusic>(context, listen: false).play();
                  int newSongIndex =
                      Provider.of<CurrentMusic>(context, listen: false)
                          .getMusic();
                  int songLength =
                      Provider.of<CurrentMusic>(context, listen: false)
                          .songLength();
                  if (newSongIndex < songLength - 1) {
                    playingBox.put(0, newSongIndex + 1);
                  } else {
                    playingBox.put(0, 0);
                  }
                  Provider.of<CurrentMusic>(context, listen: false).playIt();
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (toggle == 'loop') {
                  setState(() {
                    playingBox.put('toggle', 'playOnce');
                  });
                  Provider.of<CurrentMusic>(context, listen: false)
                      .setOnceIcon();
                } else if (toggle == 'playOnce') {
                  setState(() {
                    playingBox.put('toggle', 'shuffle');
                  });
                  Provider.of<CurrentMusic>(context, listen: false)
                      .setShuflleIcon();
                } else {
                  setState(() {
                    playingBox.put('toggle', 'loop');
                  });
                  Provider.of<CurrentMusic>(context, listen: false)
                      .setLoopIcon();
                }
              },
              icon: Icon(Provider.of<CurrentMusic>(context).shuffleIcon),
              color: subColor,
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {
                favSongs.add(url);
                int songAlbum = Provider.of<CurrentMusic>(context).getAlbum();
                favSongAlbum.add(songAlbum);
                favSongsName.add(Provider.of<CurrentMusic>(context)
                    .songNames[Provider.of<CurrentMusic>(context).getMusic()]);
                Provider.of<Favourite>(context, listen: false).AddFav();
                Provider.of<Favourite>(context, listen: false).AddFavName();
                Provider.of<Favourite>(context, listen: false).AddFavAlbum();
              },
              icon: const Icon(Icons.favorite),
              color: subColor,
              iconSize: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class Album extends StatelessWidget {
  const Album({super.key});

  @override
  Widget build(BuildContext context) {
    int songAlbum = Provider.of<CurrentMusic>(context).getAlbum();
    return QueryArtworkWidget(
      nullArtworkWidget: Image.asset('assets/images/music.png'),
      id: songAlbum,
      type: ArtworkType.AUDIO,
      quality: 100,
      artworkFit: BoxFit.cover,
      artworkQuality: FilterQuality.high,
      artworkBorder: BorderRadius.circular(200.0),
    );
  }
}
