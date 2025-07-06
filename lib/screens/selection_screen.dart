import 'package:flutter/material.dart';
import 'package:video_editor/helpers/screen_sizes.dart';
import 'package:video_editor/helpers/screen_transition.dart';
import 'package:video_editor/screens/audio_projects_screen.dart';
import 'package:video_editor/screens/video_projects_screen.dart';
import 'package:video_editor/widgets/custom_button.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double buttonSize = ScreenSizes.width(context) * 0.4;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox.expand(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: ScreenSizes.height(context) * 0.35,
            child: Center(
              child: Text(
                'Create & Edit\nYour Videos and Audio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenSizes.width(context) * 0.07,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: ScreenSizes.height(context) * 0.5,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87, Colors.black],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: ScreenSizes.height(context) * 0.08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(screenTransition(VideoEditorScreen()));
                    },
                    text: 'Video',
                  ),
                ),
                SizedBox(width: ScreenSizes.width(context) * 0.06),
                SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(screenTransition(AudioEditorScreen()));
                    },
                    text: 'Audio',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
