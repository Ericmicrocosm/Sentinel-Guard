
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SentinelHomePage(),
    );
  }
}

class SentinelHomePage extends StatefulWidget {
  const SentinelHomePage({super.key});

  @override
  State<SentinelHomePage> createState() => _SentinelHomePageState();
}

class _SentinelHomePageState extends State<SentinelHomePage> {
  bool _protectionEnabled = false;
  bool _sensorAvailable = false;
  String _motionStatus = 'Waiting for sensor data';
  String _ownerName = '';
  String _pin = '';
  double _motionLevel = 0;

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _sensorAvailable = true;
          _motionLevel = (event.x * event.x +
                  event.y * event.y +
                  event.z * event.z)
              .sqrt();
          _motionStatus = 'Motion sensor connected';
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _motionStatus = 'Motion sensor unavailable');
      },
    );
  }

  Future<void> _configureOwner() async {
    final nameController = TextEditingController(text: _ownerName);
    final pinController = TextEditingController(text: _pin);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Owner settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Six-digit PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  !RegExp(r'^\d{6}$').hasMatch(pinController.text)) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Enter your name and a six-digit PIN.'),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, {
                'name': nameController.text.trim(),
                'pin': pinController.text,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    pinController.dispose();

    if (result != null && mounted) {
      setState(() {
        _ownerName = result['name']!;
        _pin = result['pin']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentinel Guard'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 82,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your personal anti-theft assistant',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Owner: ${_ownerName.isEmpty ? "Not configured" : _ownerName}'),
                    const SizedBox(height: 8),
                    Text(_motionStatus),
                    const SizedBox(height: 8),
                    Text(
                      'Acceleration magnitude: ${_motionLevel.toStringAsFixed(2)} m/s²',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _sensorAvailable
                          ? 'Accelerometer data received'
                          : 'Waiting for accelerometer',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _configureOwner,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Configure owner and PIN'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _ownerName.isEmpty || _pin.length != 6
                  ? null
                  : () => setState(
                        () => _protectionEnabled = !_protectionEnabled,
                      ),
              icon: Icon(
                _protectionEnabled
                    ? Icons.shield
                    : Icons.shield_outlined,
              ),
              label: Text(
                _protectionEnabled
                    ? 'Disable protection'
                    : 'Enable protection',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _protectionEnabled
                  ? 'Protection is enabled. Motion learning and alarm response are not implemented yet.'
                  : 'Configure your owner details to prepare the prototype.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

extension on double {
  double sqrt() => this <= 0 ? 0 : _sqrtValue(this);
}

double _sqrtValue(double value) {
  // Newton's method avoids an additional math import.
  var estimate = value;
  for (var i = 0; i < 12; i++) {
    estimate = (estimate + value / estimate) / 2;
  }
  return estimate;
}
