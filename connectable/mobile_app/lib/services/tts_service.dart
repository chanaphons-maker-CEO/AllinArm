import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  TtsService() {
    // ตั้งค่าเริ่มต้น: ให้รองรับไทย/อังกฤษ และใช้ออฟไลน์เอนจิน (หากเครื่องมี)
    _tts.setSpeechRate(0.9);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  /// พูดข้อความ (จะใช้ voice ที่ระบบรองรับ: th-TH, en-US)
  Future<void> speak(String text) async {
    // ตรวจจับง่าย ๆ: ไทย/อังกฤษ
    final isThai = _looksThai(text);
    await _tts.setLanguage(isThai ? 'th-TH' : 'en-US');
    await _tts.speak(text);
  }

  bool _looksThai(String s) {
    return RegExp(r'[\u0E00-\u0E7F]').hasMatch(s);
  }
}
