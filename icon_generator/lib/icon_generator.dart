// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class AppIconValidator {
  static void run(List<File> files, String currentDir) {
    print('🎨 \x1B[1m\x1B[33mVALIDATION ENGINE CHECK...\x1B[0m');
    final errors = <String>[];
    final warnings = <String>[];
    final autoFixes = <String>[];

    // 1. Duplicate check (case-insensitive)
    final nameSet = <String>{};
    for (final file in files) {
      final base = p.basenameWithoutExtension(file.path).toLowerCase();
      if (nameSet.contains(base)) {
        errors.add('Duplicate app icon name collision found for "$base".');
      }
      nameSet.add(base);
    }

    // 2. Missing default check
    final hasDefault = files.any((f) => p.basenameWithoutExtension(f.path).toLowerCase() == 'default');
    if (!hasDefault) {
      errors.add('Missing primary default icon "default.png" under assets/app_icons/.');
    }

    for (final file in files) {
      final originalName = p.basenameWithoutExtension(file.path);
      final sanitized = sanitize(originalName);

      // 3. Filename format validity
      if (originalName != sanitized) {
        warnings.add('Filename "$originalName" is invalid for Android resources.');
        autoFixes.add('Automatically rename "$originalName" to compliant component suffix "$sanitized" during compiles.');
      }

      // Check image metadata
      final bytes = file.readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image == null) {
        errors.add('Failed to decode PNG in "${p.basename(file.path)}".');
        continue;
      }

      // 4. Dimensions check
      if (image.width != 1024 || image.height != 1024) {
        warnings.add('"${p.basename(file.path)}" is not 1024x1024 pixels (found ${image.width}x${image.height}).');
        autoFixes.add('Automatically resize "${p.basename(file.path)}" to target 1024x1024 pixels in memory during compile.');
      }

      // 5. Transparency warning
      if (hasTransparency(image)) {
        warnings.add('"${p.basename(file.path)}" contains transparent pixels, which is unsupported on iOS alternate icons.');
        autoFixes.add('Automatically blend transparency onto solid white canvas backgrounds for iOS alternate icons and legacy Android mipmaps.');
      }
    }

    // 6. Manifest & Plist discrepancies
    _checkBuildSyncErrors(files, currentDir, warnings, autoFixes);

    // Print summary
    if (warnings.isNotEmpty) {
      print('\n⚠️  \x1B[33m\x1B[1mWarnings Found (${warnings.length}):\x1B[0m');
      for (final w in warnings) {
        print('  - $w');
      }
    }

    if (autoFixes.isNotEmpty) {
      print('\n🔧 \x1B[32m\x1B[1mSuggested Automatic Fixing Actions:\x1B[0m');
      for (final f in autoFixes) {
        print('  ✔ $f');
      }
    }

    if (errors.isNotEmpty) {
      print('\n❌ \x1B[31m\x1B[1mBlocking Errors Found (${errors.length}):\x1B[0m');
      for (final e in errors) {
        print('  - $e');
      }
      print('\x1B[35m' + '=' * 60 + '\x1B[0m');
      exit(1);
    } else {
      print('\n✅ \x1B[32mStatic validation checks completed! Moving to generation.\x1B[0m');
    }
  }

  static String sanitize(String name) {
    var clean = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (RegExp(r'^[0-9_]').hasMatch(clean)) {
      clean = 'icon_$clean';
    }
    return clean;
  }

  static bool hasTransparency(img.Image imgObj) {
    for (final pixel in imgObj) {
      if (pixel.aNormalized < 1.0) return true;
    }
    return false;
  }

  static void _checkBuildSyncErrors(List<File> files, String currentDir, List<String> warnings, List<String> autoFixes) {
    final cleanNamesSet = files.map((f) => sanitize(p.basenameWithoutExtension(f.path))).where((name) => name != 'default').toSet();

    // Android Manifest sync check
    final manifestFile = File(p.join(currentDir, 'android', 'app', 'src', 'main', 'AndroidManifest.xml'));
    if (manifestFile.existsSync()) {
      final content = manifestFile.readAsStringSync();
      final aliasRegex = RegExp(r'<activity-alias[^>]*android:name="[^"]+\.MainActivity([^"]+)"');
      final declaredAliasesSet = aliasRegex.allMatches(content).map((m) => m.group(1)!).toSet();

      final missingInManifest = cleanNamesSet.difference(declaredAliasesSet);
      final redundantInManifest = declaredAliasesSet.difference(cleanNamesSet);

      if (missingInManifest.isNotEmpty || redundantInManifest.isNotEmpty) {
        warnings.add('AndroidManifest.xml activity-alias declarations are out of sync with assets/app_icons/.');
        autoFixes.add('Automatically inject matches and remove redundant lines in AndroidManifest.xml.');
      }
    }

    // iOS Plist sync check
    final plistFile = File(p.join(currentDir, 'ios', 'Runner', 'Info.plist'));
    if (plistFile.existsSync()) {
      final content = plistFile.readAsStringSync();
      final legacyMatch = RegExp(r'<!--\s*switch_app_icon:inject:start\s*-->.*?<!--\s*switch_app_icon:inject:end\s*-->', dotAll: true);
      if (!legacyMatch.hasMatch(content)) {
        warnings.add('Info.plist switch_app_icon settings block is missing or corrupt.');
        autoFixes.add('Automatically re-inject alternate icon blocks into Info.plist.');
      }
    }
  }
}

