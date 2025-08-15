import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ble_service.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleService>();
    final theme = context.watch<AppThemeNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: { theme.mode },
            onSelectionChanged: (s) => theme.setMode(s.first),
          ),
          const SizedBox(height: 24),
          const Text('Bluetooth (BLE) badge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: ble.scanning ? null : ble.scanAndConnect,
                icon: const Icon(Icons.bluetooth_searching),
                label: Text(ble.scanning ? 'Scanning...' : 'Scan & Connect'),
              ),
              const SizedBox(width: 12),
              Text(ble.connectedDeviceName ?? 'Not connected'),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Send text to badge (<= 20 chars)',
              border: OutlineInputBorder(),
            ),
            maxLength: 20,
            onSubmitted: (txt) async {
              await ble.sendText(txt);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent over BLE')));
            },
          ),
          const SizedBox(height: 24),
          const Text('Language & STT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Auto-detect Thai/English. Offline fallback via Vosk models in assets.'),
        ],
      ),
    );
  }
}
