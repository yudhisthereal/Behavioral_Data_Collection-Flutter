import 'package:behavioral_data_collection/screens/onboarding_screen.dart';
import 'package:behavioral_data_collection/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thank You Text
            const Text(
              'Thank you for participating!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF422B97), // Primary color
              ),
            ),
            const SizedBox(height: 20.0),
            // End the Session Button
            CustomButton(
                text: "End the Session",
                bgColor: AppColors.red,
                textColor: AppColors.onPrimary,
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen())
                  )
                }
            )
          ],
        ),
      ),
    );
  }
}
