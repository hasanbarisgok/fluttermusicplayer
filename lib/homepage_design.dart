import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class HomePageDesign extends StatefulWidget {
  const HomePageDesign({Key? key}) : super(key: key);

  @override
  State<HomePageDesign> createState() => _HomePageDesignState();
}

class _HomePageDesignState extends State<HomePageDesign> {
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  double screenHeight = 0;
  double screenWidth = 0;

  final List<Widget> bottomNavigationBar = [
    IconButton(
      onPressed: () {},
      icon: Icon(Icons.autorenew_rounded),
      color: Colors.white,
    ),
    IconButton(
      onPressed: () {},
      icon: Icon(Icons.favorite_outline_rounded),
      color: Colors.white,
    ),
    IconButton(
      onPressed: () {},
      icon: Icon(Icons.menu_rounded),
      color: Colors.white,
    ),
    IconButton(
      onPressed: () {},
      icon: Icon(Icons.bookmark_border),
      color: Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    setupPlaylist();
  }

  void setupPlaylist() async {
    await audioPlayer.open(
        Playlist(audios: [
          Audio('assets/uryan.mp3',
              metas: Metas(
                  title: 'Uryan Geldim',
                  artist: 'Cem Karaca',
                  image: MetasImage.asset('assets/polat.jpg'))),
          Audio('assets/kvp.mp3',
              metas: Metas(
                  title: 'Tanridan Diledim',
                  artist: 'KVP',
                  image: MetasImage.asset('assets/elif.jpg'))),
        ]),
        autoStart: false,
        loopMode: LoopMode.playlist);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  Widget audioImage(RealtimePlayingInfos realtimePlayingInfos) {
    return Container(
      height: screenHeight * 0.3,
      width: screenWidth * 0.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          realtimePlayingInfos.current!.audio.audio.metas.image!.path,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget titleText(RealtimePlayingInfos realtimePlayingInfos) {
    return Text(
      realtimePlayingInfos.current!.audio.audio.metas.title!,
      style:
          TextStyle(fontSize: 35, color: Colors.white, fontFamily: 'Catamaran'),
    );
  }

  Widget artistText(RealtimePlayingInfos realtimePlayingInfos) {
    return Text(
      realtimePlayingInfos.current!.audio.audio.metas.artist!,
      style: TextStyle(
        fontFamily: 'Catamaran',
        fontSize: 20,
        color: Colors.grey,
      ),
    );
  }

  //Playbar Kismi:

  Widget playBar(RealtimePlayingInfos realtimePlayingInfos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => audioPlayer.previous(),
          icon: Icon(Icons.skip_previous_rounded),
          iconSize: screenHeight * 0.04,
          color: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        IconButton(
          onPressed: () => audioPlayer.playOrPause(),
          icon: Icon(realtimePlayingInfos.isPlaying
              ? Icons.pause_circle_filled_rounded
              : Icons.play_circle_fill_rounded),
          iconSize: screenHeight * 0.08,
          color: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        IconButton(
          onPressed: () => audioPlayer.next(),
          icon: Icon(Icons.skip_next_rounded),
          iconSize: screenHeight * 0.04,
          color: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        )
      ],
    );
  }

  Widget timestamps(RealtimePlayingInfos realtimePlayingInfos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          transformString(realtimePlayingInfos.currentPosition.inSeconds),
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(width: screenWidth * 0.7),
        Text(
          transformString(realtimePlayingInfos.duration.inSeconds),
          style: TextStyle(color: Colors.grey),
        )
      ],
    );
  }

  //stringleri int formata cevirmek icin:: dd:ss gibi
  String transformString(int seconds) {
    String minuteString =
        '${(seconds / 60).floor() < 10 ? 0 : ''}${(seconds / 60).floor()}';
    String secondString = '${seconds % 60 < 10 ? 0 : ''}${seconds % 60}';
    return '$minuteString:$secondString';
  }

  //Slider icin

  Widget slider(RealtimePlayingInfos realtimePlayingInfos) {
    return Stack(
      children: [
        Positioned.fill(
            child: Container(
          height: screenHeight * 0.3,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xff1c1c1e),
            Color(0xff1c1c1e),
            Colors.black,
            Colors.black,
          ], stops: [
            0.0,
            0.55,
            0.55,
            1.0
          ], end: Alignment.bottomCenter, begin: Alignment.topCenter)),
        )),
        SliderTheme(
            data: SliderThemeData(
              trackShape: CustomTrackShape(),
              thumbColor: Colors.white,
              activeTrackColor: Color(0xffe45923),
              inactiveTrackColor: Colors.grey[800],
              overlayColor: Colors.transparent,
            ),
            child: Slider.adaptive(
                value:
                    realtimePlayingInfos.currentPosition.inSeconds.toDouble(),
                max: realtimePlayingInfos.duration.inSeconds.toDouble() + 3,
                min: -3,
                onChanged: (value) {
                  if (value <= 0) {
                    audioPlayer.seek(Duration(seconds: 0));
                  } else if (value >= realtimePlayingInfos.duration.inSeconds) {
                    audioPlayer.seek(realtimePlayingInfos.duration);
                  } else {
                    audioPlayer.seek(Duration(seconds: value.toInt()));
                  }
                }))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xff1c1c1e),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: SizedBox(
          height: screenHeight * 0.15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: bottomNavigationBar,
          ),
        ),
      ),
      body: audioPlayer.builderRealtimePlayingInfos(
          builder: (context, realtimePlayingInfos) {
        if (realtimePlayingInfos != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              audioImage(realtimePlayingInfos),
              SizedBox(height: screenHeight * 0.05),
              titleText(realtimePlayingInfos),
              SizedBox(height: screenHeight * 0.01),
              artistText(realtimePlayingInfos),
              SizedBox(height: screenHeight * 0.05),
              playBar(realtimePlayingInfos),
              SizedBox(height: screenHeight * 0.05),
              timestamps(realtimePlayingInfos),
              slider(realtimePlayingInfos),
            ],
          );
        } else {
          return Column();
        }
      }),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPrefferedRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
