part of '../global.dart';

class Settings {
//  static Map<String, Gallery> favorites = {};
//  static Map<String, AlbumPreview> bookmarks = {};
//  static Map<String, URLd> downloadedList = {};

  static const String _prefs_favorite = "favo_";
  static const String _prefs_bookmark = "book_";
  static const String _prefs_downloaded = "down_";
  static const String _prefs_domainAlia = "domain.alias.jav_";
  static SharedPreferences globalPrefs;

  static Future<SharedPreferences> init() async {
//    await readFavorites();
//    await readDownloaded();
//    await readBookmarks();
    globalPrefs = await SharedPreferences.getInstance();
    // 先确认域名情况
    DOMAIN_Javbus_Com = globalPrefs.getString('domain.javbus');
    // 初始化Javbus默认免翻墙域名
    if (DOMAIN_Javbus_Com == null) {
      DOMAIN_Javbus_Com = "www.seedmm.cloud";
      globalPrefs.setString('domain.javbus', DOMAIN_Javbus_Com);
    }
    initURLd();
    //等到默认免翻墙域名加载完毕后，设置别名
    globalPrefs.getKeys().forEach((key) {
      if (key.startsWith(_prefs_domainAlia)) {
        String realKey = key.replaceFirst(_prefs_domainAlia, "");
        //String value = globalPrefs.getString(realKey);
        mapDomainAlias[realKey] = DOMAIN_Javbus_Com;
      }
    });

    // 解析其它基于URLd的配置和默认配置
    globalPrefs.getKeys().forEach((key) {
      if (key.startsWith(_prefs_favorite)) {
        Gallery gallery = Gallery.fromJson(json.decode(globalPrefs.get(key)));
        favorites[key] = gallery;
        var suggest = _genSuggest(gallery);
        recentSuggest.add(suggest);
      } else if (key.startsWith(_prefs_bookmark)) {
        AlbumPreview abp =
            AlbumPreview.fromJson(json.decode(globalPrefs.get(key)));
        bookmarks[key] = abp;
      } else if (key.startsWith(_prefs_downloaded)) {
        URLd urLd = URLd.from(globalPrefs.get(key));
        downloadedList[key] = urLd;
      } else if (key == 'hosts') {
        print('hosts初始化...');
        hosts = getHosts();
      } else if (key == 'proxy.port') {
        port = globalPrefs.getInt(key);
      }
    });
    //初始化hosts默认配置
    if (hosts == null) {
      globalPrefs.setString('hosts',
          '{"www.javbus.com": "104.31.94.235"}');
      hosts = getHosts();
    }
    //初始化代理端口
    if (port == null) {
      globalPrefs.setInt('proxy.port', 5438);
      port = 5438;
    }
    //初始化主页默认配置
    if (globalPrefs.getBool("home") == null) {
//      setHome("gallery", "m.nvshens.net", "/gallery/");
      setHome("gallery", "www.bilibili.com", "/v/kichiku/guide/#/all/click/0/");
    }
    return globalPrefs;
  }

  static String getSaveDirPath() {
    return globalPrefs.getString('path');
  }

  static setSaveDirPath(String path) {
    globalPrefs.setString('path', path);
    saveRootDir = path;
  }

  static Map<String, dynamic> getHosts() {
    return json.decode(globalPrefs.get('hosts'));
  }

  static setJav(String domain) {
    globalPrefs.setString('domain.javbus', domain);
    globalPrefs.setString(_prefs_domainAlia + DOMAIN_Javbus_Com, domain);
  }

  static setHosts(Map hosts) {
    globalPrefs.setString('hosts', json.encode(hosts));
  }

  static setPort(int port) {
    globalPrefs.setInt('proxy.port', port);
  }

  static bool getHome() {
    return globalPrefs.getBool("home");
  }

  static String getHomeType() {
    return globalPrefs.getString("home.type");
  }

  static URLd getHomeUrld() {
    final homeDomain = globalPrefs.getString("home.domain");
    final homePath = globalPrefs.getString("home.path");
    return URLd(path: homePath, domain: homeDomain);
  }

