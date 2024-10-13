import 'package:behavioral_data_collection/models/keystroke_data.dart';
import 'package:behavioral_data_collection/screens/horizontal_swipe_screen.dart';
import 'package:behavioral_data_collection/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import '../services/data_storage.dart';
import '../widgets/chat_bubble.dart';
import '../theme/colors.dart';

class TypingTestScreen extends StatefulWidget {
  const TypingTestScreen({super.key});

  @override
  TypingTestScreenState createState() => TypingTestScreenState();
}

class TypingTestScreenState extends State<TypingTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatBubble> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final KeystrokeSession _alphabeticalSession = KeystrokeSession();
  final KeystrokeSession _numericalSession = KeystrokeSession();
  final KeystrokeSession _mixedSession = KeystrokeSession();
  final DataStorage _dataStorage = DataStorage();
  int _currentStep = 0;
  DateTime? _lastKeyTime;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // Ensure focus is requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendChat("If you were creating a username for your game profile, what would it be?");
    });
    _controller.addListener(_handleTextChange); // Listen for text changes
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    if (_controller.text.isNotEmpty) {
      DateTime now = DateTime.now();
      String lastKeyPressed = _controller.text[_controller.text.length - 1]; // Get the last typed character

      if (_lastKeyTime != null) {
        // Calculate flight time
        Duration flightTime = now.difference(_lastKeyTime!);
        _addFlightTime(lastKeyPressed, flightTime.inMilliseconds);
      }

      _lastKeyTime = now; // Update the last keypress time
    }
  }

  void _addFlightTime(String key, int flightTime) {
    // Add flight time and key to the current session depending on the step
    if (_currentStep == 1) {
      _alphabeticalSession.addFlightTime(key, flightTime);
    } else if (_currentStep == 2) {
      _numericalSession.addFlightTime(key, flightTime);
    } else if (_currentStep == 3) {
      _mixedSession.addFlightTime(key, flightTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Abot', style: TextStyle(color: AppColors.primary)),
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: AppColors.primary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: CustomTextField(controller: _controller, hintText: 'Type a message')),
          IconButton(
            onPressed: () {
              _sendMessage(_controller.text);
            },
            icon: const Icon(Icons.send_outlined, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(ChatBubble(text: message, isUserMessage: true));
        _processUserInput(message);
        _controller.clear();
        _lastKeyTime = null; // Reset keypress time after message is sent
      });
      _scrollToBottom();
    }
  }

  void _sendChat(String message) {
    setState(() {
      _messages.add(ChatBubble(text: message, isUserMessage: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _processUserInput(String input) {
    switch (_currentStep) {
      case 0:
        _currentStep++;
        _sendChat("Cool! then, what's its password?");
        break;
      case 1:
        _currentStep++;
        _sendChat("Please write the following number!");
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendChat("990123477130546");
        });
        break;
      case 2:
        _dataStorage.saveNumericalKeystrokeData(_numericalSession.toList());
        _currentStep++;
        _sendChat("Please write the following sentence!");
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendChat("Don't be discouraged when things go wrong, you're strong!");
        });
        break;
      case 3:
        _dataStorage.saveAlphabeticalKeystrokeData(_alphabeticalSession.toList());
        _currentStep++;
        _sendChat("Please write the following sentence!");
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendChat(
              "I love you 3000...");
        });
        break;
      case 4:
        _dataStorage.saveMixedKeystrokeData(_mixedSession.toList());
        _showCompletionPopup();
        break;
    }
  }

  void _showCompletionPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(24.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Great! Let's continue!",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HorizontalSwipeScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Next',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
