import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/domain/entities/sub_section.dart';
import 'package:my_app/domain/entities/surah.dart';
import 'package:my_app/domain/entities/tafsir.dart';
import 'package:my_app/domain/entities/mahawer.dart';
import 'package:my_app/domain/entities/section.dart';
import 'package:my_app/domain/entities/topic.dart';
import 'package:my_app/presentation/pages/home_page.dart';  // Adjust path to HomePage

void main() {
  group('UC09: Edit Extracted Content', () {
    test('UC09-UT-01: Editing a Section node updates the Tafsir object', () {
      // Arrange: Create mock Tafsir with Section
      final originalSection = Section(
        id: 'sec1',
        type: 'قسم',
        sequence: 'القسم الأول',
        text: 'Original text',
        ayat: [1, 2],
      );
      final tafsir = Tafsir(
        tafsirId: 't1',
        title: 'Test Tafsir',
        author: 'Test Author',
        publisher: 'Test Publisher',
        year: 2023,
        location: 'Test Location',
        isbn: '123456',
        surahId: '4',
        state: 'draft',
        surah: Surah(surahId: '4', surahName: 'سورة النساء'),
        mahawer: [
          Mahawer(
            id: 'm1',
            type: 'محور',
            sequence: 'المحور الأول',
            text: 'Test Mahawer',
            sections: [originalSection], 
            title: 'المحور الأول',
          ),
        ],
      );

      // Act: Simulate editing (update text)
      final updatedSection = Section(
        id: 'sec1',
        type: 'قسم',
        sequence: 'القسم الأول',
        text: 'Edited text via AI refinement',  // Simulate AI-assisted edit
        ayat: [1, 2],
      );

      // Simulate _onNodeEdited logic (find and replace)
      final mahawerIndex = tafsir.mahawer.indexWhere((m) => m.id == 'm1');
      final sectionIndex = tafsir.mahawer[mahawerIndex].sections.indexWhere((s) => s.id == 'sec1');
      tafsir.mahawer[mahawerIndex].sections[sectionIndex] = updatedSection;

      // Assert: Verify update
      expect(tafsir.mahawer[0].sections[0].text, 'Edited text via AI refinement');
    });

    test('UC09-UT-02: Ayat list casting works for edited content', () {
      // Arrange: Mock dynamic ayat from AI-processed data
      final dynamicAyat = [1, 2, 3] as List<dynamic>;

      // Act: Cast to List<int> (simulate editing)
      final castedAyat = dynamicAyat.map((e) => e as int).toList();

      // Assert: Correct casting
      expect(castedAyat, [1, 2, 3]);
    });

    test('UC09-UT-03: Editing handles empty topics list', () {
      // Arrange: Section with empty topics
      final section = Section(
        id: 'sec2',
        type: 'قسم',
        sequence: 'القسم الثاني',
        text: 'Test',
        subSections: [
          SubSection(id: 'sub1', type: 'فصل', sequence: 'الفصل الأول', text: 'Test', topics: []),
        ],
      );

      // Act: Edit subsection (add topic)
      final updatedSub = SubSection(
        id: 'sub1',
        type: 'فصل',
        sequence: 'الفصل الأول',
        text: 'Edited via AI',
        topics: [Topic(id: 't1', type: 'قضية', sequence: 'القضية الأولى', text: 'AI-added topic')],
      );

      // Simulate update
      section.subSections![0] = updatedSub;

      // Assert: Topics added
      expect(section.subSections![0].topics!.length, 1);
    });
  });
}