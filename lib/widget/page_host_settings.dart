import 'package:flutter/material.dart';
import 'package:flutter_app_picviewer/global.dart';
import 'package:html/parser.dart';
import 'package:flutter/services.dart';

import '../domain/urld.dart';
import '../global.dart';
import './drawer.dart';
import '../util/custom_http.dart' as http;

class HostPage extends StatefulWidget {
  HostPage({Key key}) : super(key: key);

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  Map<String, dynamic> hostsMap;
  List<String> listKey;
  List listValue;
  String portStr;
  String jStr;

  @override
  void initState() {
    super.initState();
    hostsMap = {};
    hostsMap.addAll(hosts);
    listKey = hostsMap.keys.toList();
    listValue = hostsMap.values.toList();
    portStr = '$port';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
          body: ListView.builder(
              itemCount: hostsMap.length + 3,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Container(
                    margin: EdgeInsets.fromLTRB(0, 25, 0, 25),
                    alignment: Alignment.center,
                    child: Text(
                      '本地hosts设置',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                if (index == hostsMap.length + 1) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Row(
                      textBaseline: TextBaseline.ideographic,
                      children: <Widget>[
                        Expanded(
                          child: Text('代理端口'),
                        ),
                        Expanded(
                          child: TextField(
                            controller:
                                new TextEditingController(text: '$port'),
                            onChanged: (value) {
                              portStr = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (index == hostsMap.length + 2) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        getDomainBtn(),
                        getSaveBtn(),
                        getResetBtn(),
                      ],
                    ),
                  );
                }
                index--;
                return Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Row(
                    textBaseline: TextBaseline.ideographic,
                    children: <Widget>[
                      Expanded(
                        child: Text(listKey[index]),
                      ),
                      Expanded(
                        child: TextField(
                          controller:
                              new TextEditingController(text: listValue[index]),
                          onChanged: (value) {
                            listValue[index] = value;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              })),
    );
  }

  Widget getDomainBtn(){
    return Container(
      margin: EdgeInsets.fromLTRB(5, 25, 5, 3),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.all(new Radius.circular(10.0)),
        color: Colors.lightBlue,
      ),
      child: MaterialButton(
        child: Text('获取域名'),
        onPressed: () {
          if(proxy == null){
            CuDialog.show(context, '请先打开代理！！');
            return;
          }
          http
              .getCommonUrl(
              urlWithProtocol: 'https://www.javbus.com',
              porxyPort: port)
              .then((html) {
            final list = [];
            parse(html)
                .querySelectorAll(
                ".alert .row .col-xs-12 a")
                .forEach((ele) {
              if (ele.attributes['rel'] == 'nofollow') {
                list.add(ele.attributes['href']);
              }
            });
            showDialog(
              context: context,
              child: AlertDialog(
                content: Text(list.toString()),
                actions: <Widget>[
                  FlatButton(
                    child: new Text('确定'),
                    onPressed: () {Navigator.of(context).pop();},
                  ),
                  FlatButton(
                    child: new Text('复制'),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: list.length>0 ?list[0] : "[]"));
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget getSaveBtn(){
    return Container(
      margin: EdgeInsets.fromLTRB(5, 25, 5, 3),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.all(new Radius.circular(10.0)),
        color: Colors.lightBlue,
      ),
      child: MaterialButton(
        child: Text('保存'),
        onPressed: () {
          for (int i = 0; i < listKey.length; i++) {
            hostsMap[listKey[i]] = listValue[i];
          }
          hosts.addAll(hostsMap);
          Settings.setHosts(hostsMap);

          port = int.parse(portStr);
          Settings.setPort(port);

          Settings.setJav(jStr);
        },
      ),
    );
  }
  Widget getResetBtn(){
    return  Container(
      margin: EdgeInsets.fromLTRB(5, 25, 5, 3),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.all(new Radius.circular(10.0)),
        color: Colors.lightBlue,
      ),
      child: MaterialButton(
        child: Text('重置'),
        onPressed: () {
          listValue = hostsMap.values.toList();
          setState(() {});
        },
      ),
    );
  }
}

