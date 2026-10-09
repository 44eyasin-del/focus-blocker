
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const FocusBlockerApp());
}

class FocusBlockerApp extends StatelessWidget {
  const FocusBlockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Blocker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const FocusHomePage(),
    );
  }
}

class FocusHomePage extends StatefulWidget {
  const FocusHomePage({super.key});

  @override
  State<FocusHomePage> createState() => _FocusHomePageState();
}

class _FocusHomePageState extends State<FocusHomePage> {
  static const platform = MethodChannel('focus_blocker');

  static const allowedApps = [
    'Phone Calls',
    'WhatsApp',
    'imo',
    'Messenger',
  ];

  int remaining = 0;
  bool running = false;
  String status = 'প্রস্তুত';

  String get timeText {
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  Future<void> startFocus(int minutes) async {
    try {
      await platform.invokeMethod(
        'startBlocking',
        {'minutes': minutes},
      );

      if (!mounted) return;
      setState(() {
        remaining = minutes * 60;
        running = true;
        status = 'ফোকাস সেশন চালু';
      });
    } on PlatformException catch (e) {
      setState(() {
        status = 'Android সার্ভিস তৈরি করা বাকি';
      });
      debugPrint(e.message);
    } on MissingPluginException {
      setState(() {
        status = 'Android সার্ভিস এখনো যোগ করা হয়নি';
      });
    }
  }

  Future<void> stopFocus() async {
    try {
      await platform.invokeMethod('stopBlocking');
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      remaining = 0;
      running = false;
      status = 'ফোকাস সেশন বন্ধ';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Blocker')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.shield_moon, size: 70),
          const SizedBox(height: 16),
          const Text(
            'ফোকাস টাইমার',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            timeText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(status, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          for (final minutes in [15, 30, 60, 120])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FilledButton(
                onPressed: running
                    ? null
                    : () => startFocus(minutes),
                child: Text('$minutes মিনিট চালু করো'),
              ),
            ),
          OutlinedButton(
            onPressed: running ? stopFocus : null,
            child: const Text('ফোকাস বন্ধ করো'),
          ),
          const Divider(height: 32),
          const Text(
            'অনুমোদিত অ্যাপ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (final app in allowedApps)
            ListTile(
              leading: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              title: Text(app),
            ),
          const SizedBox(height: 12),
          const Text(
            'নোট: অন্য অ্যাপ ব্লক করার জন্য '
            'Android সার্ভিস ও অনুমতি যোগ করতে হবে।',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
