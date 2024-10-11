import 'package:behavioral_data_collection/screens/chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    // Store the current ScaffoldMessengerState
    final messenger = ScaffoldMessenger.of(context);

    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Storage permission granted!')),
      );
      // Navigate to the next screen or perform any other action
    } else if (status.isDenied) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // Open app settings if the permission is permanently denied
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title Text
            const Text(
              'Chat, Sketch, and Play with Abot!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),

            // Description Text
            const Text(
              'Abot is a chatbot who will guide you through the session. Let\'s play with Abot!',
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.lightGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),

            // Illustration Image
            Center(
              child: Image.asset(
                'assets/gambar_signature.png',
                width: 200.0,
                height: 200.0,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32.0),

            // Get Started Button
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Primary color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
              ),
              child: const Text(
                'Get Started!',
                style: TextStyle(
                  color: Colors.white, // On primary color
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
