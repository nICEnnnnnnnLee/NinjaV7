import 'dart:convert';

import 'package:flutter_app_picviewer/global.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'dart:io';
import '../util/custom_http.dart' as http;
import '../domain/album.dart';
import '../domain/gallery.dart';
import '../util/downloader.dart';
import '../util/custom_log_util.dart';
import '../domain/urld.dart';

part '_bilibili_guichu.dart';

abstract class Parsers {
  static DownLoadManager manager = DownLoadManager();
  static List<Parsers> parsers = [
    ParserBiliGuichu1(),
  ];

   static Future loadAlbumAll(Album album) async {
    bool isSuc = await loadAlbumNextPage(album);
    while (isSuc) {
      isSuc = await loadAlbumNextPage(album);
    }
  }

  static  Future<bool> loadAlbumNextPage(Album album, {bool isDone}) async {
    if (album.totalPage > 0 && album.currentPage == album.totalPage) return false;
    album.currentPage++;
    bool result =  await Parsers.loadAlbum(album, album.currentPage);
    if(result && isDone == true && album.currentPage == 1){
      String path = await getSaveRootDir() + "/${album.urld.realDomain}/${album.title}/info.json";
      final file = File(path);
      bool isFileExists = await file.exists();
//      print("检查到已经下载完毕，自动装载中 ${file.path}: $isFileExists");
      if(isFileExists){
        final previewPic = album.pics[0];
        album.pics = new List(album.totalSize);
        album.pics[0] = previewPic;
//        print("查询 ${currentPage -1}页，返回结果 $result");
        album.currentPage = album.totalPage;

        return true;
      }
    }
//    print("查询 ${album.currentPage -1}页，返回结果 $result");
    return result;
  }

  static String genWebLink(URLd urld, int page){
    for (int i = 0; i < parsers.length; i++) {
      if (parsers[i].valid(urld)) {
        return parsers[i]._genWebLink(urld, page);
      }
    }
    return null;
  }

  static Future<bool> loadAlbum(Album album, int currentPage) async {
    for (int i = 0; i < parsers.length; i++) {
      if (parsers[i].valid(album.urld)) {
        return parsers[i]._loadAlbum(album, currentPage);
      }
    }
    return false;
  }

  static Future<int> loadGallery(
      URLd urLd, int currentPage, List<AlbumPreview> albumsPreview) async {
    for (int i = 0; i < parsers.length; i++) {
      if (parsers[i].valid(urLd)) {
        return parsers[i]._loadGallery(urLd, albumsPreview, currentPage);
      }
    }
    return 0;
  }

  static ParseResult parse(String query) {
    RegExp reg = new RegExp(r"https?://([^/]+)(/?.*)$");
    Match m = reg.firstMatch(query);
    if (m != null) {
      URLd urdToParse = URLd(path: m.group(2), domain: m.group(1));
      for (int i = 0; i < parsers.length; i++) {
        if (parsers[i].valid(urdToParse)) {
          return parsers[i]._parseResultOf(urdToParse);
        }
      }
    }
    return ParseResult(ResultType.NONE);
  }

  static Future<List<Gallery>> search(String domain, String keyWord) {
    for (int i = 0; i < parsers.length; i++) {
      if (parsers[i].valid(URLd(path: "/search", domain: domain))) {
        return parsers[i]._search(keyWord);
      }
    }
    return null;
  }

  bool valid(URLd urld);

  Future<bool> _loadAlbum(Album album, int currentPage);

  Future<int> _loadGallery(
    URLd urLd,
    List<AlbumPreview> albumsPreview,
    int currentPage,
  );

  // 如果没有搜索功能，返回null
  Future<List<Gallery>> _search(String keyWord);

  ParseResult _parseResultOf(URLd urdToParse);

  String _genWebLink(URLd urld, int page);
}

enum ResultType { GALLERY, ALBUM, NONE }

class ParseResult {
  ResultType type;
  String domain;
  String path;
  int currentPage;

  ParseResult(this.type, {this.domain, this.path, this.currentPage});
}
