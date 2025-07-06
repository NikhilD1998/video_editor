import 'package:flutter/material.dart';
import 'package:video_editor/helpers/screen_sizes.dart';
import 'package:video_editor/widgets/custom_button.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double buttonSize = ScreenSizes.width(context) * 0.4;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: CustomButton(onPressed: () {}, text: 'Video'),
            ),
            SizedBox(height: ScreenSizes.height(context) * 0.03),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: CustomButton(onPressed: () {}, text: 'Audio'),
            ),
          ],
        ),
      ),
    );
  }
}
