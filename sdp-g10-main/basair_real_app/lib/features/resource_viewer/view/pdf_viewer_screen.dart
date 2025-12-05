import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatefulWidget {
  final String assetPath;
  final String title;
  final int initialPage;

  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
    this.initialPage = 1,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await rootBundle.load(widget.assetPath);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/_tmp.pdf');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    setState(() => _localPath = file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: _localPath!,
              defaultPage: (widget.initialPage - 1).clamp(0, 9999),
            ),
    );
  }
}
