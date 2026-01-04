import 'package:flutter/material.dart';
import 'package:responsi/pages/welcome_page.dart';
import 'package:responsi/pages/home_page.dart';
import 'package:responsi/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(SocialHomePage());
}

class SocialHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SupabaseService.isLoggedIn ? HomePage() : WelcomePage(),
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Color(0xFFFFF7F3),
      ),
    );
  }
}