//import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../domain/album.dart';
import '../domain/gallery.dart';
import '../global.dart';
import '../parser/parser.dart';

class DownLoadManager {
  Set<String> urlsToDown = new Set();
  Set<String> urlsDone = new Set();
  List<Album> albumToDown = [];
  List<Album> albumDone = [];
  bool isRunning = false;

  factory DownLoadManager() => _getInstance();
  static DownLoadManager _instance;

  DownLoadManager._();

  static DownLoadManager _getInstance() {
    if (_instance == null) {
      _instance = DownLoadManager._();
    }
    return _instance;
  }

  void clearHistory() {
    albumDone.clear();
    urlsDone.clear();
  }

  Future<DownLoadManager> addTask(
    Album album, {
    Function(Album album) onAlbumDone,
    Function(Album album) onAlbumCancel,
    Function(Album album, int index) onPicDone,
  }) async {
//    print("当前任务在下载列表里: ${urlsToDown.contains(album.urld.urlWithoutProtocol)}");
//    print("当前任务在完成列表里: ${urlsDone.contains(album.urld.urlWithoutProtocol)}");
    if (!urlsToDown.contains(album.urld.urlWithoutProtocol) &&
        !urlsDone.contains(album.urld.urlWithoutProtocol)) {
      // 确保已经含有基本信息再加入列表,防止显示错误
      if (album.pics.length == 0) {
        await Parsers.loadAlbumNextPage(album);
      }
      albumToDown.add(album);
      urlsToDown.add(album.urld.urlWithoutProtocol);
    }
//    print("downloader : ${album.urld.urlWithoutProtocol}加入下载任务");
    run(
        onAlbumDone: onAlbumDone,
        onAlbumCancel: onAlbumCancel,
        onPicDone: onPicDone);
    return this;
  }

  Future<DownLoadManager> run({
    Function(Album album) onAlbumDone,
    Function(Album album) onAlbumCancel,
    Function(Album album, int index) onPicDone,
  }) async {
    if (isRunning) return this;
    isRunning = true;
    while (isRunning && albumToDown.length > 0) {
      print("downloader : ${albumToDown[0].urld.urlWithoutProtocol}开始下载");
      albumToDown[0].stop = false;
      await downloadAlbum(albumToDown[0],
          onAlbumDone: onAlbumDone, onPicDone: onPicDone);
      print("downloader : ${albumToDown[0].urld.urlWithoutProtocol}下载完毕");

      urlsDone.add(albumToDown[0].urld.urlWithoutProtocol);
      albumDone.add(albumToDown[0]);
      urlsToDown.remove(albumToDown[0].urld.urlWithoutProtocol);
      albumToDown.removeAt(0);
    }
    isRunning = false;
    return this;
  }

  Future<DownLoadManager> cancel(Album album) async {
    if (albumToDown.contains(album)) {
      album.stop = true;
      albumToDown.remove(album);
      urlsToDown.remove(album);
    }
    return this;
  }

  void removeHistory(Album album) {
    albumDone.remove(album);
    urlsDone.remove(album.urld.urlWithoutProtocol);
  }

  void stopAll() {
    if (albumToDown.length > 0) {
      albumToDown[0].stop = true;
      albumToDown.clear();
      urlsToDown.clear();
    }
    isRunning = false;
  }

  bool isDownloading(String url) {
    return isRunning &&
        albumToDown.length > 0 &&
        albumToDown[0].urld.urlWithoutProtocol == url;
  }

  bool isFinished(String url) {
    return urlsDone.contains(url);
  }

  bool isWaiting(String url) {
//    if(urlsToDown.length > 0){
//      print("${urlsToDown.toList()[0]}");
//    }
//    print("isWaiting ? $url");
    return urlsToDown.contains(url);
  }

  void check4ToDo(AlbumPreview albumPreview) {
    // 是否在下载队列中
    albumPreview.isToDown =
        urlsToDown.contains(albumPreview.urld.urlWithoutProtocol) ||
            urlsDone.contains(albumPreview.urld.urlWithoutProtocol);
  }

  void check4Done(AlbumPreview albumPreview) {
//    print("查询${albumPreview.urld.realDomain} ${albumPreview.urld.path} 是否下载过");
    // 是否已经下载
//    String saveRootDir = await getSaveRootDir() +
//        "/${albumPreview.domain}/${albumPreview.title}";
//    albumPreview.isDone = await File("$saveRootDir/done").exists();
    albumPreview.isDone = downloadedList.containsValue(albumPreview.urld);
  }
}

