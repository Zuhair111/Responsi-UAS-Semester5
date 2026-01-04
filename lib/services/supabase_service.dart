import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://zmpcueepuevlrkxjiork.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptcGN1ZWVwdWV2bHJreGppb3JrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcyOTgzODcsImV4cCI6MjA4Mjg3NDM4N30.moia9YHQ8JRu0qoPU9YsxU4jNuEuV9DR6PjVbkvS0bI';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  
  static User? get currentUser => client.auth.currentUser;
  
  static bool get isLoggedIn => currentUser != null;
}
