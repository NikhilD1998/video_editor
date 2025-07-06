import 'package:flutter/material.dart';
import 'package:video_editor/helpers/constants.dart';
import 'package:video_editor/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Editor',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ), // Set Inter globally
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