//是否已经尝试下载过
Future<bool> isDownloaded(Album album) async {
//  print("查询${album.urld.realDomain} ${album.urld.path} 是否下载过");
  if (downloadedList.containsValue(album.urld)) return true;
  return false;
//  String saveRootDir =
//      await getSaveRootDir() + "/${album.urld.realDomain}/${album.title}";
//  return File("$saveRootDir/done").exists();
}

// 下载整个Album
Future downloadAlbum(
  Album album, {
  Function(Album album) onAlbumDone,
  Function(Album album) onAlbumCancel,
  Function(Album album, int index) onPicDone,
}) async {
  album.downloaded = 0;
  if (album.pics.length == 0) await Parsers.loadAlbumNextPage(album);
  // 创建文件夹
  String saveRootDir =
      await getSaveRootDir() + "/${album.urld.realDomain}/${album.title}";
  var dir = Directory(saveRootDir);
  if (!await dir.exists()) dir.createSync(recursive: true);

  // 获取所有链接
//  Album albumNew = Album(
//      domain: album.domain, url: album.url, currentPage: album.currentPage);
//  albumNew.pics = List.from(album.pics.whereType<String>());
  Album albumNew = album;
  try{
    await Parsers.loadAlbumAll(album);

    for (int i = 0; i < albumNew.pics.length; i++) {
      int result = await downloadPic(albumNew.pics[i], "/$i.jpg",
          saveRootDir: saveRootDir);
      if(result == 200 || result == 404){
        // 404是网站的问题，应该算作成功
        albumNew.downloaded++;
      }else{
//      print("下载失败 error $result");
      }
      if (onPicDone != null) {
        onPicDone(albumNew, i);
      }
      if (albumNew.stop) break;
    }
  }catch(e){
    print(e);
    albumNew.stop = true;
  }

  if(albumNew.downloaded == albumNew.totalSize){
    // 打上记号,表明已经下载成功
//    print("downloade : $saveRootDir/done文件尝试建立");
    await File("$saveRootDir/done").create();
    await File("$saveRootDir/info.json").writeAsString(json.encode(album));
    String key = Settings.keyOfDownloaded(albumNew);
    if (!downloadedList.containsKey(key)) {
      Settings.addDownloaded(album.urld);
//      downloadedList[key] = ();
//      await writeDownloaded(urld: album.urld);
    }
  }
  if (onAlbumDone != null) {
    onAlbumDone(album);
  }
}

// 下载单个图片
Future<int> downloadPic(String url, String savePath,
    {String saveRootDir}) async {
  if (saveRootDir == null) saveRootDir = await getSaveRootDir();

  // 找到保存路径
  String newPath = saveRootDir + savePath;
  var newFile = File(newPath);
//  print("下载图片前先搜索路径： ${newFile.path}");
  if (await newFile.exists()) {
//    print("已经保存过");
    return 200;
  }

  if(url == null){
    return 404;
  }
//  Directory parent = await newFile.parent.create(recursive: true);
//  print(parent.path);
  // 先找找缓存文件
  Directory dir = await getTemporaryDirectory();
  String path = dir.path + "/" + md5.convert(utf8.encode(url)).toString();
  var cacheFile = File(path);
  if (await cacheFile.exists()) {
    cacheFile.copy(newPath);
//    print("从缓存文件下载");
    return 200;
  }
//  print("从网络下载：$url");
  try{
    Dio dio = Dio();
    Response response = await dio.download(url, newPath);
    return response.statusCode;
  }on DioError catch(e){
//    print(e.toString());
    return e.response.statusCode;
  }



//  var raf = await newFilePart.open(mode: FileMode.write);
//  HttpClient client = new HttpClient();
//  client.getUrl(Uri.parse(url)).then((HttpClientRequest request) {
//    return request.close();
//  }).then((HttpClientResponse response) {
//    response.listen((contents) {
//      raf.writeFrom(List.from(contents));
//    }, onDone: () {
//      raf.closeSync();
//      newFilePart.renameSync(newPath);
//    },onError: ()=> raf.close(),
//    cancelOnError: true);
//  });
}
