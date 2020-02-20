import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/album.dart';
import '../domain/gallery.dart';
import '../domain/urld.dart';
import '../global.dart';
import '../parser/parser.dart';
import '../util/custom_network_image.dart' as NTImage;
import '../util/downloader.dart';
import 'drawer.dart';
import 'page_album.dart';
import 'page_download.dart';
import 'page_search.dart';

part 'gallery/galleryViewer.dart';

class GalleryPage extends StatefulWidget {
  final URLd urld;
  final int currentPage;

  GalleryPage({Key key, @required this.urld, this.currentPage = 0})
      : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final List<AlbumPreview> albumsPreview = [];
  final man = DownLoadManager();

  String defaultTitle;
  String finalTitle;

  double gridRatio = 0.55;
  bool isInSelectMode = false;
  int currentPage;
  List<bool> isSelectedLists;
  double tipOpacityLevel = 0;
  String tipToShow = "再按一遍后退键退出!!";
  Timer tipDisplayControlTimer;
  var lastTimePopped = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    currentPage = widget.currentPage;
  }

  @override
  void dispose() {
    if (tipDisplayControlTimer != null && tipDisplayControlTimer.isActive) {
      tipDisplayControlTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTitle == null) {
      defaultTitle = widget.urld.siteName;
    }
    if (albumsPreview.length > 0 && finalTitle == null) {
      finalTitle = albumsPreview[0].character;
    }
    String displayTitle = finalTitle == null ? defaultTitle : finalTitle;
    return WillPopScope(
        onWillPop: () async {
//          print("gallery页面返回 isInSelectMode ${isInSelectMode}");
          if (isInSelectMode) {
            isInSelectMode = false;
            albumsPreview.forEach((ele) {
              if (ele.isSelected) {
                ele.isSelected = false;
              }
            });
            setState(() {});
            return false;
          }
          if (!Navigator.canPop(context)) {
            final currentTime = DateTime.now().millisecondsSinceEpoch;
            if (currentTime - lastTimePopped < 2000) {
              return true;
            } else {
              lastTimePopped = currentTime;
              if (tipOpacityLevel == 0) {
                tipToShow = "再按一遍后退键退出!!";
                tipOpacityLevel = 1;
                setState(() {});
                tipDisplayControlTimer = new Timer(Duration(seconds: 2), () {
                  tipOpacityLevel = 0;
                  setState(() {});
                });
              }
              return false;
            }
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.lightBlue,
          drawer: CustomDrawer(
            openUrl: () {
              final page = currentPage == 0 ? 1 : currentPage;
              final url = Parsers.genWebLink(widget.urld, page);
              canLaunch(url).then((valid) {
                if (valid) launch(url);
              });
            },
            copyUrl: () {
              final page = currentPage == 0 ? 1 : currentPage;
              Clipboard.setData(
                  ClipboardData(text: Parsers.genWebLink(widget.urld, page)));
            },
            shareUrl: () {
              final page = currentPage == 0 ? 1 : currentPage;
              Share.share(Parsers.genWebLink(widget.urld, page));
            },
          ),
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Settings.setHome(
                      "gallery", widget.urld.realDomain, widget.urld.path);
                  tipOpacityLevel = 1;
                  tipToShow = "已将当前设为主页，重启后生效";
                  setState(() {});
                  tipDisplayControlTimer = new Timer(Duration(seconds: 2), () {
                    tipOpacityLevel = 0;
                    setState(() {});
                  });
                  //Navigator.of(context).popUntil(ModalRoute.withName("/home"));
                }),
            title: Text(
              displayTitle,
            ),
            actions: appBarButtons(),
          ),
          body: GalleryViewer(
            urld: widget.urld,
            initialPage: widget.currentPage,
            isInSelectMode: isInSelectMode,
            albumsPreview: albumsPreview,
            tipOpacityLevel: tipOpacityLevel,
            tipToShow: tipToShow,
            gridRatio: gridRatio,
            onLongPressPic: (int index) {
              isInSelectMode = !isInSelectMode;
              setState(() {});
            },
            onGlobalRefreshNeeded: (currentPage) => setState(() {
              this.currentPage = currentPage;
            }),
          ),
        ));
  }

  List<Widget> appBarButtons() {
    Gallery gallery = Gallery(
      title: finalTitle,
      urld: widget.urld,
    );
    bool isFavorite = favorites.containsValue(gallery);
    final btnFavorite = (IconButton(
        icon: isFavorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
        tooltip: isFavorite ? '取消收藏' : '收藏',
        onPressed: () {
          Settings.triggerFavorite(gallery);
          setState(() {});
        }));
    final btnManage = (IconButton(
        icon: Icon(Icons.brightness_high),
        tooltip: '下载管理',
        onPressed: () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => DownloadPage()));
        }));
    final btnRatioSwitch = (IconButton(
        icon: Icon(Icons.swap_horiz),
        tooltip: '网格宽高比例切换',
        onPressed: () {
          if(gridRatio == 0.55)
            gridRatio = 0.7;
          else if(gridRatio == 0.7)
            gridRatio = 0.95;
          else
            gridRatio = 0.55;
          setState(() {});
        }));
    final btnSearch = (IconButton(
        icon: Icon(Icons.search),
        tooltip: '查找页面',
        onPressed: () {
          showSearch(context: context, delegate: SearchBarDelegate());
        }));

    if (!isInSelectMode) {
      return [btnFavorite, btnManage, btnRatioSwitch, btnSearch];
    }
    final btnDownload = (IconButton(
        icon: Icon(Icons.file_download),
        tooltip: '下载选中项',
        onPressed: () {
          albumsPreview.forEach((ele) {
            if (ele.isSelected) {
              ele.isToDown = true;
              man.addTask(Album(urld: ele.urld), onAlbumDone: (album) {
                ele.isToDown = false;
                ele.isDone = true;
                setState(() {});
              });
              ele.isSelected = false;
            }
          });
          isInSelectMode = false;
          setState(() {});
        }));
    final btnUnbook = (IconButton(
        icon: Icon(Icons.bookmark_border),
        tooltip: '取消标签',
        onPressed: () {
          albumsPreview.forEach((ele) {
            if (ele.isSelected) {
              ele.isBookmarked = false;
              Settings.removeBookmark(ele);
              ele.isSelected = false;
            }
          });
//          writeBookmarks();
          isInSelectMode = false;
          setState(() {});
        }));
    final btnBook = (IconButton(
        icon: Icon(Icons.bookmark),
        tooltip: '标签',
        onPressed: () {
          albumsPreview.forEach((ele) {
            if (ele.isSelected) {
              ele.isBookmarked = true;
              Settings.addBookmark(ele);
              ele.isSelected = false;
            }
          });
//          writeBookmarks();
          isInSelectMode = false;
          setState(() {});
        }));
    return [
      btnDownload,
      btnUnbook,
      btnBook,
//      btnFavorite,
//      btnManage,
//      btnRatioSwitch,
//      btnSearch
    ];
  }
}
