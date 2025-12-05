import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String imagePath;

  const ImageViewer({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Viewing Image',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: InteractiveViewer(
        panEnabled: true,
        minScale: 1,
        maxScale: 1.5,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
}
