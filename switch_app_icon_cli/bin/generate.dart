// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:icon_generator/icon_generator.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  print('\x1B[35m' + '=' * 60 + '\x1B[0m');
  print('🤖 \x1B[1m\x1B[36mDYNAMIC APP ICON GENERATOR (CLI)\x1B[0m');
  print('\x1B[35m' + '=' * 60 + '\x1B[0m');

  final currentDir = Directory.current.path;
  print('📁 Current directory: $currentDir');

  final configPath = p.join(currentDir, 'assets', 'app_icons');
  final appIconsDir = Directory(configPath);

  if (!appIconsDir.existsSync()) {
    print('❌ \x1B[31mError: Directory "$configPath" not found.\x1B[0m');
    print('💡 Please put your alternate app icons (.png) inside:');
    print('   assets/app_icons/default.png  (representing primary default icon)');
    print('   assets/app_icons/dark_icon.png (representing an alternate icon)');
    print('\x1B[35m' + '=' * 60 + '\x1B[0m');
    exit(1);
  }

  final files = appIconsDir
      .listSync()
      .whereType<File>()
      .where((f) => p.extension(f.path).toLowerCase() == '.png')
      .toList();

  if (files.isEmpty) {
    print('❌ \x1B[31mError: No alternate icon PNGs found in "${appIconsDir.path}"\x1B[0m');
    exit(1);
  }

  print('🔍 Found ${files.length} icon candidate(s) to process.');

  // Run AppIconValidator
  AppIconValidator.run(files, currentDir);

  // Run icon resizing engine
  final engine = IconResizingEngine(currentDir: currentDir);
  engine.generate(files);

  print('\n\x1B[32m🤖 Finished! All launcher icons and manifest properties updated successfully! 🚀\x1B[0m\n');
}
