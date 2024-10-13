import 'package:behavioral_data_collection/screens/drawing_screen.dart';
import 'package:behavioral_data_collection/widgets/custom_button.dart';
import 'package:behavioral_data_collection/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/data_storage.dart';
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

  Future<void> _requestStoragePermission() async {
    await Permission.storage
        .onDeniedCallback(() {
          // Handle permission denied
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied.')),
          );
        })
        .onGrantedCallback(() {
          // Handle permission granted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission granted!')),
          );
        })
        .onPermanentlyDeniedCallback(() {
          // Handle permanently denied
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission permanently denied. Please enable it in app settings.')),
          );
          openAppSettings(); // Open app settings if the permission is permanently denied
        })
        .onRestrictedCallback(() {
          // Handle restricted permission
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is restricted.')),
          );
        })
        .onLimitedCallback(() {
          // Handle limited permission
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is limited.')),
          );
        })
        .onProvisionalCallback(() {
          // Handle provisional permission
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is provisional.')),
          );
        })
    .request();
  }

  @override
  void dispose() {
    // Dispose of the controller when no longer needed
    _controller.dispose();
    super.dispose();
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
              const Text(
                'Abot is a chatbot who will guide you through the session. Let\'s play with Abot!',
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
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
              CustomButton(
                text: 'Get Started!',
                bgColor: AppColors.primary,
                textColor: AppColors.onPrimary,
                onPressed: () async {
                  DataStorage.userName = _controller.text;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DrawingScreen()),
                  );
                },
                isEnabled: isButtonEnabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
