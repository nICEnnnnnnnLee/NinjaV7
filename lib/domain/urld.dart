import 'dart:ui';

// 有效地址
String DOMAIN_Javbus_Com;
const String DOMAIN_Bilibili_Com = "www.bilibili.com";

// 别名(PC端 + 被墙域名)
Map<String, String> mapDomainAlias;
Map<String, String> mapTitle;
Map<String, String> mapKey;

void initURLd(){

  mapDomainAlias = {
    "m.bilibili.com": DOMAIN_Bilibili_Com,

  };

  mapTitle = {
    DOMAIN_Bilibili_Com: "哔哩哔哩",
  };

  mapKey = {
    DOMAIN_Bilibili_Com: "7_",
  };
}


class URLd {
  String domain;
  String path;

  String _urlWithProtocol;
  String _urlWithoutProtocol;
  String _realDomain;
  String _siteName;
  String _key;

  static String nameOf({URLd urld, String domain}){
    if(urld != null){
      return mapTitle[transRealDomain(urld.realDomain)];
    }
    return mapTitle[transRealDomain(domain)];
  }

  static String transRealDomain(String domain) {
    final alias = mapDomainAlias[domain];
    return alias == null? domain: alias;
  }

  String get key {
    if(_key == null){
      _key = mapKey[realDomain] + path;
    }
    return _key;
  }

  String get siteName {
    if(_siteName == null){
      _siteName = mapTitle[realDomain];
    }
    return _siteName;
  }

  String get realDomain {
    if(_realDomain == null){
      _realDomain = transRealDomain(domain);
    }
    return _realDomain;
  }

  String get urlWithProtocol {
    if(_urlWithProtocol == null){
      _urlWithProtocol = "https://$realDomain$path";
    }
    return _urlWithProtocol;
  }

  String get urlWithoutProtocol {
    if(_urlWithoutProtocol == null){
      _urlWithoutProtocol = "$realDomain$path";
    }
    return _urlWithoutProtocol;
  }

  URLd({ this.path, this.domain}):assert(path != null),assert(domain != null);

  URLd.from(String record) {
    final list = record.split(" ");
    domain = list[0];
    path = list[1];
  }

  URLd.parse({domain, url}):assert(url != null){
//    if(domain != null){
//      this.domain = domain;
//      this.path = url
//          .replaceFirst(RegExp(r"https?(://)?"), "")
//          .replaceFirst(domain, "");
//    }else{
      final m = RegExp("(?:https?://)?([^/]+)(/.*)").firstMatch(url);
      this.domain = m.group(1);
      this.path = m.group(2);
//    }

  }

  @override
  String toString() => "$domain $path";

  @override
  int get hashCode => hashValues(path, domain);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;

    final URLd typedOther = other;

    return path == typedOther.path &&
        realDomain == typedOther.realDomain;
  }
}