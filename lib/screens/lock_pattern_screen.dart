import 'package:behavioral_data_collection/screens/drawing_screen.dart';
import 'package:behavioral_data_collection/theme/colors.dart';
import 'package:behavioral_data_collection/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../widgets/pattern_widget.dart'; // Import the custom lock pattern widget

class LockPatternScreen extends StatefulWidget {
  const LockPatternScreen({super.key});

  @override
  LockPatternScreenState createState() => LockPatternScreenState();
}

class LockPatternScreenState extends State<LockPatternScreen> {
  late List<int> _pattern; // To store the pattern of connected circles
  bool _isPatternMade = false; // Flag to check if a pattern is made
  bool _isPatternValid = false; // Flag to check if a pattern is valid

  @override
  void initState() {
    super.initState();
    _pattern = [];
  }

  void _onPatternChanged(List<int> pattern) {
    setState(() {
      _pattern = pattern;
      _isPatternValid = _pattern.length >= 4; // Check if the pattern has at least 4 points
      _isPatternMade = _pattern.isNotEmpty;
    });
  }

  void _continue() {
    if (_isPatternMade) {
      // Navigate to the drawing activity
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DrawingScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lock Pattern'),
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: AppColors.primary),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "If you're setting up your screen lock, how would you create your screen lock pattern?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          LockPattern(
            onPatternChanged: _onPatternChanged,
          ),
          const SizedBox(height: 40), // Adjust this value for more or less space
          if (_isPatternMade) ...[
            if (!_isPatternValid) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Connect at least four dots!",
                  style: TextStyle(
                    color: Colors.red, // Set color for emphasis
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (_isPatternValid) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Great! Let's continue!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomButton(
                    text: 'Continue',
                    bgColor: _isPatternValid ? AppColors.primary : AppColors.lightGray,
                    textColor: _isPatternValid ? AppColors.onPrimary : AppColors.black,
                    onPressed: _continue
                )
              ),
            ],
          ],
        ],
      ),
    );
  }
}
