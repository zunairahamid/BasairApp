import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basair_real_app/core/data/database/database_provider.dart';
import 'package:basair_real_app/core/data/database/database_seeder.dart';
import 'package:basair_real_app/core/navigation/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
await dotenv.load(fileName: ".env");
await Supabase.initialize(
    url: 'https://phfiewpuqiqculaalyva.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoZmlld3B1cWlxY3VsYWFseXZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyODM2NDEsImV4cCI6MjA3MTg1OTY0MX0.tqDkeMeyOUzgd-GqzDp_0uDHUppst7htItdOaWjh86Q',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  try {
    final database = await container.read(databaseProvider.future);
    await QuranDatabaseSeeder.seedDatabase(database);
    debugPrint('Database initialized and seeded successfully');
    
  } catch (e) {
    debugPrint('Error initializing database: $e');
  }

  runApp(ProviderScope(
      child: BasairApp(),
    ),);
}

class BasairApp extends StatelessWidget {
  const BasairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Basair',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
