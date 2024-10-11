import 'package:behavioral_data_collection/screens/card_swipe_screen.dart';
import 'package:flutter/material.dart';
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
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendChat("If you were creating a username for your game profile, what would it be?");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
              controller: _scrollController, // Attach the ScrollController
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
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
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
        _currentStep++;
        _sendChat("Please write the following sentence!");
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendChat("Don't be discouraged when things go wrong, you're strong!");
        });
        break;
      case 3:
        _currentStep++;
        _sendChat("Please write the following sentence!");
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendChat(
              "Norway, known for its stunning fjords, has a coastline that stretches approximately 2,580 kilometers, with over 50,000 islands.");
        });
        break;
      case 4:
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
                "Great! Let's continue to the last game!",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center-align the text
              ),
              const SizedBox(height: 20), // Add some space between text and button
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CardSwipeScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
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