import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  final String assetPath;
  final String? title;
  const ImageViewerScreen({super.key, required this.assetPath, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Image')),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
