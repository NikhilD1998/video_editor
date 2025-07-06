import 'package:flutter/material.dart';
import 'package:video_editor/helpers/screen_sizes.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.fontSize = 0.045,
  });

  final VoidCallback onPressed;
  final String text;
  final double fontSize;

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
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: ScreenSizes.width(context) * fontSize,
        ),
      ),
    );
  }
}
