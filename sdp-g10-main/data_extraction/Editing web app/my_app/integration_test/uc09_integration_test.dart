import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart';
import 'package:my_app/presentation/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://zbyrqebgmnxtzyydqhby.supabase.co', 
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpieXJxZWJnbW54dHp5eWRxaGJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MzE4NzEsImV4cCI6MjA3ODUwNzg3MX0.kedjnq1wklnqX4vr5x5JSaUqzEtbSFkVTBnG2BcIeNg', // Replace with your public anon key
  );
  });

  group('UC09: Edit Tafsir Data', () {
    testWidgets('UC09-IT-01: Edit tafsir metadata and save changes', (WidgetTester tester) async {
      await tester.pumpWidget( MyApp());
      await tester.pumpAndSettle();

      // Wait for tafsirs to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if dropdown has items
      final dropdownItems = find.byType(DropdownMenuItem<String>);
      if (dropdownItems.evaluate().isEmpty) {
        // No tafsirs, skip test
        expect(find.text('Select a Tafsir to Load'), findsOneWidget);
        return;
      }

      // Select first tafsir
      await tester.tap(find.byKey(const Key('tafsir_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(dropdownItems.first);
      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.byKey(const Key('edit_button')));
      await tester.pumpAndSettle();

      // Edit fields
      await tester.enterText(find.byKey(const Key('title_field')), 'Updated Title');
      await tester.enterText(find.byKey(const Key('author_field')), 'Updated Author');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.byKey(const Key('save_metadata_button')));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Tafsir updated successfully'), findsOneWidget);
    });

    testWidgets('UC09-IT-02: Edit handles invalid input gracefully', (WidgetTester tester) async {
      await tester.pumpWidget( MyApp());
      await tester.pumpAndSettle();

      // Wait for tafsirs to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if dropdown has items
      final dropdownItems = find.byType(DropdownMenuItem<String>);
      if (dropdownItems.evaluate().isEmpty) {
        // No tafsirs, skip test
        expect(find.text('Select a Tafsir to Load'), findsOneWidget);
        return;
      }

      // Select first tafsir
      await tester.tap(find.byKey(const Key('tafsir_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(dropdownItems.first);
      await tester.pumpAndSettle();

      // Tap edit
      await tester.tap(find.byKey(const Key('edit_button')));
      await tester.pumpAndSettle();

      // Enter invalid input
      await tester.enterText(find.byKey(const Key('title_field')), '');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.byKey(const Key('save_metadata_button')));
      await tester.pumpAndSettle();

      // Verify error
      expect(find.text('Title cannot be empty'), findsOneWidget);
    });
  });
}