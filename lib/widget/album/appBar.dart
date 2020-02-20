part of '../page_album.dart';

class AppBarW {
  final Album album;
  final BuildContext context;
  final manager = downloader.DownLoadManager();

  final Function() onTapBtnDownload;
  final Function() onTapBtnManage;
  final Function() onTapBtnMark;
  final Function() onTapBtnSearch;

  AppBarW({
    Key key,
    this.context,
    this.album,
    this.onTapBtnDownload,
    this.onTapBtnManage,
    this.onTapBtnMark,
    this.onTapBtnSearch,
  });

  AppBar build() {
    return AppBar(
      leading: PopupMenuButton<String>(
        icon: Icon(Icons.face),
        itemBuilder: (BuildContext context) {
          List<PopupMenuItem<String>> list = [];
          for (int i = 0; i < album.characterUrls.length; i++) {
            var pop = new PopupMenuItem<String>(
                value: "$i",
                child: Container(
                  child: Text(
                    album.characters[i],
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                  width: 120,
//                  height: 50,
                  alignment: Alignment.centerLeft,
                ),);
            list.add(pop);
          }
          return list;
        },
        onSelected: (String action) {
          int index = int.parse(action);
          if (album.characterUrls[index] != null) {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => GalleryPage(
                        urld: URLd.parse(url: album.characterUrls[index]))));
          }
        },
      ),
      title: Text(
        album.urld.siteName,
        textAlign: TextAlign.start,
      ),
      actions: appBarButtons(),
    );
  }

  List<Widget> appBarButtons() {
    IconButton btnDownload;
    if (manager.isDownloading(album.urld.urlWithoutProtocol)) {
      btnDownload = IconButton(
          icon: Icon(Icons.file_download), tooltip: '正在下载中', onPressed: () {});
    } else if (manager.isWaiting(album.urld.urlWithoutProtocol)) {
      btnDownload = IconButton(
          icon: Icon(Icons.access_time), tooltip: '等待下载中', onPressed: () {});
    } else {
      btnDownload = IconButton(
        icon: album.isDone != true
            ? new Icon(Icons.star_border)
            : new Icon(Icons.star),
        tooltip: '下载',
        onPressed: onTapBtnDownload,
      );
    }
    IconButton btnManage = IconButton(
        icon: Icon(Icons.brightness_high),
        tooltip: '下载管理',
        onPressed: onTapBtnManage);
    IconButton btnMark = IconButton(
        icon: album.isBookmarked != true
            ? new Icon(Icons.bookmark_border)
            : new Icon(Icons.bookmark),
        tooltip: '标记',
        onPressed: onTapBtnMark);
    IconButton btnSearch = (IconButton(
        icon: Icon(Icons.search), tooltip: '查找页面', onPressed: onTapBtnSearch));
    return [btnDownload, btnManage, btnMark, btnSearch];
  }
}
