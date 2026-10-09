import 'package:flutter/material.dart';
import 'screens/app_shell.dart';
import 'services/scan_storage.dart';
import 'services/app_inventory_service.dart';

class AiSecurityApp extends StatefulWidget {
  const AiSecurityApp({required this.storage, super.key});
  final ScanStorage storage;

  @override
  State<AiSecurityApp> createState() => _AiSecurityAppState();
}

class _AiSecurityAppState extends State<AiSecurityApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff176b87),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'AI Security',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfff7fafb),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: const CardThemeData(margin: EdgeInsets.zero, elevation: 0),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff73c7dc),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero, elevation: 0),
      ),
      home: AppShell(
        storage: widget.storage,
        inventoryService: AppInventoryService(),
        onToggleTheme: () => setState(() {
          _themeMode = _themeMode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark;
        }),
      ),
    );
  }
}
