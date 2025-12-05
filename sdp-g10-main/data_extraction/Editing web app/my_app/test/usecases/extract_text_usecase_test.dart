import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:my_app/domain/usecases/extract_text_usecase.dart';
import 'package:my_app/domain/repositories/pdf_repository.dart'; 

// Generate mocks
@GenerateMocks([PdfRepository])
import 'extract_text_usecase_test.mocks.dart';

void main() {
  late MockPdfRepository mockPdfRepo;
  late ExtractTextUseCase useCase;

  setUp(() {
    mockPdfRepo = MockPdfRepository();
    useCase = ExtractTextUseCase(mockPdfRepo);
  });

  group('UC08: Extract Data Using AI-Assistant', () {
    test('UC08-UT-01: AI API extracts text from PDF bytes', () async {
      // Arrange: Simulate PDF bytes and AI response
      final pdfBytes = Uint8List.fromList([1, 2, 3, 4]);
      when(mockPdfRepo.extractText(pdfBytes)).thenAnswer((_) async => 'AI-extracted structured text from PDF');

      // Act: Call the use case (await since it's async)
      final result = await useCase.call(pdfBytes);

      // Assert: Verify AI extraction returns expected text
      expect(result, 'AI-extracted structured text from PDF');
      verify(mockPdfRepo.extractText(pdfBytes)).called(1);
    });

    test('UC08-UT-02: AI API handles invalid PDF bytes gracefully', () async {
      // Arrange: Invalid bytes
      final invalidBytes = Uint8List.fromList([]);
      when(mockPdfRepo.extractText(invalidBytes)).thenThrow(Exception('Invalid PDF format'));

      // Act & Assert: Expect exception for invalid input
      expect(() async => await useCase.call(invalidBytes), throwsException);
    });

    test('UC08-UT-03: AI extraction converts text to JSON structure', () async {
      // Arrange: Mock AI response as JSON-ready text
      final pdfBytes = Uint8List.fromList([5, 6, 7]);
      when(mockPdfRepo.extractText(pdfBytes)).thenAnswer((_) async => '{"title": "AI-parsed Surah", "content": "Extracted via AI"}');

      // Act
      final result = await useCase.call(pdfBytes);

      // Assert: Verify JSON-like output
      expect(result.contains('AI-parsed'), true);
    });
  });
}