  static void setHome(String type, String domain, String path) {
    globalPrefs.setBool("home", true);
    globalPrefs.setString("home.type", type);
    globalPrefs.setString("home.domain", domain);
    globalPrefs.setString("home.path", path);
  }

  static bool showAD() {
    return globalPrefs.getBool("ad.show") != false;
  }

  static void triggerAD() {
    if (showAD()) {
      globalPrefs.setBool("ad.show", false);
    } else {
      globalPrefs.setBool("ad.show", true);
    }
  }

  static String _key(obj) {
    if (obj.runtimeType != URLd)
      return obj.urld.key;
    else
      return obj.key;
  }

  static String keyOfDomainAlias(String obj) {
    return _prefs_domainAlia + obj;
  }

  static String keyOfBookmark(dynamic obj) {
    return _prefs_bookmark + _key(obj);
  }

  static String keyOfFavorites(dynamic obj) {
    return _prefs_favorite + _key(obj);
  }

  static String keyOfDownloaded(dynamic obj) {
    return _prefs_downloaded + _key(obj);
  }

  static void addBookmark(AlbumPreview album) {
    String key = keyOfBookmark(album);
    bookmarks[key] = (album);
    globalPrefs.setString(key, json.encode(album));
    print('添加Bookmark AlbumPreview : $key');
  }

  static void removeBookmark(AlbumPreview album) {
    String key = keyOfBookmark(album);
    globalPrefs.remove(key);
    bookmarks.remove(key);
    print('删除Bookmark AlbumPreview : $key');
  }

  static void saveBookmarks() {
    bookmarks.forEach((key, albumPreview) {
      globalPrefs.setString(key, json.encode(albumPreview));
    });
  }

//  Map<String, Gallery> favorites = {};
//  Map<String, AlbumPreview> bookmarks = {};
//  List<String> recentSuggest = [];
//  Map<String, URLd> downloadedList = {};
  static void addFavorite(Gallery gallery) {
    String key = keyOfFavorites(gallery);
    favorites[key] = (gallery);
    globalPrefs.setString(key, json.encode(gallery));
    var suggest = _genSuggest(gallery);
    if (!recentSuggest.contains(suggest)) recentSuggest.add(suggest);
    print('添加Favorite gallery : $key');
  }

  static void removeFavorite(Gallery gallery) {
    String key = keyOfFavorites(gallery);
    globalPrefs.remove(key);
    favorites.remove(key);
    var suggest = _genSuggest(gallery);
    recentSuggest.remove(suggest);
    print('删除Favorite gallery : $key');
  }

  static void saveFavorites() {
    favorites.forEach((key, gallery) {
      globalPrefs.setString(key, json.encode(gallery));
    });
  }

  static void addDownloaded(URLd urld) {
    String key = keyOfDownloaded(urld);
    downloadedList[key] = (urld);
    globalPrefs.setString(key, urld.toString());
    print('添加Downloaded URLd : $key');
  }

  static void removeDownloaded(Gallery gallery) {
    String key = keyOfDownloaded(gallery);
    globalPrefs.remove(key);
    downloadedList.remove(key);
    print('删除Downloaded URLd : $key');
  }

  static void saveDownloads() {
    downloadedList.forEach((key, urld) {
      globalPrefs.setString(key, urld.toString());
    });
  }

  static Future import() async {
    await _readFavorites();
    await _readDownloaded();
    await _readBookmarks();
  }

  static Future export() async {
    await _writeFavorites();
    await _writeDownloaded();
    await _writeBookmarks();
  }

  static triggerBookmark(AlbumPreview albumPreview) {
    String key = Settings.keyOfBookmark(albumPreview);
    if (bookmarks.containsKey(key)) {
      removeBookmark(albumPreview);
    } else {
      addBookmark(albumPreview);
    }
  }

