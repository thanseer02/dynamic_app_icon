import 'package:flutter/material.dart';
import 'package:dynamic_app_icon/dynamic_app_icon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSupported = false;
  String _currentIcon = 'default';

  @override
  void initState() {
    super.initState();
    _checkPluginState();
  }

  Future<void> _checkPluginState() async {
    final isSupported = await DynamicAppIcon.isSupported();
    String currentIcon = 'default';
    if (isSupported) {
      final activeIcon = await DynamicAppIcon.getCurrentIcon();
      currentIcon = activeIcon ?? 'default';
    }

    if (!mounted) return;

    setState(() {
      _isSupported = isSupported;
      _currentIcon = currentIcon;
    });
  }

  Future<void> _changeIcon(String? iconName) async {
    try {
      await DynamicAppIcon.setIcon(iconName);
      final activeIcon = await DynamicAppIcon.getCurrentIcon();
      setState(() {
        _currentIcon = activeIcon ?? 'default';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully set icon to: $_currentIcon')),
        );
      }
    } on DynamicAppIconException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing icon: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic App Icon Example'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Supported on this device: $_isSupported',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Current Active Icon: $_currentIcon',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSupported ? () => _changeIcon(null) : null,
                  child: const Text('Set Default Icon'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isSupported ? () => _changeIcon('dark_icon') : null,
                  child: const Text('Set Dark Icon'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
