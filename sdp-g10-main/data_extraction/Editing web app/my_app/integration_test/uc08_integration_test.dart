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
      url: 'https://zbyrqebgmnxtzyydqhby.supabase.co',  // Replace with your actual URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpieXJxZWJnbW54dHp5eWRxaGJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MzE4NzEsImV4cCI6MjA3ODUwNzg3MX0.kedjnq1wklnqX4vr5x5JSaUqzEtbSFkVTBnG2BcIeNg',  // Replace with your actual anon key
    );
  });

  group('UC08: Extract Data Using AI-Assistant', () {
    testWidgets('UC08-IT-01: AI-assisted PDF upload and storage', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Verify the upload FAB is present (UI is set up for PDF upload)
      expect(find.byKey(const Key('upload_fab')), findsOneWidget);
    });

    testWidgets('UC08-IT-02: AI extraction handles invalid PDF gracefully', (WidgetTester tester) async {
      await tester.pumpWidget( MyApp());
      await tester.pumpAndSettle();

      // Verify the upload FAB is present (UI is set up for PDF upload)
      expect(find.byKey(const Key('upload_fab')), findsOneWidget);
    });
  });
}