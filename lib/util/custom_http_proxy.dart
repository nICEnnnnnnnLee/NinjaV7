import 'dart:io';
import 'dart:convert';



class CustomHttpsProxy {
  final Map hosts;
  final int port;

  ServerSocket serverSocket;

  CustomHttpsProxy({this.hosts, this.port});

  Future init() async {
    await ServerSocket.bind(InternetAddress.anyIPv4, port).then((serverSocket) {
      this.serverSocket = serverSocket;
      serverSocket.listen((client) {
        try {
          ClientConnectionHandler(client, hosts).handle();
        } catch (e) {
          print('ClientConnectionHandler exception $e');
        }
      });
    }).catchError((e) {
      print('serverSocket 处理异常$e');
    });
    return serverSocket;
  }

  void close() {
    if (serverSocket != null) {
      serverSocket.close();
    }
  }
}

class ClientConnectionHandler {
  final RegExp regx = RegExp(r'CONNECT ([^ :]+)(?::([0-9]+))? HTTP/1.1\r\n');
  final Map hosts;

  Socket server;
  Socket client;
  String content = '';
  String host;
  int port;

  ClientConnectionHandler(this.client, this.hosts);

  void closeSockets() {
//    print('socket is going to destroy');
    if (server != null) {
      server.destroy();
    }
    client.destroy();
  }

  void dataHandler(data) {
    if (server == null) {
      content += utf8.decode(data);
      final m = regx.firstMatch(content);
      if (m != null) {
        host = m.group(1);
        port = m.group(2) == null ? 443 : int.parse(m.group(2));
        final realHost = hosts != null && hosts.containsKey(host) ? hosts[host] : host;
        try {
          ServerConnectionHandler(realHost, port, this)
              .handle()
              .catchError((e) {
            print('Server error $e');
            closeSockets();
          });
        } catch (e) {
          print('Server exception $e');
          closeSockets();
        }
      }
    } else {
      try {
        server.add(data);
      } catch (e) {
        print('sever has been shut down');
        closeSockets();
      }
    }
  }

  void errorHandler(error, StackTrace trace) {
    print('client socket error: $error');
  }

  void doneHandler() {
    closeSockets();
  }

  void handle() {
    client.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: true);
  }
}

class ServerConnectionHandler {
  final String RESPONSE = 'HTTP/1.1 200 Connection Established\r\n\r\n';
  final String host;
  final int port;
  final ClientConnectionHandler handler;
  Socket server;
  Socket client;
  String content = '';

  ServerConnectionHandler(this.host, this.port, this.handler) {
    client = handler.client;
  }

  //接收报文
  void dataHandler(data) {
    try {
      client.add(data);
    } on Exception catch (e) {
      print('client has been shut down $e');
      handler.closeSockets();
    }
  }

  void errorHandler(error, StackTrace trace) {
    print('server socket error: $error');
  }

  void doneHandler() {
    handler.closeSockets();
  }

  Future handle() async {
//    print('尝试建立连接： $host:$port');
    server = await Socket.connect(host, port, timeout: Duration(seconds: 60));
    server.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: true);
    handler.server = server;
    client.write(RESPONSE);
  }
}