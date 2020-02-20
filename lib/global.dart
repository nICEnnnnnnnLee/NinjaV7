import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/gallery.dart';
import 'domain/urld.dart';
import 'util/custom_http_proxy.dart';

part 'util/settings.dart';

List<String> recentSuggest = [];// 搜索栏建议
Map<String, Gallery> favorites = {};// 画廊收藏(画廊：某种同质的相册列表合集)
Map<String, AlbumPreview> bookmarks = {};// 相册标签
Map<String, URLd> downloadedList = {};// 已经下载的相册


Map<String, dynamic> hosts ;
int port = 5438;
String Function(Uri) findProxy;
CustomHttpsProxy proxy;

// 临时文件保存目录
Directory temporaryDirectory;
// 文件保存根目录
String saveRootDir;

// 获取app SD存储路径
Future<String> getSaveRootDir() async {
  if (saveRootDir == null) {
    final pathFromConfig = Settings.getSaveDirPath();
    if(pathFromConfig == null){
      saveRootDir =
          (await path.getExternalStorageDirectory()).path + "/Download/MyLove";
    }else{
      saveRootDir = pathFromConfig;
    }

  }
  Directory(saveRootDir).createSync(recursive: true);
  return saveRootDir;
}

// 获取系统临时文件路径
Future getTemporaryDirectory() async {
  if (temporaryDirectory == null) {
    temporaryDirectory = await path.getTemporaryDirectory();
  }
  return temporaryDirectory;
}

Future nomedia(bool isNoMedia) async {
  final rootDir = Directory("${await getSaveRootDir()}");
  final file = File("${rootDir.path}/.nomedia");
  try {
    if (isNoMedia) {
      file.createSync();
//      print("根目录创建nomedia..");
    } else {
      file.deleteSync();
    }
  } catch (e) {}

  final domainDirs = rootDir.listSync();
  for (int i = 0; i < domainDirs.length; i++) {
    if (await FileSystemEntity.type(domainDirs[i].path) !=
        FileSystemEntityType.directory) break;
    final albumDirs = Directory(domainDirs[i].path).listSync();
    for (int j = 0; j < albumDirs.length; j++) {
      final file = File("${albumDirs[j].path}/.nomedia");
      try {
        if (isNoMedia) {
          file.createSync();
//          print("创建nomedia..");
        } else {
          file.deleteSync();
        }
      } catch (e) {}
    }
  }
}