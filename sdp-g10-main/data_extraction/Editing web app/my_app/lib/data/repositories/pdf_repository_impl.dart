import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/pdf_repository.dart';

class PdfRepositoryImpl implements PdfRepository {
  final String backendUrl = 'http://localhost:3000/extract-text';

  @override
  Future<String> extractText(Uint8List pdfBytes) async {
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/pdf'},
      body: pdfBytes,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text'] ?? '';
    } else {
      throw Exception('Failed to extract text: ${response.body}');
    }
  }
}