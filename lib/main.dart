import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import './domain/urld.dart';
import './global.dart';
import './widget/page_album.dart';
import './widget/page_gallery.dart';

void main() {
  runApp(
      MyApp(type: "gallery", urld: URLd(path: "/", domain: "www.javbus.com")));
}

Future<bool> requestPermission() async {
  // 申请权限
//  Map<PermissionGroup, PermissionStatus> permissions =
  await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  // 申请结果
  PermissionStatus permission =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  if (permission != PermissionStatus.granted) {
    SystemNavigator.pop();
    return false;
  } else {
    print("requestPermission allowed");
    return true;
  }
}

class MyApp extends StatelessWidget {
  final String type;
  final URLd urld;

  MyApp({Key key, this.type, this.urld}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '爱好app',
//      routes: {
//        "/home": (context) => GalleryPage(urld:URLd(domain: 'm.nvshens.net', path: '/gallery/')),
//      },
//      initialRoute: '/home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CountPage(initialCount: 5),
//      home: HostPage(),
    );
  }
}

class CountPage extends StatefulWidget {
  const CountPage({Key key, this.initialCount}) : super(key: key);
  final initialCount;

  @override
  _CountPageState createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  final Color _transparent = Colors.transparent;
  final _ad = "这里是一个广告";

  int count;
  Color circleColor;
  Timer _timer;

  String _adToShow = "";
  bool isHomeSettingExist;
  bool isGoingHome = false;

  @override
  void initState() {
    super.initState();
    circleColor = _transparent;
    count = widget.initialCount;
    requestPermission().then((result) {
      if (result) {
        Settings.init().then((prefs) {
          isHomeSettingExist = Settings.getHome();
          if (!Settings.showAD()) _goHome(invokeFromTimer: false);
        });
      }
    });

    _timer = Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
      count--;
      circleColor = null;
      if (_ad.length - count + 1 >= 0 && _ad.length - count + 1 <= _ad.length) {
        _adToShow = _ad.substring(0, _ad.length - count + 1);
      }
      if (count < 1) {
        circleColor = _transparent;
        _goHome(invokeFromTimer: true);
      }
      setState(() {});
    });
  }

  void _goHome({bool invokeFromTimer}) {
    if (isGoingHome) return;
    if (invokeFromTimer && isHomeSettingExist == null) return;
    if (!invokeFromTimer && isHomeSettingExist == false) return;

    isGoingHome = true;
    _jumpPage(type: Settings.getHomeType(), urld: Settings.getHomeUrld());
  }

  void _jumpPage({type, urld}) {
    if (type == "gallery") {
      Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              settings: RouteSettings(name: "/home", isInitialRoute: true),
              builder: (context) => GalleryPage(urld: urld)));
    } else {
      Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              settings: RouteSettings(name: "/home", isInitialRoute: true),
              builder: (context) => AlbumPage(urld: urld)));
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Stack(
          alignment: const FractionalOffset(0.5, 0.2),
          children: <Widget>[
            Center(
                child: Stack(
              children: <Widget>[
//                CircleAvatar(
//                  radius: 80,
//                  backgroundColor: circleColor,
//                ),
                Text(
                  "$count",
                  style: TextStyle(fontSize: 50, color: circleColor),
                ),
//                AnimatedOpacity(
//                  duration: Duration(milliseconds: 500),
//                  opacity: _opacity,
//                  child:
//                ),
              ],
              alignment: Alignment.center,
            )),
            Container(
                child: Text(
              _adToShow,
              style: TextStyle(fontSize: 40),
            )),
          ],
        ));
  }
}
