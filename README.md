# AI Security

**AI Security for Digital Scams** is an Android-first Flutter app for local, privacy-conscious scam checks.

## Features

- Home dashboard with a weighted AI Safety Score (Messages 33%, URLs 33%, Apps 34%)
- Local rule-based message scanner for phishing, fake KYC, OTP, banking, rewards, jobs, investments, urgency, payment requests, and links
- URL checker for HTTPS, IP hosts, shorteners, punycode, ports, subdomains, keywords, and URL structure
- Android app inventory through a platform channel, showing package metadata and sensitive permissions
- Four Material 3 bottom-navigation tabs: Home, Messages, URLs, and Apps
- Light/dark themes and local scan summaries without storing full message text

## Architecture

- `lib/src/screens`: Material 3 UI and navigation
- `lib/src/services`: local analyzers, persistence, and Android inventory bridge
- `lib/src/models`: scan result and app metadata models
- `android/app/src/main/kotlin`: Android `PackageManager` integration

Run with:

```sh
flutter pub get
flutter run
```

The message and URL analyzers are intentionally local and replaceable; an AI provider can be added behind the same service boundaries without exposing API keys in the app.
