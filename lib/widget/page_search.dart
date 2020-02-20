import 'package:flutter/material.dart';
import '../widget/page_album.dart';
import '../widget/page_gallery.dart';
import '../global.dart';
import '../widget/page_search_result.dart';
import '../parser/parser.dart';
import '../domain/urld.dart';

final searchDomainList = [
];
final searchSourcesCnt = 0;

class SearchBarDelegate extends SearchDelegate<String> {
//  @override
//  String get searchFieldLabel => "My hint text";

  SearchBarDelegate() : super(searchFieldLabel: "请输入合法网址");

  //清空按钮
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = "", //搜索值为空
      )
    ];
  }

  //返回上级按钮
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () => close(context, null) //点击时关闭整个搜索页面
        );
  }

  Future _gotoResult(BuildContext context, ParseResult result) async {
    if (result.type == ResultType.GALLERY) {
      await Future.delayed(Duration(seconds: 0)).then((_) {
//        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => GalleryPage(
                      urld: URLd(path: result.path, domain: result.domain),
                      currentPage: result.currentPage,
                    )));
      });
    } else if (result.type == ResultType.ALBUM) {
      await Future.delayed(Duration(seconds: 0)).then((_) {
//        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => AlbumPage(
                    urld: URLd(path: result.path, domain: result.domain))));
      });
    }
  }

//搜到到内容后的展现
  @override
  Widget buildResults(BuildContext context) {
    ParseResult result = Parsers.parse(query);
    if (result.type != ResultType.NONE) {
      _gotoResult(context, result);
      return Text("");
    } else {
      return Center(
        child: Text("无法解析非法请求，请重新输入！！"),
      );
    }
  }

//设置推荐
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionsList = query.isEmpty
        ? recentSuggest
        : recentSuggest.where((input) => input.contains(query)).toList();

    return ListView.builder(
        itemCount: query.isNotEmpty
            ? suggestionsList.length + searchSourcesCnt
            : suggestionsList.length,
        itemBuilder: (context, index) {
          var suggest;
          if (index < searchSourcesCnt && query.isNotEmpty) {
            suggest = Text("    从${searchDomainList[index]}搜索");
          } else {
            int realIndex = query.isNotEmpty ? index - searchSourcesCnt : index;
            int start = suggestionsList[realIndex].indexOf(query);
            suggest = RichText(
              //富文本
              text: TextSpan(
                  text: suggestionsList[realIndex].substring(0, start),
                  style: TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(
                        text: suggestionsList[realIndex]
                            .substring(start, start + query.length),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: suggestionsList[realIndex]
                            .substring(start + query.length),
                        style: TextStyle(color: Colors.grey)),
                  ]),
            );
          }
          return ListTile(
            title: GestureDetector(
              child: suggest,
              onTap: () {
                if (index < searchSourcesCnt && query.isNotEmpty) {
                  Parsers.search(searchDomainList[index], query).then((gList) {
                    if (gList != null) {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => ResultPage(
                                    gList: gList,
                                  )));
                    }else{
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => GalleryPage(
                                urld: URLd(path: "/search/$query", domain: searchDomainList[index]),
                                currentPage: 0,
                              )));
                    }
                  });
                } else {
                  int realIndex =
                      query.isNotEmpty ? index - searchSourcesCnt : index;
                  int begin = suggestionsList[realIndex].indexOf("http");
                  //query = suggestionsList[index].substring(begin);
                  ParseResult result = Parsers.parse(
                      suggestionsList[realIndex].substring(begin));
                  _gotoResult(context, result);
                }
              },
              onLongPress: () {
                int realIndex =
                    query.isNotEmpty ? index - searchSourcesCnt : index;
                int begin = suggestionsList[realIndex].indexOf("http");
                query = suggestionsList[realIndex].substring(begin);
              },
            ),
          );
        });
  }
}
