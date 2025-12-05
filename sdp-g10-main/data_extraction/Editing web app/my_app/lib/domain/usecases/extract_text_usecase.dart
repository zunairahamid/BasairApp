import 'dart:typed_data';

import '../repositories/pdf_repository.dart';

class ExtractTextUseCase {
  final PdfRepository pdfRepository;

  ExtractTextUseCase(this.pdfRepository);

  Future<String> call(Uint8List pdfBytes) => pdfRepository.extractText(pdfBytes);
}