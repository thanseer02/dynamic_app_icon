import 'package:flutter/material.dart';
import 'package:dynamic_app_icon/dynamic_app_icon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic App Icon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          primary: Colors.tealAccent,
          secondary: Colors.deepPurpleAccent,
          background: const Color(0xFF0F172A), // Slate 900
          surface: const Color(0xFF1E293B), // Slate 800
        ),
      ),
      home: const IconStudioScreen(),
    );
  }
}

class IconStudioScreen extends StatefulWidget {
  const IconStudioScreen({super.key});

  @override
  State<IconStudioScreen> createState() => _IconStudioScreenState();
}

class _IconStudioScreenState extends State<IconStudioScreen>
    with SingleTickerProviderStateMixin {
  bool _isSupported = false;
  String _currentIcon = 'default';
  String _selectedIcon = 'default';
  List<String> _availableIcons = [];
  bool _isLoading = false;

  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.decelerate,
    ));

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
      List<String> availableIcons = [];
      if (isSupported) {
        final activeIcon = await DynamicAppIcon.current();
        currentIcon = activeIcon ?? 'default';
        availableIcons = await DynamicAppIcon.availableIcons();
      }
      if (mounted) {
        setState(() {
          _isSupported = isSupported;
          _currentIcon = currentIcon;
          _selectedIcon = currentIcon;
          _availableIcons = availableIcons;
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
    setState(() => _isLoading = true);
    try {
      await DynamicAppIcon.change(iconName);
      final activeIcon = await DynamicAppIcon.current();
      setState(() {
        _currentIcon = activeIcon ?? 'default';
        _selectedIcon = _currentIcon;
      });
      _animController.forward(from: 0.0);
      _showFeedback('App launcher icon changed to: $_currentIcon');
    } on DynamicAppIconException catch (e) {
      _showFeedback('Failed: ${e.message}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetIcon() async {
    setState(() => _isLoading = true);
    try {
      await DynamicAppIcon.reset();
      final activeIcon = await DynamicAppIcon.current();
      setState(() {
        _currentIcon = activeIcon ?? 'default';
        _selectedIcon = _currentIcon;
      });
      _animController.forward(from: 0.0);
      _showFeedback('App launcher icon reset to default');
    } on DynamicAppIconException catch (e) {
      _showFeedback('Failed: ${e.message}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.teal[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getReadableName(String raw) {
    switch (raw) {
      case 'default':
        return 'Standard Red';
      case 'dark_icon':
        return 'Obsidian Dark';
      case 'festive_icon':
        return 'Festive Gold';
      default:
        return raw.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  Widget _buildLauncherMock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 250,
          height: 440,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFF334155), width: 8), // Slate 700
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                blurRadius: 36,
                spreadRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Phone wallpaper
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF311042)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Home widget clock
                Positioned(
                  top: 36,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        TimeOfDay.now().format(context),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'Monday, July 20',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                // Centered App Icon Mock and Name
                Center(
                  child: KeyedSubtree(
                    key: ValueKey(_selectedIcon),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/app_icons/$_selectedIcon.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.apps, size: 48, color: Colors.tealAccent),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Launcher',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1.5))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Dock at bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.phone, color: Colors.white70, size: 20),
                        Icon(Icons.message, color: Colors.white70, size: 20),
                        Icon(Icons.chrome_reader_mode, color: Colors.white70, size: 20),
                        Icon(Icons.camera_alt, color: Colors.white70, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _selectedIcon == _currentIcon ? Colors.tealAccent : Colors.white30,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedIcon == _currentIcon ? 'ACTIVE ICON' : 'PREVIEW ONLY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: _selectedIcon == _currentIcon ? Colors.tealAccent : Colors.white30,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isDesktop = media.size.width > 700;
    final displayIcons = ['default', ..._availableIcons.where((name) => name != 'default')];

    Widget buildLayout() {
      if (isDesktop) {
        // Desktop landscape side-by-side
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _buildLauncherMock(),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFF334155)),
            Expanded(
              flex: 6,
              child: _buildConfigPanel(displayIcons),
            ),
          ],
        );
      } else {
        // Mobile portrait vertical
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                _buildLauncherMock(),
                const SizedBox(height: 32),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 16),
                _buildConfigPanelMobile(displayIcons),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Studio Icon Changer',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.tealAccent),
            tooltip: 'Sync Plugin State',
            onPressed: _isLoading ? null : _checkPluginState,
          )
        ],
      ),
      body: Stack(
        children: [
          buildLayout(),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel(List<String> displayIcons) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeviceInfo(),
          const SizedBox(height: 28),
          const Text(
            'SELECT A DESIGN',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white60),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildGrid(displayIcons),
          ),
          const SizedBox(height: 16),
          _buildActionPanel(),
        ],
      ),
    );
  }

  Widget _buildConfigPanelMobile(List<String> displayIcons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDeviceInfo(),
        const SizedBox(height: 24),
        const Text(
          'SELECT A DESIGN',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white60),
        ),
        const SizedBox(height: 16),
        _buildGridMobile(displayIcons),
        const SizedBox(height: 24),
        _buildActionPanel(),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Icon(
            _isSupported ? Icons.check_circle : Icons.error,
            color: _isSupported ? Colors.tealAccent : Colors.redAccent,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSupported ? 'Dynamic Alternate Icons Supported' : 'Changer Unsupported on Device',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  _isSupported
                      ? 'Select an alternate theme to customize your phone launcher layout icon.'
                      : 'Alternate icons require Android 8+ or iOS 10.3+.',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<String> displayIcons) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: displayIcons.length,
      itemBuilder: (context, index) {
        final item = displayIcons[index];
        return _buildIconTile(item);
      },
    );
  }

  Widget _buildGridMobile(List<String> displayIcons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: displayIcons.length,
      itemBuilder: (context, index) {
        final item = displayIcons[index];
        return _buildIconTile(item);
      },
    );
  }

  Widget _buildIconTile(String item) {
    final isSelected = _selectedIcon == item;
    final isActive = _currentIcon == item;

    return InkWell(
      onTap: () {
        setState(() => _selectedIcon = item);
        _animController.forward(from: 0.0);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent.withOpacity(0.05) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.tealAccent
                : isActive
                    ? Colors.tealAccent.withOpacity(0.4)
                    : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/app_icons/$item.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.add_to_home_screen, size: 28, color: Colors.white30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getReadableName(item),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.tealAccent : Colors.white,
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 2),
                const Text(
                  'CURRENT',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionPanel() {
    final canApply = _selectedIcon != _currentIcon;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF334155)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.settings_backup_restore, size: 16),
              label: const Text('Reset Default', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: _isSupported && _currentIcon != 'default' ? _resetIcon : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.swap_horizontal_circle, size: 16),
              label: const Text('Change Icon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: _isSupported && canApply ? () => _changeIcon(_selectedIcon) : null,
            ),
          ),
        ],
      ),
    );
  }
}
