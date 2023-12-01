import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioLearn extends StatefulWidget {
  const AudioLearn({super.key});

  @override
  State<AudioLearn> createState() => _AudioLearnState();
}

class _AudioLearnState extends State<AudioLearn> {
  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() {
    Permission.storage.request();
  }

  final _audioQuerry =  OnAudioQuery();
  final _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("data"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.safety_check))
        ],
      ),
      body: FutureBuilder<List<SongModel>>(
          future: _audioQuerry.querySongs(
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
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(item.data![index].displayNameWOExt),
                subtitle: Text("${item.data![index].artist}"),
                trailing: const Icon(Icons.more_horiz),
                onTap: () async {
                  if (isPlaying) {
                    await _audioPlayer.pause();
                  } else {
                    String? url = item.data![index].data;
                    await _audioPlayer.play(UrlSource(url.toString()));
                  }
                },
              ),
              itemCount: item.data!.length,
            );
          }),
    );
  }
}
