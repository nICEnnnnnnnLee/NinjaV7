import 'dart:ui';
import 'urld.dart';

class Album {
  String title;
  URLd  urld;
  List<String> characters = [];
  List<String> characterUrls = [];
  String tags = "";

  List<String> pics = [];
  List<int> rSeed;// 用于刷新图片
  int totalSize = 0;
  int totalPage = 0;

  // 表示状态
  int currentPage = 0;
  String saveDir;
  int downloaded = 0;
  bool stop = false;
  bool isDone;
  bool isBookmarked;

  Album({this.urld, this.currentPage = 0}) : assert(urld != null);

  Map<String, dynamic> toJson() => {
        'domain': urld.realDomain,
        'title': title,
        'characters': characters,
        'url': urld.urlWithoutProtocol,
        'totalSize': totalSize,
      };

  Album.fromJson(Map<String, dynamic> json) {
    urld = URLd.parse(url: json["url"]);
    title = json["title"];
    characters = json["characters"];
    totalSize = json["totalSize"];
  }
  @override
  int get hashCode => hashValues(urld.path, urld.domain);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final Album typedOther = other;
    return urld == typedOther.urld;
  }

}
