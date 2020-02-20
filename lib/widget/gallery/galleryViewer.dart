part of '../page_gallery.dart';

class GalleryViewer extends StatefulWidget {
  final URLd urld;
  final int initialPage;
  final bool isInSelectMode;
  final double tipOpacityLevel;
  final String tipToShow;
  final List<AlbumPreview> albumsPreview;

  final Function(int currentPage) onGlobalRefreshNeeded;
  final Function(int index) onLongPressPic;
  final gridRatio;

  GalleryViewer({
    Key key,
    @required this.urld,
    @required this.tipOpacityLevel,
    @required this.tipToShow,
    @required this.initialPage,
    @required this.isInSelectMode,
    @required this.albumsPreview,
    @required this.onGlobalRefreshNeeded,
//    @required this.onTapPic,
    @required this.onLongPressPic,
    @required this.gridRatio,
  }) : super(key: key);

  @override
  _GalleryViewer createState() => _GalleryViewer();
}

class _GalleryViewer extends State<GalleryViewer> {
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  DownLoadManager man = DownLoadManager();
  int currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _loadMore();
    _scrollController.addListener(() {
      var position = _scrollController.position;
      if (position.maxScrollExtent - position.pixels < 50) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        color: Colors.deepOrangeAccent,
//              backgroundColor: Colors.lightBlue,
        child: Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Stack(
              children: <Widget>[
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 5,
                      childAspectRatio: widget.gridRatio,
                  ),
                  itemCount: widget.albumsPreview.length,
                  itemBuilder: (BuildContext context, int index) {
                    var container = GestureDetector(
//                        padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                        child: new Stack(
                          alignment: const FractionalOffset(1.0, 0.0),
                          children: <Widget>[
                            NTImage.FadeInImage.memoryNetwork(
                              image: widget.albumsPreview[index].picDisplay,
                              sdcache: true,
                              placeholder: kTransparentImage,
                              findProxy: findProxy,
                            ),
//                      Offstage(
//                          offstage: bNone,
//                          child:
                            Row(
                              children: showTopRightIcons(index),
                              mainAxisAlignment: MainAxisAlignment.end,
                            ),
//                      ),
                            Positioned(
                              bottom: 0,
                              child: Offstage(
                                offstage:
                                    widget.albumsPreview[index].isSelected !=
                                        true,
                                child: Container(
                                  color: Colors.black38,
                                  alignment: Alignment.center,
                                  height: 50,
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Icon(Icons.check_circle_outline),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onLongPress: () {
                          if (!widget.isInSelectMode) {
                            widget.albumsPreview[index].isSelected = true;
                          } else {
                            widget.albumsPreview
                                .forEach((ele) => ele.isSelected = false);
                          }
                          widget.onLongPressPic(index);
                        },
                        onTap: () {
                          if (widget.isInSelectMode) {
                            if (widget.albumsPreview[index].isSelected == true)
                              widget.albumsPreview[index].isSelected = false;
                            else
                              widget.albumsPreview[index].isSelected = true;
                            setState(() {});
                          } else {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => AlbumPage(
                                          urld:
                                              widget.albumsPreview[index].urld,
                                        )));
                          }
                        });

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        container,
                        Expanded(
                            child: Text(
                                widget.albumsPreview[index].titleDisplay == null
                                    ? widget.albumsPreview[index].title
                                    : widget.albumsPreview[index].titleDisplay,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                  decorationStyle: TextDecorationStyle.solid,
                                ))),
                      ],
                    );
                  },
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                ),
                AnimatedOpacity(
                    opacity: widget.tipOpacityLevel,
                    duration: new Duration(seconds: 1), //过渡时间：1
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: 250,
                        height: 30,
                        decoration: BoxDecoration(color:  Colors.black87,borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          widget.tipToShow,
                          style: TextStyle(
                            color: Colors.white, ),
                        ),
                      ),
                    ),
                    )
              ],
            )),
        onRefresh: _onRefresh);
  }

  Future _loadMore() async {
    if (!isLoading) {
      isLoading = true;
      setState(() {});
      currentPage++;
      try {
        int result = await Parsers.loadGallery(
            widget.urld, currentPage, widget.albumsPreview);
        if (result == 0) currentPage--;
        isLoading = false;
        widget.onGlobalRefreshNeeded(currentPage);
      } catch (e) {
        isLoading = false;
        rethrow;
      }
    }
  }

  List<Widget> showTopRightIcons(int index) {
    bool bStar = widget.albumsPreview[index].isDone;
    bool bHalfStar = widget.albumsPreview[index].isToDown;
    bool isBookmarked = widget.albumsPreview[index].isBookmarked;
    List<Widget> list = [];
    if (isBookmarked)
      list.add(Icon(
        Icons.bookmark,
        color: Colors.black87,
      ));
    if (bStar)
      list.add(Icon(
        Icons.star,
        color: Colors.black87,
      ));
    if (!bStar && bHalfStar)
      list.add(Icon(
        Icons.star_half,
        color: Colors.black87,
      ));
    return list;
  }

  Future<void> _onRefresh() async {
    print("RefreshListPage _onRefresh()");
    widget.albumsPreview.clear();
    currentPage = 0;
    _loadMore();
  }
}
