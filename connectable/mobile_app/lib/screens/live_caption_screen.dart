import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../widgets/floating_caption.dart';

class LiveCaptionScreen extends StatefulWidget {
  const LiveCaptionScreen({super.key});

  @override
  State<LiveCaptionScreen> createState() => _LiveCaptionScreenState();
}

class _LiveCaptionScreenState extends State<LiveCaptionScreen> {
  String _lastPartial = '';
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final stt = context.read<SttService>();
    stt.onPartial.listen((partial) {
      setState(() => _lastPartial = partial);
    });
    stt.onFinal.listen((text) {
      // อัปเดต UI หรือส่งไป WS ให้เครื่องอื่นได้
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stt = context.watch<SttService>();
    final tts = context.read<TtsService>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Live Captions'),
            actions: [
              IconButton(
                tooltip: stt.isListening ? 'Stop' : 'Start',
                icon: Icon(stt.isListening ? Icons.mic_off : Icons.mic),
                onPressed: () {
                  stt.isListening ? stt.stop() : stt.start();
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // แสดงข้อความสดแบบตัวใหญ่คอนทราสต์สูง
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        _lastPartial.isEmpty ? '——' : _lastPartial,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.send,
                        decoration: const InputDecoration(
                          labelText: 'Type to speak (TTS)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (txt) async {
                          if (txt.trim().isEmpty) return;
                          await tts.speak(txt);
                          _inputController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () async {
                        final txt = _inputController.text.trim();
                        if (txt.isEmpty) return;
                        await tts.speak(txt);
                        _inputController.clear();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // แคปชันลอยแบบ AR (ลากวางตำแหน่งได้)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: FloatingCaption(text: _lastPartial),
          ),
        ),
      ],
    );
  }
}
