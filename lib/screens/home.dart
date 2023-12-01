// ignore_for_file: prefer_const_constructors

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:streamwave/providers/current_music.dart';
import 'package:streamwave/providers/favourite.dart';
import 'package:streamwave/screens/playScreen.dart';
import '../widgets/widgets.dart';

class StreamWave extends StatefulWidget {
  const StreamWave({super.key});

  @override
  State<StreamWave> createState() => _StreamWaveState();
}

class _StreamWaveState extends State<StreamWave> {
  @override
  void initState() {
    super.initState();
    requestPermission();
    _playingBox.put('isPlaying', false);
    if (_playingBox.get('last') == null) {
      _playingBox.put('last', false);
    }
    if (_playingBox.get('toggle') == null) {
      _playingBox.put('toggle', 'loop');
    }
    
  }

  void requestPermission() {
    Permission.storage.request();
  }

  final _playingBox = Hive.box('playingBox');
  @override
  Widget build(BuildContext context) {
    if (_playingBox.get('favourite') == null) {
      _playingBox.put(
          'favourite', Provider.of<Favourite>(context).favourite_song);
    }
    Provider.of<Favourite>(context).favourite_song =
        _playingBox.get('favourite');
    if (_playingBox.get('favouriteName') == null) {
      _playingBox.put(
          'favouriteName', Provider.of<Favourite>(context).favourite_songName);
    }
    Provider.of<Favourite>(context).favourite_songName =
        _playingBox.get('favouriteName');
    if (_playingBox.get('favouriteAlbum') == null) {
      _playingBox.put(
          'favouriteAlbum', Provider.of<Favourite>(context).favourite_songAlbum);
    }
    Provider.of<Favourite>(context).favourite_songAlbum =
        _playingBox.get('favouriteAlbum');
    final audioQuerry = Provider.of<CurrentMusic>(context).audioQuerry;
    List songs = Provider.of<CurrentMusic>(context).songs;
    List songNames = Provider.of<CurrentMusic>(context).songNames;
    List songAlbums = Provider.of<CurrentMusic>(context).songAlbums;
    bool isPlaying = Provider.of<CurrentMusic>(
      context,
    ).isPlaying;
    bool hasLast = Provider.of<CurrentMusic>(
      context,
    ).hasLast;

    final audioPlayer = Provider.of<CurrentMusic>(context).audioPlayer;
    // audioPlayer.pause();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 133, 213),
          leading: Icon(Icons.queue_music_outlined),
          title: Text("Stream Wave"),
          bottom: const TabBar(tabs: [
            Tab(
              text: 'songs',
            ),
            Tab(
              text: 'playlist',
            ),
            Tab(
              text: 'folders',
            ),
            Tab(
              text: 'favourite',
            ),
          ]),
        ),
        body: FutureBuilder<List<SongModel>>(
            future: audioQuerry.querySongs(
              sortType: null,
              orderType: OrderType.ASC_OR_SMALLER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true,
            ),
            builder: (context, item) {
              if (item.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (item.data!.isEmpty) {
                return const Center(
                  child: Text("No songs found"),
                );
              }
              for (var i = 0; i < item.data!.length; i++) {
                if (!songs.contains(item.data![i].data)) {
                  songs.add(item.data![i].data);
                  songNames.add(item.data![i].title);
                  songAlbums.add(item.data![i].id);
                }
              }
              return TabBarView(physics: BouncingScrollPhysics(), children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: item.data!.length,
                        itemBuilder: (context, index) {
                          return MusicTile(
                            newTitle: item.data![index].displayNameWOExt,
                            newSubtitle: "${item.data![index].artist}",
                            image: 'assets/images/music.png',
                            index: index,
                            item: item,
                            newOnTap: () {
                              audioPlayer.pause();
                              Provider.of<CurrentMusic>(context, listen: false)
                                  .pause();
                              _playingBox.put(0, index);
                              _playingBox.put(1, item.data![index].title);
                              _playingBox.put('last', true);
                              Provider.of<CurrentMusic>(context, listen: false)
                                  .setLast();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PlayScreen(
                                        audioPlayer: Provider.of<CurrentMusic>(
                                                context,
                                                listen: false)
                                            .audioPlayer,
                                      )));
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
                Column(
                    children: [
                      Text(Provider.of<Favourite>(context).favourite_song.toString()),
                      Text(Provider.of<Favourite>(context).favourite_songAlbum.toString()),
                      Text(Provider.of<Favourite>(context).favourite_songName.toString()),
                      ],
                    ),
                Column(),
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: Provider.of<Favourite>(context)
                            .favourite_song
                            .length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.music_note),
                            title: Text(Provider.of<Favourite>(context)
                                .favourite_songName[index]),
                            subtitle: Text(Provider.of<Favourite>(context)
                                .favourite_songAlbum[index]),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ]);
            }),
        bottomNavigationBar: hasLast
            ? Container(
                alignment: Alignment.center,
                height: 70,
                color: Color.fromARGB(255, 255, 133, 213),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PlayScreen(
                              audioPlayer: Provider.of<CurrentMusic>(context,
                                      listen: false)
                                  .audioPlayer,
                            )));
                  },
                  leading: Album(),
                  title: Text(
                    Provider.of<CurrentMusic>(context).songNames[
                        Provider.of<CurrentMusic>(context, listen: false)
                            .getMusic()],
                    softWrap: true,
                    maxLines: 1,
                  ),
                  trailing: AvatarGlow(
                    glowColor: Colors.white,
                    endRadius: 50,
                    duration: const Duration(seconds: 3),
                    repeat: true,
                    showTwoGlows: true,
                    curve: Curves.easeOutQuad,
                    child: IconButton(
                      iconSize: 40,
                      icon: Icon(Provider.of<CurrentMusic>(context).playIcon),
                      color: Colors.white,
                      onPressed: () {
                        if (isPlaying) {
                          audioPlayer.pause();
                          Provider.of<CurrentMusic>(context, listen: false)
                              .pause();
                          return;
                        } else {
                          Provider.of<CurrentMusic>(context, listen: false)
                              .playIt();
                          return;
                        }
                      },
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
