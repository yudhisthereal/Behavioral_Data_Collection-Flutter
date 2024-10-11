import 'package:behavioral_data_collection/theme/colors.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUserMessage;

  const ChatBubble({super.key, required this.text, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    Radius bottomRight = isUserMessage ? const Radius.circular(0) : const Radius.circular(20);
    Radius bottomLeft = isUserMessage ? const Radius.circular(20) : const Radius.circular(0);
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isUserMessage ? AppColors.secondary : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: bottomLeft,
            bottomRight: bottomRight,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}