import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'video_player.dart';
//import 'package:wr_prober_flutter/utils/common_util.dart';

class FullScreenPlayerPage extends StatefulWidget {
  final String url;

  const FullScreenPlayerPage({Key key, this.url}) : super(key: key);

  @override
  _FullScreenPlayerPageState createState() => _FullScreenPlayerPageState();
}

class _FullScreenPlayerPageState extends State<FullScreenPlayerPage> {
  final StreamController<bool> _streamController = StreamController<bool>();

  goBack(BuildContext context) {
    Navigator.pop(context, '');
    //CommonUtil.exitLandscape();
  }

  CupertinoButton backBtn() {
    return CupertinoButton(
      color: Colors.black12,
      padding: EdgeInsets.all(10),
      pressedOpacity: 0.8,
      borderRadius: BorderRadius.all(Radius.circular(40)),
      child: Icon(
        CupertinoIcons.back,
        size: 28,
      ),
      onPressed: () => goBack(context),
    );
}

  @override
  Widget build(BuildContext context) {
    return Stack(
       children: <Widget>[
      VideoPlayerPage(url: widget.url,onControllerShow:(show){
        _streamController.add(show);
      }),
      StreamBuilder(
        stream: _streamController.stream,
        initialData: true,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
          if(snapshot.data) {
            return Positioned(top: 8, left: 8, child: backBtn());
          } else{
            return Container();
          }
        },
      ),
    ],
    );
  }
}