class IconResizingEngine {
  final String currentDir;

  IconResizingEngine({required this.currentDir});

  void generate(List<File> files) {
    final validNames = <String>[];
    final validImages = <String, img.Image>{};

    for (final file in files) {
      final originalName = p.basenameWithoutExtension(file.path);
      final sanitizeName = AppIconValidator.sanitize(originalName);
      
      final bytes = file.readAsBytesSync();
      var image = img.decodeImage(bytes);

      if (image == null) {
        continue;
      }

      // Auto-fix resizing check
      if (image.width != 1024 || image.height != 1024) {
        image = img.copyResize(image, width: 1024, height: 1024);
      }

      validNames.add(sanitizeName);
      validImages[sanitizeName] = image;
    }

    // 1. Generate Android Assets (Mipmaps & Adaptive Layers)
    print('\n🤖 \x1B[1m\x1B[34m[Android] Generating Legacy and Adaptive Icons...\x1B[0m');
    final androidResDir = Directory(p.join(currentDir, 'android', 'app', 'src', 'main', 'res'));
    if (!androidResDir.existsSync()) {
      print('⚠️  Android res directory not found at "${androidResDir.path}". Skipping.');
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
        final source = entry.value;

        final isTrans = AppIconValidator.hasTransparency(source);

        // Define adaptive layers
        img.Image foregroundLayer;
        img.Image backgroundLayer;
        img.Image legacyLayer;

        if (isTrans) {
          foregroundLayer = source;
          backgroundLayer = _createSolidWhite(1024);
          legacyLayer = _blendOnWhiteBackground(source);
        } else {
          foregroundLayer = _createPaddedForeground(source);
          backgroundLayer = source;
          legacyLayer = source;
        }

        // Write layered density PNG files
        for (final density in androidDensities.entries) {
          final densityFolder = Directory(p.join(androidResDir.path, density.key));
          if (!densityFolder.existsSync()) {
            densityFolder.createSync(recursive: true);
          }
          final size = density.value;

          // Legacy & Round (must be fully opaque)
          final resizedLegacy = img.copyResize(legacyLayer, width: size, height: size);
          File(p.join(densityFolder.path, 'ic_launcher_$name.png'))
              .writeAsBytesSync(img.encodePng(resizedLegacy));
          File(p.join(densityFolder.path, 'ic_launcher_${name}_round.png'))
              .writeAsBytesSync(img.encodePng(resizedLegacy));

          // Adaptive Foreground
          final resizedFore = img.copyResize(foregroundLayer, width: size, height: size);
          File(p.join(densityFolder.path, 'ic_launcher_${name}_foreground.png'))
              .writeAsBytesSync(img.encodePng(resizedFore));

          // Adaptive Background
          final resizedBack = img.copyResize(backgroundLayer, width: size, height: size);
          File(p.join(densityFolder.path, 'ic_launcher_${name}_background.png'))
              .writeAsBytesSync(img.encodePng(resizedBack));
        }

        // Write Adaptive Launcher XML configuration wrapper
        final v26Folder = Directory(p.join(androidResDir.path, 'mipmap-anydpi-v26'));
        if (!v26Folder.existsSync()) {
          v26Folder.createSync(recursive: true);
        }
        final xmlWrapper = File(p.join(v26Folder.path, 'ic_launcher_$name.xml'));
        xmlWrapper.writeAsStringSync('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_${name}_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_${name}_foreground"/>
</adaptive-icon>
''');

        print('  🎉 Generated legacy, adaptive foreground/background, and XML drawables for: $name');
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
      final injectRegex = RegExp(r'<!--\s*switch_app_icon:inject:start\s*-->.*?<!--\s*switch_app_icon:inject:end\s*-->', dotAll: true);
      manifestContent = manifestContent.replaceAll(injectRegex, '');

      // Generate alternate activity-alias entries
      final buffer = StringBuffer();
      buffer.writeln('        <!-- switch_app_icon:inject:start -->');
      for (final name in validNames) {
        if (name == 'default') continue; 
        buffer.writeln('        <activity-alias');
        buffer.writeln('            android:name="$mainActivityName$name"');
        buffer.writeln('            android:enabled="false"');
        buffer.writeln('            android:exported="true"');
        buffer.writeln('            android:icon="@mipmap/ic_launcher_$name"'); // Links to the adaptive XML wrapper on API 26+
        buffer.writeln('            android:targetActivity="$mainActivityName">');
        buffer.writeln('            <intent-filter>');
        buffer.writeln('                <action android:name="android.intent.action.MAIN"/>');
        buffer.writeln('                <category android:name="android.intent.category.LAUNCHER"/>');
        buffer.writeln('            </intent-filter>');
        buffer.writeln('        </activity-alias>');
      }
      buffer.write('        <!-- switch_app_icon:inject:end -->');

      final closingAppIndex = manifestContent.indexOf('</application>');
      if (closingAppIndex == -1) {
        print('❌ FAILED: Closing </application> tag not found in AndroidManifest.xml');
      } else {
        manifestContent = manifestContent.replaceRange(closingAppIndex, closingAppIndex, '${buffer.toString()}\n    ');
        manifestFile.writeAsStringSync(manifestContent);
        print('  🎉 Success: AndroidManifest.xml aliases updated successfully!');
      }
    }

    // 3. Generate iOS alternate icons in Runner (Blend transparency onto solid white)
    print('\n🍏 \x1B[1m\x1B[32m[iOS] Generating Alternate Icons...\x1B[0m');
    final iosRunnerDir = Directory(p.join(currentDir, 'ios', 'Runner'));
    if (!iosRunnerDir.existsSync()) {
      print('⚠️  iOS Runner directory not found. Skipping.');
    } else {
      for (final entry in validImages.entries) {
        final name = entry.key;
        final source = entry.value;

        if (name == 'default') continue; 

        // Blend transparency onto white (iOS alternate icons must be 100% opaque)
        final iosOpaqueSrc = AppIconValidator.hasTransparency(source) ? _blendOnWhiteBackground(source) : source;

        // Render sizes: iPhone (@2x = 120, @3x = 180), iPad (@2x = 152, iPad pro = 167, @1x = 76)
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

          final resized = img.copyResize(iosOpaqueSrc, width: dimension, height: dimension);
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
      final injectRegex = RegExp(r'<!--\s*switch_app_icon:inject\s*-->.*?<!--\s*switch_app_icon:inject:end\s*-->', dotAll: true);
      plistContent = plistContent.replaceAll(injectRegex, '');

      // Backup regex to clean legacy format
      final legacyRegex = RegExp(r'<!--\s*switch_app_icon:inject:start\s*-->.*?<!--\s*switch_app_icon:inject:end\s*-->', dotAll: true);
      plistContent = plistContent.replaceAll(legacyRegex, '');

      final alternateNames = validNames.where((n) => n != 'default').toList();

      final buffer = StringBuffer();
      buffer.writeln('	<!-- switch_app_icon:inject:start -->');
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
      buffer.write('	<!-- switch_app_icon:inject:end -->');

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
  }

  img.Image _createSolidWhite(int size) {
    final canvas = img.Image(width: size, height: size, numChannels: 4);
    for (final pixel in canvas) {
      pixel.r = 255; pixel.g = 255; pixel.b = 255; pixel.a = 255;
    }
    return canvas;
  }

  img.Image _createPaddedForeground(img.Image src) {
    final size = src.width;
    final scaledSize = (size * 0.66).round();
    final scaled = img.copyResize(src, width: scaledSize, height: scaledSize);
    
    final canvas = img.Image(width: size, height: size, numChannels: 4);
    for (final pixel in canvas) {
      pixel.r = 0; pixel.g = 0; pixel.b = 0; pixel.a = 0;
    }
    
    final offset = (size - scaledSize) ~/ 2;
    for (int y = 0; y < scaled.height; y++) {
      for (int x = 0; x < scaled.width; x++) {
        canvas.setPixel(offset + x, offset + y, scaled.getPixel(x, y));
      }
    }
    return canvas;
  }

  img.Image _blendOnWhiteBackground(img.Image src) {
    final canvas = img.Image(width: src.width, height: src.height, numChannels: 4);
    for (final pixel in canvas) {
      pixel.r = 255; pixel.g = 255; pixel.b = 255; pixel.a = 255;
    }
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final srcPixel = src.getPixel(x, y);
        final a = srcPixel.aNormalized;
        if (a > 0.0) {
          final dstPixel = canvas.getPixel(x, y);
          if (a >= 1.0) {
            canvas.setPixel(x, y, srcPixel);
          } else {
            dstPixel.r = (srcPixel.r * a + dstPixel.r * (1.0 - a)).round();
            dstPixel.g = (srcPixel.g * a + dstPixel.g * (1.0 - a)).round();
            dstPixel.b = (srcPixel.b * a + dstPixel.b * (1.0 - a)).round();
          }
        }
      }
    }
    return canvas;
  }
}
