import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_picviewer/util/custom_http_proxy.dart';

import '../global.dart';
import '../widget/page_host_settings.dart';
import '../widget/page_path_settings.dart';
class CustomDrawer extends StatelessWidget {
  final Function() openUrl;
  final Function() copyUrl;
  final Function() shareUrl;

  CustomDrawer(
      {Key key,
      @required this.openUrl,
      @required this.copyUrl,
      @required this.shareUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 16.0,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text('我是大撒比', style: TextStyle(fontSize: 28)),
                  accountEmail: Text('每天说一声我是大撒比，防止抑郁'),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('images/github_loding.gif'),
                  ),
                  otherAccountsPictures: <Widget>[
                    CircleAvatar(
                        backgroundImage: AssetImage('images/github_head.png')),
                    CircleAvatar(
                        backgroundImage: AssetImage('images/github_head.png')),
                    CircleAvatar(
                        backgroundImage: AssetImage('images/github_head.png'))
                  ],
                  arrowColor: Colors.transparent,
                  onDetailsPressed: () {
                    print("...这也被你找到了");
                  },
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/background.jpg'),
                        fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text('返回主页'),
                        onTap: () {
                          Navigator.of(context)
                              .popUntil(ModalRoute.withName("/home"));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.content_copy),
                        title: Text('复制当前页链接'),
                        onTap: () {
                          copyUrl();
                          CuDialog.show(context, '链接已复制');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.share),
                        title: Text('分享当前页'),
                        onTap: () {
                          shareUrl();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.open_in_browser),
                        title: Text('在浏览器中打开页面'),
                        onTap: () {
                          openUrl();
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text('广告开关'),
                        onTap: () {
                          Settings.triggerAD();
                          CuDialog.show(context, '当前广告状态：${Settings.showAD()}');
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.send),
                        title: Text('设置Hosts'),
                        onTap: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => HostPage()));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.check),
                        title: Text('打开代理'),
                        onTap: () {
                          if(proxy != null){
                            CuDialog.show(context, '代理已建立，无需再次建立');
                            return;
                          }
                          proxy = CustomHttpsProxy(hosts: hosts, port: port);
                          proxy.init().then((onValue){
                            findProxy = (uri){
                              if(uri.host == ('xmoviesforyou.com')){
//                              print('you\'re requsting a pic from ${uri}');
                                return 'PROXY localhost:$port';
                              }else
                                return 'DIRECT';
                            };
                            CuDialog.show(context, '代理已建立');
                          });

                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.close),
                        title: Text('关闭代理'),
                        onTap: () {
                          proxy?.close();
                          proxy = null;
                          findProxy = null;
                          CuDialog.show(context, '代理已关闭');
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('路径修改'),
                        onTap: () {
                          getSaveRootDir().then((path){
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => PathPage(initPath: path,)));
                          });

                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.save),
                        title: Text('导出配置'),
                        onTap: () {
                          Settings.export();
                          CuDialog.show(context, '配置已导出');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.import_export),
                        title: Text('导入配置'),
                        onTap: () {
                          Settings.import();
                          CuDialog.show(context, '配置已导入');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.search),
                        title: Text('扫描补全下载列表'),
                        onTap: () {
                          Settings.importDownloadedFromSDCard();
                          CuDialog.show(context, '扫描已完成');
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.lock_open),
                        title: Text('图片系统可见'),
                        onTap: () {
                          nomedia(false);
                          CuDialog.show(context, '.nomedia文件已删除');
                        },
                      ),
                      ListTile(
                          leading: Icon(Icons.lock_outline),
                          title: Text('图片系统不可见'),
                          onTap: () {
                            nomedia(true);
                            CuDialog.show(context, '.nomedia文件已创建');
                          }),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                bottom: 10,
                right: 10,
                child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.power_settings_new),
                      Text('退出')
                    ],
                  ),
                  onTap: () {
                    SystemNavigator.pop();
                  },
                ))
          ],
        ));
  }

}

class CuDialog{
  static show(BuildContext context, String text){
    showDialog(
      context: context,
      child: AlertDialog(
        content: Text(text),
      ),
    );
  }
}

//
