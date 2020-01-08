import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

import 'package:flutter/cupertino.dart';
//import 'package:screen/screen.dart';
//import 'package:wr_prober_flutter/utils/common_util.dart';

class VideoPlayerPage extends StatefulWidget {
  final String url;
  final bool isLive;
   final void Function(bool show) onControllerShow;
  VideoPlayerPage({Key key,@required this.url,this.isLive = false, this.onControllerShow}):super(key:key);
  @override
  VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  IjkMediaController mediaController = IjkMediaController();
  
  @override
  initState() {
    super.initState();
    //CommonUtil.enterLandscape();
    setScreenOn();
  }

  setScreenOn() async{
    //await Screen.keepOn(true);
  }

  @override
  VideoPlayerPage get widget => super.widget;

  void setDataSource() async {
    //key.currentState.fullScreen();
    mediaController
        .addIjkPlayerOptions([TargetPlatform.iOS,TargetPlatform.android], createGeneralIJKOptions());
    mediaController
        .addIjkPlayerOptions([TargetPlatform.android], createAndroidIJKOptions());
    mediaController
        .addIjkPlayerOptions([TargetPlatform.iOS], createIOSIJKOptions());
    await mediaController.setNetworkDataSource(
      widget.url,
      autoPlay: true
    );
  }

  @override
  void dispose() {
    debugPrint('video player dispose');
    mediaController.dispose();
    // CommonUtil.exitLandscape();
    // CommonUtil.showStatusBar();
    // Screen.keepOn(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 400,
      // height: 200,
      child: IjkPlayer(
              mediaController: mediaController,
              onPlatformViewCreated: (){
                setDataSource();
              },
              controllerWidgetBuilder: (mediaController) {
                if(widget.isLive) {
                  return Container();
                } else {
                  return DefaultIJKControllerWidget(controller: mediaController,
                  doubleTapPlay: true,
                  showFullScreenButton: false,
                  onShowStatus: widget.onControllerShow,
                  );
                }
              },
            )
    );
  }

  Set<IjkOption> createGeneralIJKOptions() {
    List <IjkOption> list = [
      IjkOption(IjkOptionCategory.player, "enable-accurate-seek", 1),
      IjkOption(IjkOptionCategory.player, "r", 29.97),
     
      IjkOption(IjkOptionCategory.player, "max-fps", 30),
      IjkOption(IjkOptionCategory.player, "framedrop", 1),

      IjkOption(IjkOptionCategory.format, "probesize", 1024),
      IjkOption(IjkOptionCategory.format, "max-buffer-size", 1024 * 3),
      IjkOption(IjkOptionCategory.format, "analyzeduration", 1),
      IjkOption(IjkOptionCategory.codec, "skip_loop_filter", 0),
      IjkOption(IjkOptionCategory.codec, "skip_frame", 8),
    ];
    if(widget.isLive){
      list.addAll([
        IjkOption(IjkOptionCategory.player, "max_cached_durtion", 100),
        IjkOption(IjkOptionCategory.player, "infbuf", 1),
        IjkOption(IjkOptionCategory.player, "packet-buffering", 0),
      ]);
    } else{
      list.addAll([
        IjkOption(IjkOptionCategory.player, "max_cached_durtion", 0),
        IjkOption(IjkOptionCategory.player, "infbuf", 0),
        IjkOption(IjkOptionCategory.player, "packet-buffering", 1),
      ]);
    }
    return list.toSet();
  }

  Set<IjkOption> createAndroidIJKOptions() {
    return <IjkOption>[
      IjkOption(IjkOptionCategory.player, "mediacodec", 1),
      IjkOption(IjkOptionCategory.player, "mediacodec-auto-rotate", 1),
      IjkOption(
          IjkOptionCategory.player, "mediacodec-handle-resolution-change", 1),
      IjkOption(IjkOptionCategory.player, "opensles", 0),
      IjkOption(IjkOptionCategory.player, "overlay-format", 0x32335652),
    ].toSet();
  }

  Set<IjkOption> createIOSIJKOptions() {
    return <IjkOption>[
      IjkOption(IjkOptionCategory.player, "videotoolbox", 1),
      IjkOption(IjkOptionCategory.player, "videotoolbox-max-frame-width", 1920),
    ].toSet();
  }
}
