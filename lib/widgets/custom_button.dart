import 'package:flutter/material.dart';

import '../theme/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final Function onPressed;
  final bool isEnabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.bgColor,
    required this.textColor,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? () => onPressed() : null, // Disable onTap if not enabled
      child: AbsorbPointer(
        absorbing: !isEnabled, // Prevents taps if not enabled
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isEnabled ? bgColor : AppColors.lightGray, // Change color when disabled
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isEnabled ? textColor : AppColors.black, // Change text color when disabled
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
