import 'package:flutter/material.dart';
import 'package:flutter_app_picviewer/domain/gallery.dart';
import 'package:flutter_app_picviewer/util/custom_network_image.dart' as NTImage;
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_app_picviewer/widget/page_gallery.dart';
import '../global.dart';
class ResultPage extends StatelessWidget {
  final List<Gallery> gList;

  ResultPage({Key key, this.gList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
//      backgroundColor: Colors.lightBlue,
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).popUntil(ModalRoute.withName("/home"));
                }),
            title: Text("搜索结果"),
//              actions: [
//                IconButton(
//                    icon: Icon(Icons.stop),
//                    tooltip: '返回首页',
//                    onPressed: () {Navigator.popAndPushNamed(context, '/');}),
//              ]
          ),
          body: gList.length == 0
              ? Center(
                  child: Text("什么也没有找到哦"),
                )
              : ListView.builder(
                  itemCount: gList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return albumDisplay(context, index);
                  },
                )),
    );
  }

  Widget starRatings(int starFull, int starHalf) {
    List<Widget> stars = List(5);
    for (int i = 0; i < starFull; i++) {
      stars[i] = Icon(
        Icons.star,
        size: 18,
        color: Colors.orange,
      );
    }
    for (int i = starFull; i < starFull + starHalf; i++) {
      stars[i] = Icon(
        Icons.star_half,
        size: 18,
        color: Colors.orange,
      );
    }
    for (int i = starFull + starHalf; i < 5; i++) {
      stars[i] = Icon(
        Icons.star_border,
        size: 18,
        color: Colors.orange,
      );
    }
    return Row(
      children: stars,
    );
  }

  Widget albumDisplay(context, int index) {
    var container = Container(
      margin: EdgeInsets.fromLTRB(5, 10, 10, 5),
      decoration: new BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.grey,
              offset: Offset(2.0, 2.0),
              blurRadius: 10.0,
              spreadRadius: 2.0),
//                  BoxShadow(color: Colors.grey, offset: Offset(1.0, 1.0)),
          BoxShadow(color: Color.fromRGBO(230, 230, 230, 1))
        ],
        borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
      ),
      child: MaterialButton(
        padding: EdgeInsets.only(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 90,
              height: 110,
              child: NTImage.FadeInImage.memoryNetwork(
                image: gList[index].picDisplay,
                sdcache: true,
                placeholder: kTransparentImage,
                fit: BoxFit.cover,
                findProxy: findProxy,
              ),
              padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(5, 8, 20, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: new BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey))),
                    height: 40,
                    width: 220,
                    child: Text(gList[index].title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    height: 20,
                    width: 220,
                    child: Text(gList[index].tags,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey)),
                  ),
                  Container(
                      height: 40,
                      width: 160,
                      alignment: Alignment.centerLeft,
                      child: starRatings(
                          gList[index].starFullCnt, gList[index].starHalfCnt)),
                ],
              ),
            )
          ],
        ),
        onPressed: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => GalleryPage(urld: gList[index].urld)));
        },
      ),
    );

    return container;
  }
}
