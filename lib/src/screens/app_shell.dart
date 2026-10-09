import 'package:flutter/material.dart';
import '../models/scan_models.dart';
import '../services/app_inventory_service.dart';
import '../services/message_analyzer.dart';
import '../services/scan_storage.dart';
import '../services/url_analyzer.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.storage,
    required this.inventoryService,
    required this.onToggleTheme,
    super.key,
  });
  final ScanStorage storage;
  final AppInventoryService inventoryService;
  final VoidCallback onToggleTheme;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final List<Widget> _pages = [
    HomePage(storage: widget.storage, onNavigate: (index) => setState(() => _index = index)),
    MessagePage(storage: widget.storage),
    UrlPage(storage: widget.storage),
    AppsPage(storage: widget.storage, inventoryService: widget.inventoryService),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Security', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('AI Security for Digital Scams', style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.sms_outlined), selectedIcon: Icon(Icons.sms), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.link_outlined), selectedIcon: Icon(Icons.link), label: 'URLs'),
          NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: 'Apps'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({required this.storage, required this.onNavigate, super.key});
  final ScanStorage storage;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final latest = <ScanKind, ScanSummary>{};
    for (final item in storage.summaries) {
      latest.putIfAbsent(item.kind, () => item);
    }
    final scores = [latest[ScanKind.message]?.score, latest[ScanKind.url]?.score, latest[ScanKind.apps]?.score];
    final complete = scores.every((score) => score != null);
    final overall = complete
        ? ((scores[0]! * .33) + (scores[1]! * .33) + (scores[2]! * .34)).round()
        : null;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Your Safety Score', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        _ScoreCard(score: overall),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _MetricCard(label: 'Messages', icon: Icons.sms_outlined, score: scores[0])),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(label: 'URLs', icon: Icons.link, score: scores[1])),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(label: 'Apps', icon: Icons.apps, score: scores[2])),
          ],
        ),
        const SizedBox(height: 24),
        Text('Quick Checks', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _ActionButton(icon: Icons.sms_outlined, label: 'Scan Message', onTap: () => onNavigate(1)),
        const SizedBox(height: 8),
        _ActionButton(icon: Icons.link, label: 'Check URL', onTap: () => onNavigate(2)),
        const SizedBox(height: 8),
        _ActionButton(icon: Icons.apps, label: 'Scan Apps', onTap: () => onNavigate(3)),
        const SizedBox(height: 24),
        Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (storage.summaries.isEmpty)
          const _EmptyState(icon: Icons.history, title: 'No scans yet', body: 'Your private scan summaries will appear here.')
        else
          ...storage.summaries.take(5).map((item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(_iconFor(item.kind), size: 18)),
                title: Text(item.title),
                subtitle: Text('${item.kind.name.toUpperCase()}  •  ${_timeAgo(item.createdAt)}'),
                trailing: Text('${item.score}/100', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
      ],
    );
  }
}

class MessagePage extends StatefulWidget {
  const MessagePage({required this.storage, super.key});
  final ScanStorage storage;
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _controller = TextEditingController();
  ScanResult? _result;
  bool _loading = false;
  Future<void> _scan() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final result = MessageAnalyzer().analyze(_controller.text);
    await widget.storage.add(ScanSummary(kind: ScanKind.message, score: 100 - result.score, createdAt: DateTime.now(), title: result.title));
    if (mounted) setState(() { _result = result; _loading = false; });
  }
  @override
  Widget build(BuildContext context) => _AnalyzerPage(
        title: 'Message Scanner',
        subtitle: 'Paste a suspicious message. AI Security never reads SMS or WhatsApp automatically.',
        controller: _controller,
        hint: 'Paste SMS, email, or chat text here...',
        buttonLabel: 'Analyze Message',
        loading: _loading,
        result: _result,
        onScan: _scan,
      );
}

class UrlPage extends StatefulWidget {
  const UrlPage({required this.storage, super.key});
  final ScanStorage storage;
  @override
  State<UrlPage> createState() => _UrlPageState();
}

class _UrlPageState extends State<UrlPage> {
  final _controller = TextEditingController();
  ScanResult? _result;
  bool _loading = false;
  Future<void> _scan() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final result = UrlAnalyzer().analyze(_controller.text);
    await widget.storage.add(ScanSummary(kind: ScanKind.url, score: 100 - result.score, createdAt: DateTime.now(), title: result.title));
    if (mounted) setState(() { _result = result; _loading = false; });
  }
  @override
  Widget build(BuildContext context) => _AnalyzerPage(
        title: 'URL Checker',
        subtitle: 'Review link signals locally. HTTPS alone does not mean a website is safe.',
        controller: _controller,
        hint: 'https://example.com',
        buttonLabel: 'Check URL',
        loading: _loading,
        result: _result,
        onScan: _scan,
      );
}

