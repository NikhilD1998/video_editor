import 'package:flutter/material.dart';

class VideoEditorScreen extends StatelessWidget {
  const VideoEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Video Editor Screen',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
