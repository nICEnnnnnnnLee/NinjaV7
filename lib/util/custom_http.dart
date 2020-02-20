import 'package:dio/dio.dart';
import 'package:flutter_app_picviewer/util/custom_log_util.dart';
import '../domain/urld.dart';
//Future<String> getCommonUrl({Uri uri, URLd urld, Map headers}) async{
//  if(uri == null){
//      uri = Uri.https(urld.domain, urld.path);
//  }
//  var httpClient = new HttpClient();
//  var request = await httpClient.getUrl(uri);
//  request.headers.set("User-Agent", "Mozilla/5.0 (Android 9.0; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0");
//  request.headers.set("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
//  request.headers.set("Accept-Language", "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2");
//  request.headers.set("Accept-Encoding", "gzip, deflate, br");
//
//  if(headers != null){
//    headers.forEach((key, value){
//      request.headers.add(key, value);
//    });
//  }
//  var response = await request.close();
//  var responseBody = await response.transform(utf8.decoder).join();
//  return responseBody;
//}


const Map<String, dynamic> defaultHeaders = {
  "User-Agent":
      "Mozilla/5.0 (Android 9.0; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0",
  "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "Accept-Language":
      "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
  "Accept-Encoding": "gzip, deflate",//br 乱码
};

Future<String> getCommonUrl({URLd urld, String urlWithProtocol, Map headers, int porxyPort}) async {
  var headerMap ;
  if(headers == null){
    headerMap = defaultHeaders;
  } else{
    headerMap = new Map<String, dynamic>();
    headerMap.addAll(defaultHeaders);
    headerMap.addAll(headers);
  }

  Options options = Options(
    headers: headerMap,
//    connectTimeout: 20000,
    responseType: ResponseType.plain,
  );
  Dio dio = Dio();

  if(porxyPort != null){
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
      client.findProxy = (uri) => 'PROXY localhost:$porxyPort';
    };
  }

  if(urlWithProtocol == null){
    urlWithProtocol = urld.urlWithProtocol;
  }
//  print("访问请求： ${urlWithProtocol}");
  final response = await dio.get(urlWithProtocol, options: options);
//  print("${response.headers}");
  var responseBody = response.toString();
//  LogUtil.d(responseBody);
  return responseBody;
}
