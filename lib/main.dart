import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/services/scan_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = ScanStorage();
  await storage.init();
  runApp(AiSecurityApp(storage: storage));
}
