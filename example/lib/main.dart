import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:ijkplayer_example/page/index.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  IjkConfig.isLog = true;
//  IjkConfig.level = LogLevel.verbose;
  await IjkManager.initIJKPlayer();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isInitPlugin = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      isInitPlugin = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitPlugin) {
      return Container();
    }
    return OKToast(
      child: MaterialApp(
        home: IndexPage(),
      ),
    );
  }
}
