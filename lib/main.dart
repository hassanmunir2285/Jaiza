import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(), // 👈 WelcomeScreen is now the main screen
    );
  }
}
