enum ScanKind { message, url, apps }

enum RiskLevel { low, good, needsAttention, high, critical }

extension RiskLevelLabel on RiskLevel {
  String get label => switch (this) {
        RiskLevel.low => 'Low Risk',
        RiskLevel.good => 'Good',
        RiskLevel.needsAttention => 'Needs Attention',
        RiskLevel.high => 'High Risk',
        RiskLevel.critical => 'Critical',
      };
}

class ScanResult {
  const ScanResult({
    required this.score,
    required this.level,
    required this.title,
    required this.reasons,
    required this.explanation,
    required this.recommendation,
  });
  final int score;
  final RiskLevel level;
  final String title;
  final List<String> reasons;
  final String explanation;
  final String recommendation;
}

class ScanSummary {
  const ScanSummary({
    required this.kind,
    required this.score,
    required this.createdAt,
    required this.title,
  });
  final ScanKind kind;
  final int score;
  final DateTime createdAt;
  final String title;
}

class InstalledAppInfo {
  const InstalledAppInfo({
    required this.name,
    required this.packageName,
    required this.version,
    required this.permissions,
    required this.score,
    required this.status,
    required this.isSystemApp,
  });
  final String name;
  final String packageName;
  final String version;
  final List<String> permissions;
  final int score;
  final String status;
  final bool isSystemApp;
}
