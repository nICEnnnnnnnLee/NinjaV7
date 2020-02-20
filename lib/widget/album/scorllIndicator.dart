part of '../page_album.dart';

class ScrollIndicator extends StatefulWidget {
  final int totalSize;
  final int currentPicIndex;
  final ScrollController scrollController;
  final Function(DragStartDetails drag) onHorizontalDragStart;
  final Function(DragUpdateDetails drag, int index) onHorizontalDragUpdate;
  final Function(DragEndDetails drag) onHorizontalDragEnd;

  ScrollIndicator({
    Key key,
    this.totalSize,
    this.currentPicIndex,
    this.scrollController,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
  }) : super(key: key);

  @override
  _ScrollIndicator createState() => _ScrollIndicator();
}

class _ScrollIndicator extends State<ScrollIndicator> {

  double startPos;
  double pStartPercent;
  double currentPos;
  double pCurrentPercent;
  bool isDragging = false;

  int percentToIndex(int totalCount, double percent) {
    int index = (totalCount * percent).round();
    if (index == totalCount) index--;
    return index;
  }

  double indexToPercent(int currentPicIndex) {
    return widget.totalSize == 0
        ? 0
        : currentPicIndex * 1.0 / (widget.totalSize - 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        height: 100.0,
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            isDragging
                ? Text(
              "${widget.currentPicIndex}",
              style: TextStyle(color: Colors.white),
            )
                : Text(""),
            SizedBox(
                height: 4.0,
                width: 250,
                child: CustomPaint(
                  painter: ScrollIndicatorPainter(
                      scrollPercent: indexToPercent(widget.currentPicIndex)),
                  child: Container(),
                )),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),

      onHorizontalDragStart: (DragStartDetails drag) {
        isDragging = true;
        startPos = drag.localPosition.dx;
        pStartPercent = indexToPercent(widget.currentPicIndex);
        widget.onHorizontalDragStart(drag);
      },
      onHorizontalDragEnd: (DragEndDetails drag) {
        isDragging = false;
        widget.onHorizontalDragEnd(drag);
      },
      onHorizontalDragUpdate: (DragUpdateDetails drag) {
        currentPos = drag.localPosition.dx;
        pCurrentPercent = pStartPercent + (currentPos - startPos) / 200.0;
        if (pCurrentPercent < 0) pCurrentPercent = 0;
        if (pCurrentPercent > 1) pCurrentPercent = 1;
        int tempIndex = percentToIndex(widget.totalSize, pCurrentPercent);
        if (tempIndex != widget.currentPicIndex) {
          widget.onHorizontalDragUpdate(drag, percentToIndex(widget.totalSize, pCurrentPercent));
        }
      },
    );
  }
}

class ScrollIndicatorPainter extends CustomPainter {
  ScrollIndicatorPainter({this.scrollPercent})
      : trackPaint = Paint()
    ..color = Color(0xFF444444)
    ..style = PaintingStyle.fill,
        thumbPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

  final double scrollPercent;
  final Paint trackPaint;
  final Paint thumbPaint;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, size.width, size.height),
        topLeft: Radius.circular(3.0),
        topRight: Radius.circular(3.0),
        bottomLeft: Radius.circular(3.0),
        bottomRight: Radius.circular(3.0),
      ),
      trackPaint,
    );

    final thumbLeft = scrollPercent * size.width;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, thumbLeft, size.height),
        topLeft: Radius.circular(3.0),
        bottomLeft: Radius.circular(3.0),
        topRight:
        scrollPercent == 1 ? Radius.circular(3.0) : Radius.circular(0.0),
        bottomRight:
        scrollPercent == 1 ? Radius.circular(3.0) : Radius.circular(0.0),
      ),
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}