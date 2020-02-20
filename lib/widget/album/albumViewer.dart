part of '../page_album.dart';

class AlbumViewer extends StatefulWidget {
  final Album album;
  final bool isLoadingWhenDrag;
  final ScrollController scrollController;
  final Function() onTapPic;
  final Function() onLongPressPic;
  final Function() onDoubleTapPic;
  final Function(int currentPicIndex) onGlobalRefreshNeeded;

  AlbumViewer({
    Key key,
    this.album,
    this.onTapPic,
    this.onLongPressPic,
    @required this.onDoubleTapPic,
    this.isLoadingWhenDrag,
    this.scrollController,
    this.onGlobalRefreshNeeded,
  }) : super(key: key);

  @override
  _AlbumViewer createState() => _AlbumViewer();
}

class _AlbumViewer extends State<AlbumViewer> {
//  List<int> rSeed;
  int currentPicIndex = 0;
  bool isLoading = false;

//  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
//    print("initState: invoked...");
    super.initState();
    widget.scrollController.addListener(() {
      var position = widget.scrollController.position;
      int pIndex = ((position.pixels) /
              position.maxScrollExtent *
              widget.album.pics.length)
          .floor();
      if (pIndex == widget.album.pics.length) pIndex--;
//      print("lastPicIndex: $currentPicIndex, currentPicIndex: pIndex");
      if (!widget.isLoadingWhenDrag) {
        if (currentPicIndex != pIndex) {
          widget.onGlobalRefreshNeeded(pIndex);
        }
        currentPicIndex = pIndex;

        // 小于50px时，触发上拉加载；
        if (position.maxScrollExtent - position.pixels < 50) {
          _loadMore();
        }
      }
    });
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.album.pics.length,
        itemBuilder: (BuildContext context, int index) {
          final width = MediaQuery.of(context).size.width;
          return new Stack(
            alignment: const FractionalOffset(0.5, 0.02),
            children: <Widget>[
              GestureDetector(
                child: Container(
                    width: width,
                    margin: EdgeInsets.all(0),
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(1, 10, 1, 10),
                    child: NTImage.FadeInImage.memoryNetwork(
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      image: widget.album.pics[index] == null
                          ? "https://127.0.0.1/${widget.album.urld.urlWithoutProtocol}/$index"
                          : widget.album.pics[index],
                      sdcache: true,
                      seed: widget.album.rSeed == null
                          ? null
                          : widget.album.rSeed[currentPicIndex],
                      needRefresh: true,
                      alterPath: widget.album.isDone == true
                          ? "${widget.album.saveDir}/$index.jpg"
                          : null,
                      placeholder: kTransparentImage,
                      findProxy: findProxy,
                    )),
                onTap: widget.onTapPic,
                onLongPress: () {
                  widget.onLongPressPic();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => FullScreenImgPage(
                                image: NTImage.FadeInImage.memoryNetwork(
                                  fit: BoxFit.scaleDown,
                                  image: widget.album.pics[index] == null
                                      ? "https://127.0.0.1/${widget.album.urld.urlWithoutProtocol}/$index"
                                      : widget.album.pics[index],
                                  sdcache: true,
                                  seed: widget.album.rSeed == null
                                      ? null
                                      : widget.album.rSeed[currentPicIndex],
                                  needRefresh: true,
                                  alterPath: widget.album.isDone == true
                                      ? "${widget.album.saveDir}/$index.jpg"
                                      : null,
                                  placeholder: kTransparentImage,
                                  findProxy: findProxy,
                                )),
                              ));
                },
                onDoubleTap: widget.onDoubleTapPic,
              ),
              Text(
                "$index/${widget.album.totalSize - 1}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
//                      fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
        physics: AlwaysScrollableScrollPhysics(),
        controller: widget.scrollController,
      ),
    );
  }

  Future _loadMore() async {
    if (!isLoading) {
      if (widget.album.totalPage > 0 &&
          widget.album.currentPage == widget.album.totalPage) {
        isLoading = true;
        setState(() {});
      } else {
        isLoading = true;
        setState(() {});
        try {
          if (widget.album.currentPage == 0) {
            widget.album.isDone = await downloader.isDownloaded(widget.album);
            widget.album.isBookmarked =
                bookmarks.containsKey(Settings.keyOfBookmark(widget.album));
//                bookmarks.contains(AlbumPreview("", widget.album.urld, ""));
//            print("album isDone: ${widget.album.isDone}");
//            print("album isBookmarked: ${widget.album.isBookmarked}");
            widget.onGlobalRefreshNeeded(currentPicIndex);
          }
          await Parsers.loadAlbumNextPage(widget.album,
              isDone: widget.album.isDone);
          if (widget.album.saveDir == null) {
            widget.album.saveDir = await getSaveRootDir() +
                "/${widget.album.urld.realDomain}/${widget.album.title}";
          }
          if (widget.album.rSeed == null && widget.album.totalSize > 0) {
            widget.album.rSeed = new List(widget.album.totalSize);
          }
          isLoading = false;
          setState(() {});
        } catch (Exception) {
          isLoading = false;
          rethrow;
        }
      }
    }
  }
}
