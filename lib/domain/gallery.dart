import 'dart:ui';
import 'urld.dart';

class Gallery {
  URLd urld;
  String title;

  String picDisplay;
  String tags = "";
  int starFullCnt;
  int starHalfCnt;

  Gallery({this.title, this.urld});

  @override
  int get hashCode => hashValues(urld.path, urld.domain);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final Gallery typedOther = other;
    return urld == typedOther.urld;
  }

  Map<String, dynamic> toJson() => {
        'domain': urld.realDomain,
        'title': title,
        'path': urld.path,
      };

  Gallery.fromJson(Map<String, dynamic> json) {
    urld = URLd(domain: json["domain"], path: json["path"]);
    title = json["title"];
  }
}

class AlbumPreview {
  String character;

  URLd urld;
  String title;
  String picDisplay;

  String titleDisplay;
  bool isDone = false;
  bool isToDown = false;
  bool isBookmarked = false;
  bool isSelected = false;

  AlbumPreview(this.title, this.urld, this.picDisplay, {this.character})
      : assert(title != null),
        assert(urld != null),
        assert(picDisplay != null);

  @override
  int get hashCode => hashValues(urld.path, urld.domain);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final AlbumPreview typedOther = other;
    return urld == typedOther.urld;
  }

  Map<String, dynamic> toJson() => {
        'domain': urld.realDomain,
        'title': title,
        'picDisplay': picDisplay,
        'url': urld.urlWithoutProtocol,
        'character': character,
      };

  AlbumPreview.fromJson(Map<String, dynamic> json) {
    urld = URLd.parse(url: json["url"]);
    title = json["title"];
    picDisplay = json["picDisplay"];
    character = json["character"];
  }
}
