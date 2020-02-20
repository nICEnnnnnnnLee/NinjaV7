import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import '../domain/album.dart';
import '../domain/gallery.dart';
import '../domain/urld.dart';
import '../global.dart';
import '../parser/parser.dart';
import '../util/custom_network_image.dart' as NTImage;
import '../util/downloader.dart' as downloader;
import 'drawer.dart';
import 'page_search.dart';
import 'page_download.dart';
import 'page_fullscreen_image.dart';
import 'page_gallery.dart';

part './album/albumViewer.dart';

part './album/appBar.dart';

part './album/scorllIndicator.dart';

class AlbumPage extends StatefulWidget {
  final URLd urld;

  AlbumPage({Key key, this.urld}) : super(key: key);

  @override
  _AlbumPageState createState() => _AlbumPageState(urld: urld);
}

class _AlbumPageState extends State<AlbumPage> {
  final downloader.DownLoadManager manager = downloader.DownLoadManager();
  final URLd urld;

  Album album;

  // 当前显示的图片序号
  int currentPicIndex = 0;
  ScrollController _scrollController = new ScrollController();

  //显示进度条
  bool isDisplayDraggingLine = false;

  //是否正在加载内容（拖拽完毕后）
  bool isLoadingWhenDrag = false;

  //是否显示appBar
  bool isDiplayAppbar = true;

  _AlbumPageState({Key key, @required this.urld}) {
    album = Album(urld: urld);
  }

  Future _gotoPage(int index) async {
    if (album.pics.length < album.totalSize) {
      isLoadingWhenDrag = true;
      setState(() {});
      await Parsers.loadAlbumAll(album);
    }
    final position = _scrollController.position;
    final picWidth = MediaQuery.of(context).size.width;
    double offset = index * picWidth;
    if (offset > position.maxScrollExtent) {
      offset = position.maxScrollExtent;
      currentPicIndex = (offset / picWidth).floor();
    }
    _scrollController.jumpTo(offset);
    isLoadingWhenDrag = false;
    setState(() {});
//    _scrollController.animateTo(offset,
//        duration: kTabScrollDuration, curve: Curves.ease);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.lightBlue,
          drawer: CustomDrawer(
            openUrl: () {
              int page = album.currentPage == 0 ? 1 : album.currentPage;
              final url = Parsers.genWebLink(urld, page);
              canLaunch(url).then((valid) {
                if (valid) launch(url);
              });
            },
            copyUrl: () {
              int page = album.currentPage == 0 ? 1 : album.currentPage;
              Clipboard.setData(
                  ClipboardData(text: Parsers.genWebLink(urld, page)));
            },
            shareUrl: (){
//              Share.share(json.encode(album));
              int page = album.currentPage == 0 ? 1 : album.currentPage;
              Share.share( Parsers.genWebLink(urld, page));
            },
          ),
          appBar: !isDiplayAppbar
              ? null
              : AppBarW(
                  album: album,
                  context: context,
                  onTapBtnDownload: () {
                    manager.addTask(album, onAlbumDone: (Album album) {
                      if (mounted) {
                        album.isDone = true;
                        setState(() {});
                      }
                    });
                    setState(() {});
                  },
                  onTapBtnManage: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => DownloadPage()));
                  },
                  onTapBtnMark: () {
                    AlbumPreview pre = AlbumPreview(
                        album.title, urld, album.pics[0],
                        character: album.tags);
                    Settings.triggerBookmark(pre);
                    album.isBookmarked = !album.isBookmarked;
                    setState(() {});
                  },
                  onTapBtnSearch: () {
                    showSearch(context: context, delegate: SearchBarDelegate());
                  },
                ).build(),
          body: Center(
            child: buildStack(),
          ),
        ));
  }

  // 第一层显示图片集
  // 第二层显示进度条（带有拖拽功能）
  // 第三层显示拖拽完毕后的等待页面
  Widget buildStack() {
    return Stack(
      alignment: const FractionalOffset(0.5, 0.98),
      children: <Widget>[
        AlbumViewer(
          album: album,
          scrollController: _scrollController,
          onTapPic: () {
//            print("图片被单击");
            isDisplayDraggingLine = !isDisplayDraggingLine;
            setState(() {});
          },
          onDoubleTapPic: () {
//            print("图片被双击");
//            isDiplayAppbar = !isDiplayAppbar;
//            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            setState(() {
              if (album.rSeed[currentPicIndex] != null)
                album.rSeed[currentPicIndex]++;
              else
                album.rSeed[currentPicIndex] = 0;
            });
            setState(() {});
          },
          onLongPressPic: () {
            //Clipboard.setData(ClipboardData(text: album.urld.urlWithProtocol));
          },
          onGlobalRefreshNeeded: (int index) {
            currentPicIndex = index;
            setState(() {});
          },
          isLoadingWhenDrag: isLoadingWhenDrag,
        ),
        Offstage(
          offstage: !isDisplayDraggingLine,
          child: ScrollIndicator(
            currentPicIndex: currentPicIndex,
            totalSize: album.totalSize,
            onHorizontalDragStart: (drag) {},
            onHorizontalDragUpdate: (drag, index) {
              currentPicIndex = index;
              setState(() {});
            },
            onHorizontalDragEnd: (drag) {
              isDisplayDraggingLine = false;
              _gotoPage(currentPicIndex);
              setState(() {});
            },
          ),
        ),
        Offstage(
          offstage: !isLoadingWhenDrag,
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            height: double.infinity,
            width: double.infinity,
            child: new CircularProgressIndicator(
              strokeWidth: 4.0,
              backgroundColor: Colors.transparent,
              // value: 0.2,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
