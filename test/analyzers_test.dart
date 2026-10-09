import 'package:flutter_test/flutter_test.dart';
import 'package:secura_ai/src/models/scan_models.dart';
import 'package:secura_ai/src/services/message_analyzer.dart';
import 'package:secura_ai/src/services/url_analyzer.dart';

void main() {
  group('MessageAnalyzer', () {
    test('flags an urgent OTP and payment request', () {
      final result = MessageAnalyzer().analyze(
        'URGENT: share your OTP and pay now to avoid account suspension.',
      );

      expect(result.score, greaterThan(0));
      expect(result.reasons, contains('OTP scam'));
      expect(result.reasons, contains('Urgency'));
      expect(result.reasons, contains('Payment request'));
      expect(result.level, isNot(RiskLevel.low));
    });

    test('does not invent indicators for a neutral message', () {
      final result = MessageAnalyzer().analyze('Are we still meeting at 5?');

      expect(result.score, 0);
      expect(result.reasons, isEmpty);
      expect(result.level, RiskLevel.low);
    });
  });

  group('UrlAnalyzer', () {
    test('flags a non-HTTPS IP-based URL with a suspicious keyword', () {
      final result = UrlAnalyzer().analyze('http://192.168.1.10/login');

      expect(result.reasons, contains('No HTTPS encryption'));
      expect(result.reasons, contains('IP-based URL'));
      expect(result.reasons, contains('Suspicious keywords'));
      expect(result.score, greaterThan(50));
    });

    test(
      'treats a normal HTTPS URL as low risk while explaining HTTPS limits',
      () {
        final result = UrlAnalyzer().analyze('https://example.com');

        expect(result.score, 0);
        expect(result.level, RiskLevel.good);
        expect(result.explanation, contains('does not prove'));
      },
    );
  });
}