class AppsPage extends StatefulWidget {
  const AppsPage({required this.storage, required this.inventoryService, super.key});
  final ScanStorage storage;
  final AppInventoryService inventoryService;
  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  late Future<List<InstalledAppInfo>> _apps;
  @override
  void initState() { super.initState(); _apps = widget.inventoryService.loadApps(); }
  Future<void> _reload() async {
    final future = widget.inventoryService.loadApps();
    setState(() => _apps = future);
    final apps = await future;
    if (apps.isNotEmpty) {
      final score = (apps.map((app) => app.score).reduce((a, b) => a + b) / apps.length).round();
      await widget.storage.add(ScanSummary(kind: ScanKind.apps, score: score, createdAt: DateTime.now(), title: 'Android app review'));
    }
  }
  @override
  Widget build(BuildContext context) => FutureBuilder<List<InstalledAppInfo>>(
        future: _apps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return _EmptyState(icon: Icons.error_outline, title: 'Could not load apps', body: 'Try again to query Android app information.', action: _reload);
          final apps = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('App Security', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Review permissions and security signals. A sensitive permission is not proof that an app is malware.'),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(onPressed: _reload, icon: const Icon(Icons.refresh), label: const Text('Scan installed apps')),
                const SizedBox(height: 16),
                if (apps.isEmpty) const _EmptyState(icon: Icons.android, title: 'No app data available', body: 'App inventory is available on Android devices with package visibility enabled.', action: null),
                ...apps.map((app) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ExpansionTile(
                        leading: CircleAvatar(child: Icon(app.isSystemApp ? Icons.settings : Icons.apps)),
                        title: Text(app.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${app.status}  •  ${app.score}/100'),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Align(alignment: Alignment.centerLeft, child: Text(app.packageName, style: Theme.of(context).textTheme.bodySmall)),
                          Align(alignment: Alignment.centerLeft, child: Text('Version ${app.version}')),
                          const SizedBox(height: 8),
                          Align(alignment: Alignment.centerLeft, child: Text(app.permissions.isEmpty ? 'No sensitive permissions reported.' : 'Sensitive permissions: ${app.permissions.join(', ')}')),
                        ],
                      ),
                    )),
              ],
            ),
          );
        },
      );
}

class _AnalyzerPage extends StatelessWidget {
  const _AnalyzerPage({required this.title, required this.subtitle, required this.controller, required this.hint, required this.buttonLabel, required this.loading, required this.result, required this.onScan});
  final String title, subtitle, hint, buttonLabel;
  final TextEditingController controller;
  final bool loading;
  final ScanResult? result;
  final VoidCallback onScan;
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 20),
          TextField(controller: controller, minLines: 5, maxLines: 8, decoration: InputDecoration(hintText: hint, alignLabelWithHint: true)),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: loading ? null : onScan, icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.shield_outlined), label: Text(loading ? 'Analyzing...' : buttonLabel)),
          if (result != null) ...[
            const SizedBox(height: 20),
            _ResultCard(result: result!),
          ],
        ],
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final ScanResult result;
  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(result.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), Text('${result.score}/100', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))]),
            const SizedBox(height: 6),
            Chip(label: Text(result.level.label)),
            const SizedBox(height: 12),
            Text(result.explanation),
            if (result.reasons.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('Indicators', style: TextStyle(fontWeight: FontWeight.bold)),
              ...result.reasons.map((reason) => ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.warning_amber_rounded, size: 18), title: Text(reason))),
            ],
            const Divider(),
            Text('Recommended action', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(result.recommendation),
          ]),
        ),
      );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});
  final int? score;
  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(children: [
            Text(score == null ? '--' : '$score', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900)),
            Text(score == null ? '/ 100' : '/ 100  •  ${_scoreLabel(score!)}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(score == null ? 'Complete a scan to build your score' : 'Based on your latest message, URL, and app checks'),
          ]),
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.icon, required this.score});
  final String label; final IconData icon; final int? score;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(score == null ? '--' : '$score', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))])));
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  final IconData icon; final String label; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(onPressed: onTap, icon: Icon(icon), label: Align(alignment: Alignment.centerLeft, child: Text(label)));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.body, this.action});
  final IconData icon; final String title, body; final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [Icon(icon, size: 36), const SizedBox(height: 12), Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(body, textAlign: TextAlign.center), if (action != null) ...[const SizedBox(height: 12), OutlinedButton(onPressed: action, child: const Text('Try again'))]])));
}

IconData _iconFor(ScanKind kind) => switch (kind) { ScanKind.message => Icons.sms, ScanKind.url => Icons.link, ScanKind.apps => Icons.apps };
String _scoreLabel(int score) => score >= 85 ? 'EXCELLENT' : score >= 70 ? 'GOOD' : score >= 50 ? 'NEEDS ATTENTION' : score >= 25 ? 'HIGH RISK' : 'CRITICAL';
String _timeAgo(DateTime time) { final minutes = DateTime.now().difference(time).inMinutes; return minutes < 1 ? 'Just now' : minutes < 60 ? '${minutes}m ago' : '${minutes ~/ 60}h ago'; }
