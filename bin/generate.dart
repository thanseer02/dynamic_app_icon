// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  print('\x1B[35m' + '=' * 60 + '\x1B[0m');
  print('🤖 \x1B[1m\x1B[36mDYNAMIC APP ICON GENERATOR\x1B[0m');
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

  // Validate images first
  final validNames = <String>[];
  final validImages = <String, img.Image>{};

  for (final file in files) {
    final name = p.basenameWithoutExtension(file.path);
    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes);

    if (image == null) {
      print('⚠️  \x1B[33mWarning: Failed to decode image: ${p.basename(file.path)}. Skipping.\x1B[0m');
      continue;
    }

    if (image.width != image.height) {
      print('❌ \x1B[31mError: Alternate icon must be square (found ${image.width}x${image.height} in ${p.basename(file.path)})\x1B[0m');
      exit(1);
    }

    validNames.add(name);
    validImages[name] = image;
    print('✅ Validated $name (${image.width}x${image.height})');
  }

  if (validNames.isEmpty) {
    print('❌ \x1B[31mNo valid PNG images to process.\x1B[0m');
    exit(1);
  }

  // 1. Generate Android Mipmaps
  print('\n🤖 \x1B[1m\x1B[34m[Android] Generating Mipmaps...\x1B[0m');
  final androidResDir = Directory(p.join(currentDir, 'android', 'app', 'src', 'main', 'res'));
  if (!androidResDir.existsSync()) {
    print('⚠️  Android res directory not found at "${androidResDir.path}". Skipping Android mipmap generation.');
  } else {
    final androidDensities = {
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };

    for (final entry in validImages.entries) {
      final name = entry.key;
      final image = entry.value;

      for (final density in androidDensities.entries) {
        final densityFolder = Directory(p.join(androidResDir.path, density.key));
        if (!densityFolder.existsSync()) {
          densityFolder.createSync(recursive: true);
        }

        final size = density.value;
        final resized = img.copyResize(image, width: size, height: size);
        
        final outPath = p.join(densityFolder.path, 'ic_launcher_$name.png');
        File(outPath).writeAsBytesSync(img.encodePng(resized));

        final outRoundPath = p.join(densityFolder.path, 'ic_launcher_${name}_round.png');
        File(outRoundPath).writeAsBytesSync(img.encodePng(resized));
      }
      print('  🎉 Generated mipmaps for: $name (Android)');
    }
  }

  // 2. Update AndroidManifest.xml
  print('\n🤖 \x1B[1m\x1B[34m[Android] Updating AndroidManifest.xml...\x1B[0m');
  final manifestFile = File(p.join(currentDir, 'android', 'app', 'src', 'main', 'AndroidManifest.xml'));
  if (!manifestFile.existsSync()) {
    print('⚠️  AndroidManifest.xml not found. Skipping alias injection.');
  } else {
    var manifestContent = manifestFile.readAsStringSync();

    // Determine target main activity name (e.g. '.MainActivity')
    final activityRegex = RegExp(r'<activity[^>]*android:name="([^"]+)"');
    final match = activityRegex.firstMatch(manifestContent);
    final mainActivityName = match?.group(1) ?? '.MainActivity';

    // Remove any previous dynamic injections
    final injectRegex = RegExp(r'<!--\s*dynamic_app_icon:inject:start\s*-->.*?<!--\s*dynamic_app_icon:inject:end\s*-->', dotAll: true);
    manifestContent = manifestContent.replaceAll(injectRegex, '');

    // Generate alternate activity-alias entries
    final buffer = StringBuffer();
    buffer.writeln('        <!-- dynamic_app_icon:inject:start -->');
    for (final name in validNames) {
      if (name == 'default') continue; // default is handled by primary activity/alias
      buffer.writeln('        <activity-alias');
      buffer.writeln('            android:name="$mainActivityName$name"');
      buffer.writeln('            android:enabled="false"');
      buffer.writeln('            android:exported="true"');
      buffer.writeln('            android:icon="@mipmap/ic_launcher_$name"');
      buffer.writeln('            android:targetActivity="$mainActivityName">');
      buffer.writeln('            <intent-filter>');
      buffer.writeln('                <action android:name="android.intent.action.MAIN"/>');
      buffer.writeln('                <category android:name="android.intent.category.LAUNCHER"/>');
      buffer.writeln('            </intent-filter>');
      buffer.writeln('        </activity-alias>');
    }
    buffer.write('        <!-- dynamic_app_icon:inject:end -->');

    // In most Flutter apps, we inject right before </application>
    final closingAppIndex = manifestContent.indexOf('</application>');
    if (closingAppIndex == -1) {
      print('❌ FAILED: Closing </application> tag not found in AndroidManifest.xml');
    } else {
      manifestContent = manifestContent.replaceRange(closingAppIndex, closingAppIndex, '${buffer.toString()}\n    ');
      manifestFile.writeAsStringSync(manifestContent);
      print('  🎉 Success: AndroidManifest.xml aliases updated successfully!');
    }
  }

  // 3. Generate iOS alternate icons in Runner
  print('\n🍏 \x1B[1m\x1B[32m[iOS] Generating Alternate Icons...\x1B[0m');
  final iosRunnerDir = Directory(p.join(currentDir, 'ios', 'Runner'));
  if (!iosRunnerDir.existsSync()) {
    print('⚠️  iOS Runner directory not found. Skipping.');
  } else {
    // Write alternate icons into Runner folder so they are included in Bundle
    for (final entry in validImages.entries) {
      final name = entry.key;
      final image = entry.value;

      if (name == 'default') continue; 

      // Render sizes: iPhone (@2x = 120, @3x = 180), iPad (@2x = 152, iPad pro = 167)
      final sizes = {
        '-2x.png': 120,
        '-3x.png': 180,
        '-ipad.png': 76,
        '-ipad-2x.png': 152,
        '-ipad-pro.png': 167,
      };

      for (final sizeEntry in sizes.entries) {
        final densityName = sizeEntry.key;
        final dimension = sizeEntry.value;

        final resized = img.copyResize(image, width: dimension, height: dimension);
        final outPath = p.join(iosRunnerDir.path, '$name$densityName');
        File(outPath).writeAsBytesSync(img.encodePng(resized));
      }
      print('  🎉 Generated iOS PNG files for alternate: $name');
    }
  }

  // 4. Update Info.plist
  print('\n🍏 \x1B[1m\x1B[32m[iOS] Updating Info.plist...\x1B[0m');
  final plistFile = File(p.join(currentDir, 'ios', 'Runner', 'Info.plist'));
  if (!plistFile.existsSync()) {
    print('⚠️  Info.plist not found. Skipping plist entry injections.');
  } else {
    var plistContent = plistFile.readAsStringSync();

    // Remove any previous dynamic injections
    final injectRegex = RegExp(r'<!--\s*dynamic_app_icon:inject:start\s*-->.*?<!--\s*dynamic_app_icon:inject:end\s*-->', dotAll: true);
    plistContent = plistContent.replaceAll(injectRegex, '');

    final alternateNames = validNames.where((n) => n != 'default').toList();

    final buffer = StringBuffer();
    buffer.writeln('	<!-- dynamic_app_icon:inject:start -->');
    buffer.writeln('	<key>CFBundleIcons</key>');
    buffer.writeln('	<dict>');
    buffer.writeln('		<key>CFBundleAlternateIcons</key>');
    buffer.writeln('		<dict>');
    for (final name in alternateNames) {
      buffer.writeln('			<key>$name</key>');
      buffer.writeln('			<dict>');
      buffer.writeln('				<key>CFBundleIconFiles</key>');
      buffer.writeln('				<array>');
      buffer.writeln('					<string>$name-2x</string>');
      buffer.writeln('					<string>$name-3x</string>');
      buffer.writeln('				</array>');
      buffer.writeln('				<key>UIPrerenderedIcon</key>');
      buffer.writeln('				<false/>');
      buffer.writeln('			</dict>');
    }
    buffer.writeln('		</dict>');
    buffer.writeln('	</dict>');
    buffer.writeln('	<key>CFBundleIcons~ipad</key>');
    buffer.writeln('	<dict>');
    buffer.writeln('		<key>CFBundleAlternateIcons</key>');
    buffer.writeln('		<dict>');
    for (final name in alternateNames) {
      buffer.writeln('			<key>$name</key>');
      buffer.writeln('			<dict>');
      buffer.writeln('				<key>CFBundleIconFiles</key>');
      buffer.writeln('				<array>');
      buffer.writeln('					<string>$name-ipad</string>');
      buffer.writeln('					<string>$name-ipad-2x</string>');
      buffer.writeln('					<string>$name-ipad-pro</string>');
      buffer.writeln('				</array>');
      buffer.writeln('				<key>UIPrerenderedIcon</key>');
      buffer.writeln('				<false/>');
      buffer.writeln('			</dict>');
    }
    buffer.writeln('		</dict>');
    buffer.writeln('	</dict>');
    buffer.write('	<!-- dynamic_app_icon:inject:end -->');

    // In iOS Info.plist, we can inject right before the closing </dict></plist> tag
    final match = RegExp(r'</dict>\s*</plist>').allMatches(plistContent);
    final closingPlistIndex = match.isNotEmpty ? match.last.start : -1;
    if (closingPlistIndex == -1) {
      print('❌ FAILED: Closing </dict></plist> tag not found in Info.plist');
    } else {
      plistContent = plistContent.replaceRange(closingPlistIndex, closingPlistIndex, '${buffer.toString()}\n');
      plistFile.writeAsStringSync(plistContent);
      print('  🎉 Success: Info.plist alternate icon entries updated successfully!');
    }
  }

  print('\n\x1B[32m🤖 Finished! All launcher icons and manifest properties updated successfully! 🚀\x1B[0m\n');
}
