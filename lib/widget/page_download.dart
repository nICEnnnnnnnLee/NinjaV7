import 'package:flutter/material.dart';
import 'package:flutter_app_picviewer/util/downloader.dart'; // as downloader;
import 'package:flutter_app_picviewer/domain/album.dart';
import 'package:flutter_app_picviewer/util/custom_network_image.dart' as NTImage;
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_app_picviewer/widget/page_album.dart';
import '../global.dart';
import 'dart:async';

class DownloadPage extends StatefulWidget {
  DownloadPage({
    Key key,
  }) : super(key: key);

  @override
  _DownloadPage createState() => _DownloadPage();
}

class _DownloadPage extends State<DownloadPage> {
  DownLoadManager manager = DownLoadManager();
  Timer timer;

  _DownloadPage({
    Key key,
  }) : super();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (timer.isActive) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
//      backgroundColor: Colors.lightBlue,
          appBar: AppBar(
//              leading:
//              IconButton(
//                  icon: Icon(Icons.home),
//                  onPressed: () {
//                    Navigator.of(context).popUntil(ModalRoute.withName("/home"));
//                  })
//              ,
              title: Text("下载管理"),
              actions: [
                IconButton(
                    icon: Icon(Icons.stop),
                    tooltip: '停止所有下载',
                    onPressed: () {
                      manager.stopAll();
                      setState(() {});
                    }),
                IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(Icons.cancel),
                    tooltip: '清空已完成',
                    onPressed: () {
                      manager.clearHistory();
                      setState(() {});
                    }),
              ]),
          body: manager.albumDone.length + manager.albumToDown.length == 0? Center(
            child: Text("什么也没有哦"),
          ): ListView.builder(
            itemCount: manager.albumDone.length + manager.albumToDown.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < manager.albumToDown.length) {
                var album = manager.albumToDown[index];
                return albumDisplay(album, true);
              } else {
                // 取manager.albumDone的倒数index
                index -= manager.albumToDown.length;
                index = manager.albumDone.length - index - 1;
                var album = manager.albumDone[index];
                return albumDisplay(album, false);
              }
            },
          )),
    );
  }

  Widget _buttonsDisplay(Album album, bool isDownloading) {
    return IconButton(
        padding: EdgeInsets.all(0.0),
        icon: Icon(
          isDownloading ? Icons.stop : Icons.cancel,
          size: 30,
        ),
        onPressed: () {
          if (isDownloading) {
            print("删除正在下载的任务");
            manager.cancel(album);
          } else {
            print("删除已完成的任务");
            manager.removeHistory(album);
          }
          setState(() {});
        });
  }

  Widget albumDisplay(Album album, bool isDownloading) {
    var tips;
    if (isDownloading || album.downloaded > 0) {
      tips = "${album.downloaded}/${album.totalSize}";
    } else {
      tips = "共${album.totalSize}张";
    }
    var container = Container(
      margin: EdgeInsets.fromLTRB(5, 10, 10, 5),
      decoration: new BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.grey,
              offset: Offset(2.0, 2.0),
              blurRadius: 10.0,
              spreadRadius: 2.0),
//                  BoxShadow(color: Colors.grey, offset: Offset(1.0, 1.0)),
          BoxShadow(
              color: isDownloading
                  ? Color.fromRGBO(230, 230, 230, 1)
                  : Colors.white)
        ],
        borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 90,
            height: 110,
            child: MaterialButton(
                padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                child: NTImage.FadeInImage.memoryNetwork(
                  image: album.pics[0],
                  sdcache: true,
                  placeholder: kTransparentImage,
                  fit: BoxFit.cover,
                  findProxy: findProxy,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumPage(urld: album.urld,
                        ),
                      ));
                }),
            padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(5, 8, 20, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: new BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  height: 40,
                  width: 220,
                  child: Text(album.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                Container(
                  height: 20,
                  width: 220,
                  child: Text(album.tags,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey)),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      height: 40,
                      width: 80,
                      alignment: Alignment.centerLeft,
                      child: Text(" ${album.urld.siteName} ",
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      height: 40,
                      width: 80,
                      alignment: Alignment.centerRight,
                      child: Text(tips),
                    ),
                    Container(
                      height: 40,
//                      width: 20,
                      alignment: Alignment.topRight,
                      child: _buttonsDisplay(album, isDownloading),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );

    return container;
  }
}
