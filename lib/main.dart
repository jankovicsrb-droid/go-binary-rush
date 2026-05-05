import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const BinaryRushApp());
}

class BinaryRushApp extends StatelessWidget {
  const BinaryRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Binary Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          primary: Color(0xFF00FF41),
        ),
        textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.robotoMono(
            color: const Color(0xFF00FF41),
            fontSize: 15,
            letterSpacing: 4,
          ),
        ),
      ),
      home: const GameScreen(),
    );
  }
}
