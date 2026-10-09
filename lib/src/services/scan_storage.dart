import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_models.dart';

class ScanStorage {
  late SharedPreferences _prefs;
  final List<ScanSummary> summaries = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getStringList('scan_summaries') ?? [];
    summaries.addAll(raw.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return ScanSummary(
        kind: ScanKind.values.byName(map['kind'] as String),
        score: map['score'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
        title: map['title'] as String,
      );
    }));
  }

  Future<void> add(ScanSummary summary) async {
    summaries.insert(0, summary);
    if (summaries.length > 20) summaries.removeLast();
    await _prefs.setStringList(
      'scan_summaries',
      summaries
          .map((item) => jsonEncode({
                'kind': item.kind.name,
                'score': item.score,
                'createdAt': item.createdAt.toIso8601String(),
                'title': item.title,
              }))
          .toList(),
    );
  }
}
