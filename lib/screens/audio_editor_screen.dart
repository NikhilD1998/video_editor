import 'package:flutter/material.dart';

class AudioEditorScreen extends StatelessWidget {
  const AudioEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Audio Editor Screen',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
