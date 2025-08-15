import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsService extends ChangeNotifier {
  WebSocketChannel? _ch;
  bool get connected => _ch != null;
  final List<Map<String, dynamic>> messages = [];

  // เปลี่ยน URL ตาม .env (ใส่ค่าเวลาบิลด์หรือ const)
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://10.0.2.2:8081',
  );

  WsService() {
    _tryConnect();
  }

  void _tryConnect() {
    try {
      _ch = WebSocketChannel.connect(Uri.parse(wsUrl));
      _ch!.stream.listen((event) {
        final data = jsonDecode(event);
        messages.add({'sender': 'other', 'text': data['text']});
        notifyListeners();
      }, onDone: () {
        _ch = null;
        notifyListeners();
        Future.delayed(const Duration(seconds: 2), _tryConnect);
      }, onError: (_) {
        _ch = null;
        notifyListeners();
        Future.delayed(const Duration(seconds: 3), _tryConnect);
      });
    } catch (_) {
      _ch = null;
      notifyListeners();
      Future.delayed(const Duration(seconds: 3), _tryConnect);
    }
  }

  void send(String text) {
    messages.add({'sender': 'me', 'text': text});
    notifyListeners();
    _ch?.sink.add(jsonEncode({'text': text}));
  }

  @override
  void dispose() {
    _ch?.sink.close();
    super.dispose();
  }
}
