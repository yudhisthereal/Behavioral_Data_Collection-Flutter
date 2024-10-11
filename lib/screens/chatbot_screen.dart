import 'package:behavioral_data_collection/screens/lock_pattern_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';
import '../theme/colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ChatbotScreenState createState() => ChatbotScreenState();
}

class ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatBubble> _messages = [];
  int _currentStep = 0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showStartPopup());
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          if (_currentStep == 1) _buildGenderOptions(),
          if (_currentStep == 2) _buildHandednessOptions(),
          if (_currentStep != 1 && _currentStep != 2 && _currentStep < 4)
            _buildUserInput(),
          if (_currentStep >= 4) _buildStartButton()
        ],
      ),
    );
  }

  void _showStartPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Start the Session',
            style: TextStyle(color: AppColors.primary), // Set title color,.
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Press Start to begin the session.',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendChat("Hi, my name is Abot. What is your name?");
                },
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Start',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton(
        onPressed: () {
          _startGame();
        },
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.black),
          padding: const EdgeInsets.all(20),
        ),
        child: const Text(
          "Start",
          style: TextStyle(color: Colors.black),
        ),
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
    }
  }

  void _sendChat(String message) {
    setState(() {
      _messages.add(ChatBubble(text: message, isUserMessage: false));
    });
  }

  void _processUserInput(String input) {
    switch (_currentStep) {
      case 0:
        _userName = input;
        _currentStep++;
        _sendChat("Please indicate your gender.");
        break;
      case 1:
        _currentStep++;
        _sendChat("Are you left-handed or right-handed?");
        break;
      case 2:
        _currentStep++;
        _sendChat("How old are you, $_userName?");
        break;
      case 3:
        _currentStep++;
        _sendChat("Great, now let's play some games!");
        break;
    }
  }

  Widget _buildGenderOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              _sendMessage("I'm a Male.");
            },
            child: const Text("Male"),
          ),
          ElevatedButton(
            onPressed: () {
              _sendMessage("I'm a Female.");
            },
            child: const Text("Female"),
          ),
          ElevatedButton(
            onPressed: () {
              _sendMessage("I'd rather not say.");
            },
            child: const Text("Other"),
          ),
        ],
      ),
    );
  }

  Widget _buildHandednessOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              _sendMessage("Left-handed");
            },
            child: const Text("Left-handed"),
          ),
          ElevatedButton(
            onPressed: () {
              _sendMessage("Right-handed");
            },
            child: const Text("Right-handed"),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LockPatternScreen()));
  }
}