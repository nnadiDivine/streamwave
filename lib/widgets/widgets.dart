import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:streamwave/providers/current_music.dart';

class MusicTile extends StatefulWidget {
  MusicTile({
    Key? key,
    required this.newTitle,
    required this.newSubtitle,
    required this.image,
    required this.item,
    required this.index,
    this.isFavorite = false,
    this.newOnTap,
  }) : super(key: key);
  final String newTitle, newSubtitle, image;
  var item;
  final int index;
  bool isFavorite;
  VoidCallback? newOnTap;

  @override
  State<MusicTile> createState() => _MusicTileState();
}

class _MusicTileState extends State<MusicTile> {
  bool _isFavorite = false;
  @override
  void initState() {
    setState(() {
      _isFavorite = widget.isFavorite;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.newOnTap,
      leading: QueryArtworkWidget(
        nullArtworkWidget: Image.asset('assets/images/music.png'),
        id: widget.item.data![widget.index].id,
        type: ArtworkType.AUDIO,
      ),
      title: Text(
        widget.newTitle,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(widget.newSubtitle),
      // trailing: 
    );
  }
}
