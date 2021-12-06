import 'package:flutter/material.dart';
// import 'saved_images.dart';
import 'image_homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Downloader',
      theme: ThemeData.dark(),
      home: ImageHomePage(title: 'Image Downloader'),
      // home: SavedImages(title: 'Saved Images'),
    );
  }
}

