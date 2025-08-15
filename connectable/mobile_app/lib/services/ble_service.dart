import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService extends ChangeNotifier {
  final FlutterBluePlus _ble = FlutterBluePlus.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _txChar;
  bool scanning = false;

  String? get connectedDeviceName => _device?.platformName;

  // UUIDs ต้องตรงกับฝั่ง ESP32
  static const String serviceUuid = String.fromEnvironment(
    'BLE_SERVICE_UUID',
    defaultValue: '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
  );
  static const String charUuid = String.fromEnvironment(
    'BLE_CHAR_UUID',
    defaultValue: '6e400003-b5a3-f393-e0a9-e50e24dcca9e',
  );

  Future<void> scanAndConnect() async {
    scanning = true; notifyListeners();
    try {
      await _ble.startScan(timeout: const Duration(seconds: 6));
      await for (final res in _ble.scanResults) {
        for (final r in res) {
          // เลือกอุปกรณ์ใดๆ ที่โฆษณา serviceUuid นี้
          if (r.advertisementData.serviceUuids.contains(serviceUuid)) {
            _device = r.device;
            await _ble.stopScan();
            await _device!.connect(timeout: const Duration(seconds: 6));
            final services = await _device!.discoverServices();
            for (final s in services) {
              if (s.uuid.str128 == serviceUuid) {
                for (final c in s.characteristics) {
                  if (c.uuid.str128 == charUuid) {
                    _txChar = c;
                    scanning = false; notifyListeners();
                    return;
                  }
                }
              }
            }
          }
        }
      }
    } catch (_) {
      // ignore
    } finally {
      scanning = false; notifyListeners();
    }
  }

  Future<void> sendText(String text) async {
    if (_txChar == null) return;
    final truncated = text.characters.take(20).toString();
    await _txChar!.write(utf8.encode(truncated), withoutResponse: true);
  }
}
