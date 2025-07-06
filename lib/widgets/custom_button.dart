import 'package:flutter/material.dart';
import 'package:video_editor/helpers/screen_sizes.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.text});

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: BorderSide(color: Colors.grey[400]!, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScreenSizes.width(context) * 0.03,
          ),
        ),
      ),
      onPressed: () {
        // TODO: Navigate to video screen
      },
      child: Text(
        'Video',
        style: TextStyle(
          color: Colors.white,
          fontSize: ScreenSizes.width(context) * 0.045,
        ),
      ),
    );
  }
}
