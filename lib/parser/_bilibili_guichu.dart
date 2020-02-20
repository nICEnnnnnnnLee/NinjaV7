part of "parser.dart";

class ParserBiliGuichu1 extends Parsers {
  @override
  bool valid(URLd urLd) {
    return urLd.realDomain == DOMAIN_Bilibili_Com;
  }

  @override
  String _genWebLink(URLd urLd, int currentPage) {
    // https://www.bilibili.com/v/kichiku/guide/#/all/click/0/1/
    // https://www.bilibili.com/v/kichiku/guide/#/all/click/0/2/
    // https://www.bilibili.com/v/kichiku/guide/?spm_id_from=xxx#/all/click/0/1/2020-xx-xx,2020-xx-xx
    if (urLd.path.startsWith('/v/kichiku/guide/')) {
      final url =
          "https://${urLd.realDomain}/v/kichiku/guide/#/all/click/0/$currentPage/";
      return url;
    }
    ////http://www.bilibili.com/video/av123456
    return urLd.urlWithProtocol;
  }

  String _twoDigits(int num) {
    if (num < 10)
      return '0$num';
    else
      return num.toString();
  }

  @override
  Future<bool> _loadAlbum(Album album, int currentPage) async {
    if(currentPage > 2)return false;
    //http://www.bilibili.com/video/av123456
    var header = {'Host':'www.bilibili.com',
    'Cookie':'CURRENT_FNVAL=16; '};
    var responseBody = await http.getCommonUrl(
        urlWithProtocol: _genWebLink(album.urld, currentPage),headers: header);
    
    final match = RegExp(r'window.__INITIAL_STATE__ *= *(.*?);\(function').firstMatch(responseBody);
    Map result = json.decode(match.group(1));
    Map videoData = json.decode(match.group(1))['videoData'];
    if (album.title == null) {
      album.title = videoData['title'];
//      videoData['dynamic'];
      result['tags'].forEach((ele) {
        album.characters.add(ele['tag_name']);
        album.tags += "#" + ele['tag_name'];
        album.characterUrls.add(null);
      });
      album.totalPage = 2;
      album.totalSize = 12;
    }
    album.pics.add(videoData['pic']);
    album.pics.add(videoData['pic']);
    album.pics.add(videoData['pic']);
    album.pics.add(videoData['pic']);
    album.pics.add(videoData['pic']);
    album.pics.add(videoData['pic']);
    return true;
  }

  @override
  Future<int> _loadGallery(
      URLd urLd, List<AlbumPreview> albumsPreview, int currentPage) async {
    final timeNow = DateTime.now();
    final str_time_to =
        '${timeNow.year}${_twoDigits(timeNow.month)}${_twoDigits(timeNow.day)}';
    final timeFrom = DateTime.fromMillisecondsSinceEpoch(
        timeNow.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * 7);
    final str_time_from =
        '${timeFrom.year}${_twoDigits(timeFrom.month)}${_twoDigits(timeFrom.day)}';
    final url =
        'https://s.search.bilibili.com/cate/search?callback=jqueryCallback_bili_20011144542570434&main_ver=v3&search_type=video&view_type=hot_rank&order=click&copy_right=-1&cate_id=22'
        '&page=$currentPage&pagesize=20&jsonp=jsonp&time_from=$str_time_from&time_to=$str_time_to&_=${timeNow.millisecondsSinceEpoch}';
//    print('_load bili album :$url');
    var responseBody = await http.getCommonUrl(urlWithProtocol: url);
    responseBody = responseBody
        .replaceFirst('jqueryCallback_bili_20011144542570434\(', '')
        .replaceFirst(RegExp(r'\)$'), '');
//    LogUtil.d(responseBody);


    var result = json.decode(responseBody);

    List list = result['result'];
    list.forEach((ele){
      var pre = AlbumPreview(ele['title'], URLd.parse(url: ele['arcurl']), 'https:${ele['pic']}');
      Parsers.manager?.check4Done(pre);
      Parsers.manager?.check4ToDo(pre);
      pre.isBookmarked = bookmarks.containsValue(pre);
//      pre.character = '${ele['author']}, ${ele['tag']}';
      albumsPreview.add(pre);
    });
    return list.length;
  }

  ParseResult _parseResultOf(URLd urdToParse) {
    //搜索栏链接 只对哔哩哔哩 鬼畜区提供 画廊类型的入口

    Match m = RegExp(
            r'/v/kichiku/guide/(?:\?spm_id_from=[^#]+)?#/all/click/0/(?:([0-9]+)/)?')
        .firstMatch(urdToParse.path);
    if (m != null) {
      return ParseResult(ResultType.GALLERY,
          domain: urdToParse.realDomain,
          path: '/v/kichiku/guide/#/all/click/0/',
          currentPage: m.group(1) == null? 0: (int.parse(m.group(1)) - 1)
      );
    }
    return ParseResult(ResultType.NONE);
  }

  @override
  Future<List<Gallery>> _search(String keyWord) async {
    // 不提供
    return null;
  }
}
