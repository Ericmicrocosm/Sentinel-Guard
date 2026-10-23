
import 'package:flutter/material.dart';

void main() {
  runApp(const SentinelGuardApp());
}

class SentinelGuardApp extends StatelessWidget {
  const SentinelGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentinel Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const SentinelHomePage(),
    );
  }
}

class SentinelHomePage extends StatefulWidget {
  const SentinelHomePage({super.key});

  @override
  State<SentinelHomePage> createState() =>
      _SentinelHomePageState();
}

class _SentinelHomePageState extends State<SentinelHomePage> {
  final TextEditingController ownerController =
      TextEditingController();

  bool protectionEnabled = false;

  @override
  void dispose() {
    ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentinel Guard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Personalized Phone Protection',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: ownerController,
              decoration: const InputDecoration(
                labelText: 'Owner full name',
                hintText: 'Enter the phone owner’s name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable protection'),
              subtitle: Text(
                protectionEnabled
                    ? 'Protection switch is on'
                    : 'Protection switch is off',
              ),
              value: protectionEnabled,
              onChanged: (value) {
                setState(() {
                  protectionEnabled = value;
                });
              },
            ),
            const Spacer(),
            const Text(
              'Motion-learning and alarm functions '
              'will be added in the next steps.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
