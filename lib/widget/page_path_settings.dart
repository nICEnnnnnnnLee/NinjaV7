import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_picviewer/global.dart';

class PathPage extends StatefulWidget {
  final String initPath;

  const PathPage({Key key, @required this.initPath}) : super(key: key);

  @override
  _PathPageState createState() => _PathPageState();
}

class _PathPageState extends State<PathPage> {
  Directory currentDir;
  List<FileSystemEntity> childs;
  String dirNameToCreate;

  @override
  void initState() {
    super.initState();
    dirNameToCreate = '';
    reset(widget.initPath);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool reset(String path) {
    final dirToSet = Directory(path);
    try {
      final childList = dirToSet.listSync(); // 这一步可能会抛出异常
      currentDir = dirToSet;
      childs = [];
      childList.sort((left, right) => left.path.compareTo(right.path));
      childList.forEach((f) {
        if (FileSystemEntity.isDirectorySync(f.path)) {
          childs.add(f);
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var path = currentDir.path;
    final maxLen = 50;
    if (path.length >= maxLen - 3) {
      path = '...' + path.substring(path.length - maxLen + 3);
    }
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('保存路径设置'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: () {
                final file = File('${currentDir.path}/.testWoshishabi');
                try {
                  file.createSync();
                  file.deleteSync();
                  Settings.setSaveDirPath(currentDir.path);
                  CuDialog.show(context, text: '保存成功！');
                } catch (e) {
                  CuDialog.show(context, text: '保存失败！');
                }
              },
              icon: CircleAvatar(
                child: Icon(Icons.check),
              ),
              iconSize: 60,
              tooltip: '保存设置',
            ),
            IconButton(
              onPressed: () {
                CuDialog.show(context,
                    content: TextField(
                      controller:
                          TextEditingController(text: this.dirNameToCreate),
                      maxLines: 1,
                      onChanged: (val) {
                        dirNameToCreate = val;
                      },
                      decoration: InputDecoration(hintText: '请输入要创建的文件夹名称...'),
                    ),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            if (dirNameToCreate.isEmpty) return;
                            final dir = Directory(
                                '${currentDir.path}/$dirNameToCreate');
                            dir.createSync();
                            reset(currentDir.path);
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Text('确认')),
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('取消'))
                    ]);
              },
              icon: CircleAvatar(
                child: Icon(Icons.add),
              ),
              iconSize: 60,
              tooltip: '创建文件夹',
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                path,
                softWrap: false,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              width: double.infinity,
              padding: EdgeInsets.only(left: 10, top: 5),
            ),
            MaterialButton(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  width: 1,
                ))),
                alignment: Alignment.centerLeft,
                child: Text(
                  '向上一层',
                  style: TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onPressed: () {
                var path = currentDir.parent.path;
                if (!reset(path)) {
                  CuDialog.show(context, text: '未能获取到该文件夹信息...');
                }
                setState(() {});
              },
            ),
            SizedBox(
              child: ListView.builder(
                itemCount: childs.length,
                itemBuilder: (BuildContext context, int index) {
                  final parentNameLen = childs[index].parent.path.length;
                  final name = childs[index].path.substring(parentNameLen + 1);

                  return MaterialButton(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 1,
                      ))),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onPressed: () {
                      var path = childs[index].path;
                      if (!reset(path)) {
                        CuDialog.show(context, text: '未能获取到该文件夹信息...');
                      }
                      setState(() {});
                    },
                  );
                },
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 180,
            )
          ],
        ),
      ),
    );
  }
}

class CuDialog {
  static show(BuildContext context,
      {String text, Widget content, List<Widget> actions}) {
    showDialog(
      context: context,
      child: AlertDialog(
        content: text != null ? Text(text) : content,
        actions: actions,
      ),
    );
  }
}
