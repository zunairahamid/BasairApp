import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'presentation/pages/home_page.dart';
import 'presentation/providers/json_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://zbyrqebgmnxtzyydqhby.supabase.co', 
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpieXJxZWJnbW54dHp5eWRxaGJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MzE4NzEsImV4cCI6MjA3ODUwNzg3MX0.kedjnq1wklnqX4vr5x5JSaUqzEtbSFkVTBnG2BcIeNg', // Replace with your public anon key
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => JsonProvider(), 
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tafsir Editor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}
