import 'package:behavioral_data_collection/screens/drawing_screen.dart';
import 'package:behavioral_data_collection/widgets/custom_button.dart';
import 'package:behavioral_data_collection/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();

    // Listen to changes in the text field
    _controller.addListener(() {
      setState(() {
        isButtonEnabled = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when no longer needed
    _controller.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Container(
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
                  color: AppColors.darkGray,
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
              const Text(
                'Please enter your name',
                style: TextStyle(color: AppColors.primary),
              ),
              CustomTextField(controller: _controller, hintText: 'Enter your name'),
              // Get Started Button
              CustomButton(
                text: 'Get Started!',
                bgColor: AppColors.primary,
                textColor: AppColors.onPrimary,
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DrawingScreen()),
                  );
                },
                isEnabled: isButtonEnabled, // Use the state variable
              ),
            ],
          ),
        ),
      ),
    );
  }
}