  static Future _readBookmarks() async {
    var file = File("${await getSaveRootDir()}/bookmarks.json");
    if (await file.exists()) {
      String content =
          File("${await getSaveRootDir()}/bookmarks.json").readAsStringSync();
//    print(content);
      List list = json.decode(content);
//    bookmarks.clear();
//    print("读取前Bookmarks数量： ${bookmarks.length}");
      list.forEach((ele) {
        AlbumPreview album = AlbumPreview.fromJson(ele);
        String key = Settings.keyOfBookmark(album);
        if (!bookmarks.containsKey(key)) bookmarks[key] = (album);
      });
//    print("读取后Bookmarks数量： ${bookmarks.length}");
    }
    saveBookmarks();
  }

  static Future _writeBookmarks() async {
//  print(json.encode(bookmarks));
    await File("${await getSaveRootDir()}/bookmarks.json")
        .writeAsString(json.encode(bookmarks.values.toList(growable: false)));
  }

  static String _genSuggest(Gallery gallery) {
    String site = "${mapTitle[gallery.urld.realDomain]}";
    String url = gallery.urld.urlWithProtocol;
    return "$site-${gallery.title}-$url".replaceFirst("-null", "");
  }

  static Future triggerFavorite(Gallery gallery) async {
    String key = Settings.keyOfFavorites(gallery);
    if (favorites.containsKey(key)) {
      removeFavorite(gallery);
    } else {
      addFavorite(gallery);
    }
  }

  static Future _readFavorites() async {
    print("从文件读取Favorites");
    var file = File("${await getSaveRootDir()}/favorites.json");
    if (await file.exists()) {
      String content =
          File("${await getSaveRootDir()}/favorites.json").readAsStringSync();
      List list = json.decode(content);
//    favorites.clear();
//    recentSuggest.clear();

      list.forEach((ele) {
        Gallery gallery = Gallery.fromJson(ele);
        String key = Settings.keyOfFavorites(gallery);
        if (!favorites.containsKey(key)) {
          favorites[key] = (gallery);
          var suggest = _genSuggest(gallery);
          recentSuggest.add(suggest);
        }
      });
    }
    saveFavorites();
  }

  static Future _writeFavorites() async {
    await File("${await getSaveRootDir()}/favorites.json")
        .writeAsString(json.encode(favorites.values.toList(growable: false)));
  }

  static Future _readDownloaded() async {
    var file = File("${await getSaveRootDir()}/downloaded.lines");
    if (await file.exists()) {
      List content = file.readAsLinesSync();
//    print(content);
//    downloadedList.clear();
      content.forEach((line) {
        URLd urld = URLd.from(line);
        String key = Settings.keyOfDownloaded(urld);
        downloadedList[key] = (urld);
      });
    }
    saveDownloads();
  }

  static Future _writeDownloaded({URLd urld}) async {
    if (urld != null) {
      await File("${await getSaveRootDir()}/downloaded.lines")
          .writeAsString(urld.toString() + "\r\n", mode: FileMode.append);
    } else {
      final file = File("${await getSaveRootDir()}/downloaded.lines");
      IOSink io = file.openWrite();
      downloadedList.forEach((key, value) {
        io.writeln(value.toString());
//        print(" ${value.toString()}");
      });
      await io.flush();
      await io.close();
    }
  }

  static Future importDownloadedFromSDCard() async {
    print("importDownloadedFromSDCard 被调用");
    final rootDir = Directory("${await getSaveRootDir()}");
    final domainDirs = rootDir.listSync();
    for (int i = 0; i < domainDirs.length; i++) {
      if (await FileSystemEntity.type(domainDirs[i].path) !=
          FileSystemEntityType.directory) break;
      final albumDirs = Directory(domainDirs[i].path).listSync();
      for (int j = 0; j < albumDirs.length; j++) {
        final file = File("${albumDirs[j].path}/info.json");
        if (file.existsSync()) {
          final album = json.decode(file.readAsStringSync());
          final urld = URLd.parse(url: album["url"], domain: album["domain"]);
          String key = Settings.keyOfDownloaded(urld);
          downloadedList[key] = urld;
        } else {
          print("${file.path} 不存在");
        }
      }
    }
    saveDownloads();
    print("importDownloadedFromSDCard 被调用完毕");
  }
}
