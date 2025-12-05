import 'dart:typed_data';

abstract class PdfRepository {
  Future<String> extractText(Uint8List pdfBytes);
}