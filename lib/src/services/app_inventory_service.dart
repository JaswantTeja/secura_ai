import 'package:flutter/services.dart';

import '../models/scan_models.dart';

class AppInventoryService {
  static const _channel = MethodChannel('ai_security/apps');

  Future<List<InstalledAppInfo>> loadApps() async {
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('listApps') ?? [];
      return raw.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final permissions = List<String>.from(
          map['permissions'] as List? ?? [],
        );
        final sensitive = permissions
            .where(
              (permission) =>
                  permission.contains('SMS') ||
                  permission.contains('CONTACTS') ||
                  permission.contains('RECORD_AUDIO') ||
                  permission.contains('SYSTEM_ALERT_WINDOW') ||
                  permission.contains('ACCESSIBILITY'),
            )
            .length;
        final score =
            (100 - sensitive * 15 - ((map['systemApp'] == true) ? 0 : 0)).clamp(
              0,
              100,
            );
        final status = score >= 76
            ? 'Low Risk'
            : score >= 51
            ? 'Needs Review'
            : score >= 26
            ? 'High Risk'
            : 'Critical';
        return InstalledAppInfo(
          name: map['name'] as String? ?? 'Unknown app',
          packageName: map['packageName'] as String? ?? '',
          version: map['version'] as String? ?? 'Unknown',
          permissions: permissions,
          score: score,
          status: status,
          isSystemApp: map['systemApp'] as bool? ?? false,
        );
      }).toList();
    } on MissingPluginException {
      return [];
    } on PlatformException {
      return [];
    }
  }
}
