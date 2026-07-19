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
  List<String> _availableIcons = [];

  @override
  void initState() {
    super.initState();
    _checkPluginState();
  }

  Future<void> _checkPluginState() async {
    final isSupported = await DynamicAppIcon.isSupported();
    String currentIcon = 'default';
    List<String> availableIcons = [];
    if (isSupported) {
      final activeIcon = await DynamicAppIcon.current();
      currentIcon = activeIcon ?? 'default';
      availableIcons = await DynamicAppIcon.availableIcons();
    }

    if (!mounted) return;

    setState(() {
      _isSupported = isSupported;
      _currentIcon = currentIcon;
      _availableIcons = availableIcons;
    });
  }

  Future<void> _changeIcon(String iconName) async {
    try {
      await DynamicAppIcon.change(iconName);
      final activeIcon = await DynamicAppIcon.current();
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

  Future<void> _resetIcon() async {
    try {
      await DynamicAppIcon.reset();
      final activeIcon = await DynamicAppIcon.current();
      setState(() {
        _currentIcon = activeIcon ?? 'default';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully reset launcher icon')),
        );
      }
    } on DynamicAppIconException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting icon: ${e.message}')),
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
                const SizedBox(height: 10),
                Text(
                  'Available Alternate Icons: ${_availableIcons.join(", ")}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: _isSupported ? _resetIcon : null,
                  child: const Text('Reset Default Icon'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isSupported ? () => _changeIcon('dark_icon') : null,
                  child: const Text('Set Dark Icon'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isSupported ? () => _changeIcon('festive_icon') : null,
                  child: const Text('Set Festive Icon'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
