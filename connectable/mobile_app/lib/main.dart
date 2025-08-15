import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'screens/live_caption_screen.dart';
import 'screens/messaging_screen.dart';
import 'screens/settings_screen.dart';
import 'services/stt_service.dart';
import 'services/tts_service.dart';
import 'services/ble_service.dart';
import 'services/ws_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // สร้าง service พื้นฐานไว้ใช้งานทั่วแอป
  final wsService = WsService();
  final bleService = BleService();
  final sttService = SttService(wsService: wsService);
  final ttsService = TtsService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppThemeNotifier()),
        Provider.value(value: wsService),
        Provider.value(value: bleService),
        Provider.value(value: sttService),
        Provider.value(value: ttsService),
      ],
      child: const ConnectAbleApp(),
    ),
  );
}

class AppThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  void setMode(ThemeMode m) { _mode = m; notifyListeners(); }
}

class ConnectAbleApp extends StatelessWidget {
  const ConnectAbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeNotifier>(context);
    return MaterialApp(
      title: 'ConnectAble',
      debugShowCheckedModeBanner: false,
      themeMode: theme.mode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      home: const RootTabs(),
      localizationsDelegates: const [
        // ใช้ localizations ของ Flutter (เลือกเพิ่ม intl later)
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th'),
        Locale('en'),
      ],
    );
  }
}

class RootTabs extends StatefulWidget {
  const RootTabs({super.key});
  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _idx = 0;
  final _screens = const [
    LiveCaptionScreen(),
    MessagingScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.subtitles), label: 'Captions'),
          NavigationDestination(icon: Icon(Icons.chat_bubble), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (i) => setState(() => _idx = i),
      ),
    );
  }
}
