import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:ijkplayer_example/i18n/i18n.dart';

import 'video_player/video_player.dart';

class NetworkPage extends StatelessWidget {
  final stack = Stack(
    children: <Widget>[
      VideoPlayerPage(url: 'rtsp://192.168.1.160:554', isLive: true),
      //Container(color: Colors.lightBlue,height: 48,),
      SafeArea(
        child: BackButton(
          color: Colors.white,
        ),
      )
    ],
  );

  @override
  StatelessElement createElement() {
    hideStatusBar();
    return super.createElement();
  }

  static void hideStatusBar() async {
    await SystemChrome.setEnabledSystemUIOverlays([]);
  }

  static void showStatusBar() async {
    await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: stack,
    );
  }
}

// the option is copied from ijkplayer example
Set<IjkOption> createAndroidIJKOptions() {
  return <IjkOption>[
    IjkOption(IjkOptionCategory.player, "mediacodec", 1),
    IjkOption(IjkOptionCategory.player, "mediacodec-auto-rotate", 1),
    IjkOption(
        IjkOptionCategory.player, "mediacodec-handle-resolution-change", 1),
    IjkOption(IjkOptionCategory.player, "opensles", 0),
    IjkOption(IjkOptionCategory.player, "overlay-format", 0x32335652),

    IjkOption(IjkOptionCategory.player, "enable-accurate-seek", 1),
    IjkOption(IjkOptionCategory.player, "max-fps", 30),
    IjkOption(IjkOptionCategory.player, "framedrop", 1),
    //IjkOption(IjkOptionCategory.player, "videotoolbox", 1),
    //IjkOption(IjkOptionCategory.player, "videotoolbox-max-frame-width", 1920),
    IjkOption(IjkOptionCategory.player, "max_cached_durtion", 100),
    IjkOption(IjkOptionCategory.player, "infbuf", 1),
    IjkOption(IjkOptionCategory.player, "packet-buffering", 0),

    IjkOption(IjkOptionCategory.format, "probesize", 1024),
    IjkOption(IjkOptionCategory.format, "max-buffer-size", 1024 * 3),
    IjkOption(IjkOptionCategory.format, "analyzeduration", 1),

    IjkOption(IjkOptionCategory.codec, "skip_loop_filter", 0),
    IjkOption(IjkOptionCategory.codec, "skip_frame", 8),
  ].toSet();
}

Set<IjkOption> createiOSIJKOptions() {
  return <IjkOption>[
    IjkOption(IjkOptionCategory.player, "enable-accurate-seek", 1),
    IjkOption(IjkOptionCategory.player, "max-fps", 30),
    IjkOption(IjkOptionCategory.player, "framedrop", 1),
    //IjkOption(IjkOptionCategory.player, "videotoolbox", 1),
    //IjkOption(IjkOptionCategory.player, "videotoolbox-max-frame-width", 1920),
    IjkOption(IjkOptionCategory.player, "max_cached_durtion", 100),
    IjkOption(IjkOptionCategory.player, "infbuf", 1),
    IjkOption(IjkOptionCategory.player, "packet-buffering", 0),

    IjkOption(IjkOptionCategory.format, "probesize", 1024),
    IjkOption(IjkOptionCategory.format, "max-buffer-size", 1024 * 3),
    IjkOption(IjkOptionCategory.format, "analyzeduration", 1),

    IjkOption(IjkOptionCategory.codec, "skip_loop_filter", 0),
    IjkOption(IjkOptionCategory.codec, "skip_frame", 8),
  ].toSet();
}
