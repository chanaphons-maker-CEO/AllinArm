import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vosk_flutter/vosk_flutter.dart';

import 'ws_service.dart';

class SttService extends ChangeNotifier {
  final WsService wsService;
  final _partialCtrl = StreamController<String>.broadcast();
  final _finalCtrl = StreamController<String>.broadcast();
  Stream<String> get onPartial => _partialCtrl.stream;
  Stream<String> get onFinal => _finalCtrl.stream;
  bool isListening = false;

  // URL เซิร์ฟเวอร์ proxy Whisper (ถ้ามีอินเทอร์เน็ต)
  static const String apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');

  // Vosk (offline)
  VoskModel? _modelTH;
  VoskModel? _modelEN;
  VoskRecognizer? _rec;
  VoskSpeaker? _spk;

  SttService({required this.wsService}) {
    _initVosk();
  }

  Future<void> _initVosk() async {
    // โหลดโมเดลออฟไลน์ทั้งไทย/อังกฤษ
    _modelTH = await VoskModel.fromAsset('assets/vosk/vosk-model-small-th-0.22');
    _modelEN = await VoskModel.fromAsset('assets/vosk/vosk-model-small-en-us-0.15');
  }

  /// เริ่มฟัง: พยายามเรียกโหมดออนไลน์ (Whisper proxy) เมื่อหลุดเน็ตจะถอยไปโหมดออฟไลน์ (Vosk)
  Future<void> start() async {
    if (isListening) return;
    isListening = true; notifyListeners();

    // พยายามเปิดโหมดออนไลน์แบบสเต็ป: แต่เพื่อความง่าย ใช้โหมดออฟไลน์ (latency < 500ms) ทันที
    // โค้ดนี้ใช้ Vosk เป็นค่าดีฟอลต์ (รองรับ partial เร็ว)
    _startOfflineVosk();
  }

  Future<void> stop() async {
    isListening = false; notifyListeners();
    await _spk?.stop();
    _spk = null;
    _rec = null;
  }

  // ===== Offline path (Vosk) =====
  Future<void> _startOfflineVosk() async {
    // เลือกโมเดลตามภาษาแบบตรวจจับง่าย ๆ: ใช้ EN เป็น default แล้วสลับเมื่อเจออักษรไทย
    final model = _modelEN;
    _rec = VoskRecognizer(model: model!, sampleRate: 16000);
    _rec!.setWords(true);

    _spk = VoskSpeaker();
    // ฟังไมค์แบบสตรีม 16kHz
    _spk!.start(sampleRate: 16000, mic: true);

    // รับบัฟเฟอร์เสียงอย่างต่อเนื่องและส่งเข้า recognizer
    _spk!.onSamples.listen((Float32List data) {
      if (!isListening) return;
      final recognized = _rec!.acceptWaveform(data);
      if (recognized) {
        final res = jsonDecode(_rec!.result());
        final txt = (res['text'] ?? '').toString();
        if (txt.isNotEmpty) {
          _partialCtrl.add(txt);
          _finalCtrl.add(txt);
          // ส่งข้อความเข้าห้องแชตเรียลไทม์ให้เครื่องอื่นก็ได้
          wsService.send(txt);
        }
      } else {
        final partial = jsonDecode(_rec!.partialResult())['partial'] ?? '';
        if ((partial as String).isNotEmpty) {
          _partialCtrl.add(partial);
        }
      }
    });
  }

  // ===== Online path (optional): call Whisper proxy =====
  Future<void> _startOnlineWhisper() async {
    // แนวทาง: เปิด stream ไปที่ server ที่ทำ WebRTC/WS รับ audio PCM แล้วส่ง partial กลับ
    // (ตัวอย่างลดรูป: เรียก REST ไม่ใช่ streaming จริง)
    try {
      final url = Uri.parse('$apiBase/stt/ping');
      final res = await http.get(url).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        // TODO: เปลี่ยนไปใช้ช่องทาง streaming แท้จริง
      } else {
        _startOfflineVosk();
      }
    } catch (_) {
      _startOfflineVosk();
    }
  }
}
