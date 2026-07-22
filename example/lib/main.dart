import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dynamic_app_icon/dynamic_app_icon.dart';

void main() {
  runApp(const DynamicAppIconDemo());
}

class DynamicAppIconDemo extends StatelessWidget {
  const DynamicAppIconDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic App Icon Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
          primary: Colors.deepPurple,
          secondary: Colors.pinkAccent,
          surface: const Color(0xFFF8FAFC), // Slate 50

        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          primary: Colors.deepPurpleAccent,
          secondary: Colors.pinkAccent,
          surface: const Color(0xFF0F172A), // Slate 900

        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const IconStudioScreen(),
    );
  }
}

class IconStudioScreen extends StatefulWidget {
  const IconStudioScreen({super.key});

  @override
  State<IconStudioScreen> createState() => _IconStudioScreenState();
}

class _IconStudioScreenState extends State<IconStudioScreen> with SingleTickerProviderStateMixin {
  bool _isSupported = false;
  String _currentIcon = 'default';
  String _selectedIcon = 'default';
  bool _isLoading = true;
  
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  // The 6 requested flat illustration icons
  final List<String> _availableIcons = [
    'default', // Corresponds to flutter.png or default app icon
    'cat',
    'dog',
    'fox',
    'panda',
    'rocket'
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.05).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_animController);

    _checkPluginState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkPluginState() async {
    setState(() => _isLoading = true);
    try {
      final isSupported = await DynamicAppIcon.isSupported();
      String currentIcon = 'default';
      
      if (isSupported) {
        final activeIcon = await DynamicAppIcon.current();
        currentIcon = activeIcon ?? 'default';
      }
      
      if (mounted) {
        setState(() {
          _isSupported = isSupported;
          _currentIcon = currentIcon;
          _selectedIcon = currentIcon;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeIcon(String iconName) async {
    if (iconName == _currentIcon) return;
    
    setState(() => _isLoading = true);
    try {
      if (iconName == 'default') {
        await DynamicAppIcon.reset();
      } else {
        await DynamicAppIcon.change(iconName);
      }
      
      final activeIcon = await DynamicAppIcon.current();
      setState(() {
        _currentIcon = activeIcon ?? 'default';
        _selectedIcon = _currentIcon;
      });
      _animController.forward(from: 0.0);
      _showFeedback('Successfully applied $_currentIcon icon!', isSuccess: true);
    } catch (e) {
      _showFeedback('Failed to change icon.', isSuccess: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyRandomIcon() {
    final available = _availableIcons.where((icon) => icon != _currentIcon).toList();
    if (available.isNotEmpty) {
      final randomIcon = available[Random().nextInt(available.length)];
      _changeIcon(randomIcon);
    }
  }

  void _showFeedback(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _getReadableName(String raw) {
    if (raw == 'default') return 'Flutter Original';
    return raw.substring(0, 1).toUpperCase() + raw.substring(1);
  }
  
  String _getAssetPath(String raw) {
    return 'assets/app_icons/$raw.png';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dynamic App Icon Demo'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: isDesktop 
          ? _buildDesktopLayout(colorScheme)
          : _buildMobileLayout(colorScheme),
      ),
    );
  }

  Widget _buildMobileLayout(ColorScheme colorScheme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildActiveIconPreview(colorScheme),
            const SizedBox(height: 32),
            _buildGridView(colorScheme),
            const SizedBox(height: 32),
            _buildControlPanel(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SingleChildScrollView(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActiveIconPreview(colorScheme),
                const SizedBox(height: 48),
                _buildControlPanel(colorScheme),
              ],
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: _buildGridView(colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveIconPreview(ColorScheme colorScheme) {
    return Column(
      children: [
        const Text(
          'CURRENT ACTIVE ICON',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                _getAssetPath(_currentIcon),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Icon(Icons.apps, size: 80, color: colorScheme.primary.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _getReadableName(_currentIcon),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _isSupported ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isSupported ? Icons.check_circle_outline : Icons.error_outline,
                size: 14,
                color: _isSupported ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _isSupported ? 'Supported on this device' : 'Unsupported on this device',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isSupported ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHOOSE AN ICON',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 140,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: _availableIcons.length,
          itemBuilder: (context, index) {
            final iconName = _availableIcons[index];
            final isSelected = _selectedIcon == iconName;
            final isActive = _currentIcon == iconName;
            
            return GestureDetector(
              onTap: () {
                setState(() => _selectedIcon = iconName);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? colorScheme.primary.withValues(alpha: 0.1) 
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected 
                        ? colorScheme.primary 
                        : (isActive ? colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              _getAssetPath(iconName),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getReadableName(iconName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 2),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 9, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildControlPanel(ColorScheme colorScheme) {
    final canApply = _selectedIcon != _currentIcon;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _isSupported && canApply ? () => _changeIcon(_selectedIcon) : null,
            icon: const Icon(Icons.rocket_launch),
            label: const Text(
              'Apply Selected Icon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: canApply ? 4 : 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isSupported && _currentIcon != 'default' ? () => _changeIcon('default') : null,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 50,
                child: FilledButton.tonalIcon(
                  onPressed: _isSupported ? _applyRandomIcon : null,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Random', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
