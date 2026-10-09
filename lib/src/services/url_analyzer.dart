import '../models/scan_models.dart';

class UrlAnalyzer {
  ScanResult analyze(String input) {
    final value = input.trim();
    final lower = value.toLowerCase();
    final reasons = <String>[];
    var risk = 0;
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) {
      return const ScanResult(
        score: 100,
        level: RiskLevel.critical,
        title: 'Invalid URL',
        reasons: ['The input is not a complete URL'],
        explanation: 'Enter a full URL such as https://example.com.',
        recommendation: 'Do not open malformed links from unknown senders.',
      );
    }
    if (uri.scheme != 'https') {
      reasons.add('No HTTPS encryption');
      risk += 18;
    }
    if (RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(uri.host)) {
      reasons.add('IP-based URL');
      risk += 27;
    }
    if (['bit.ly', 'tinyurl.com', 't.co', 'is.gd', 'ow.ly'].contains(uri.host)) {
      reasons.add('URL shortener');
      risk += 20;
    }
    if (uri.host.split('.').length > 3) {
      reasons.add('Excessive subdomains');
      risk += 12;
    }
    if (uri.host.startsWith('xn--') || uri.host.contains('.xn--')) {
      reasons.add('Punycode domain');
      risk += 18;
    }
    if (uri.hasPort && uri.port != 443 && uri.port != 80) {
      reasons.add('Unusual port');
      risk += 15;
    }
    if (RegExp(r'(login|verify|secure|wallet|bonus|claim|prize|password|bank)').hasMatch(lower)) {
      reasons.add('Suspicious keywords');
      risk += 14;
    }
    if (uri.pathSegments.length > 5 || value.contains('@') || value.contains('..')) {
      reasons.add('Unusual URL structure');
      risk += 12;
    }
    final score = risk.clamp(0, 100);
    final level = score >= 76
        ? RiskLevel.critical
        : score >= 51
            ? RiskLevel.high
            : score >= 26
                ? RiskLevel.needsAttention
                : RiskLevel.good;
    return ScanResult(
      score: score,
      level: level,
      title: reasons.isEmpty ? 'No obvious red flags' : reasons.first,
      reasons: reasons,
      explanation: 'HTTPS is only one signal; it does not prove that a website is safe.',
      recommendation: score >= 51
          ? 'Do not enter credentials or payment details. Verify the domain independently.'
          : 'Check the domain carefully before signing in or sharing information.',
    );
  }
}
