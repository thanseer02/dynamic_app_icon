// ignore_for_file: avoid_print

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final dir = Directory('example/assets/app_icons');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // Create default.png (red)
  final img1 = img.Image(width: 200, height: 200);
  img.fill(img1, color: img.ColorRgb8(255, 0, 0));
  File('example/assets/app_icons/default.png').writeAsBytesSync(img.encodePng(img1));

  // Create dark_icon.png (black)
  final img2 = img.Image(width: 200, height: 200);
  img.fill(img2, color: img.ColorRgb8(30, 30, 30));
  File('example/assets/app_icons/dark_icon.png').writeAsBytesSync(img.encodePng(img2));

  // Create festive_icon.png (gold)
  final img3 = img.Image(width: 200, height: 200);
  img.fill(img3, color: img.ColorRgb8(255, 215, 0));
  File('example/assets/app_icons/festive_icon.png').writeAsBytesSync(img.encodePng(img3));

  print('Created test asset images in example/assets/app_icons/');
}
