import '../models/scan_models.dart';

class MessageAnalyzer {
  ScanResult analyze(String input) {
    final text = input.toLowerCase();
    final checks = <String, List<String>>{
      'Phishing': ['verify your account', 'click here', 'login immediately'],
      'Fake KYC': ['kyc', 'pan card', 'update kyc'],
      'OTP scam': ['otp', 'one time password', 'share the code'],
      'Banking scam': ['bank account', 'debit card', 'netbanking'],
      'Fake reward': ['won', 'cash prize', 'reward', 'lottery'],
      'Job scam': ['work from home', 'job offer', 'registration fee'],
      'Investment scam': ['guaranteed returns', 'double your money', 'crypto'],
      'Urgency': ['urgent', 'immediately', 'within 24 hours', 'suspended'],
      'Payment request': ['send money', 'pay now', 'upi', 'gift card'],
      'Suspicious link': ['http://', 'bit.ly', 'tinyurl', '.xyz', '://'],
    };
    final reasons = <String>[];
    var points = 0;
    for (final entry in checks.entries) {
      if (entry.value.any(text.contains)) {
        reasons.add(entry.key);
        points += entry.key == 'Urgency' ? 8 : 11;
      }
    }
    final score = points.clamp(0, 100);
    final level = score >= 76
        ? RiskLevel.critical
        : score >= 51
            ? RiskLevel.high
            : score >= 26
                ? RiskLevel.needsAttention
                : RiskLevel.low;
    return ScanResult(
      score: score,
      level: level,
      title: reasons.isEmpty ? 'No clear scam pattern' : reasons.first,
      reasons: reasons,
      explanation: reasons.isEmpty
          ? 'No strong indicators were found by the local rules. Stay cautious with unexpected requests.'
          : 'This message combines signals commonly seen in scam campaigns. Verify through an official channel.',
      recommendation: reasons.isEmpty
          ? 'Avoid sharing personal details and do not open unexpected links.'
          : 'Do not reply, pay, or share OTPs. Contact the organization using a trusted number.',
    );
  }
}
